import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:record/record.dart';

enum VoicePhase { idle, calibrating, listening, error }

/// عدّاد صوتي: يفتح الميكروفون ويعدّ كل مرة ينطق فيها المستخدم الذكر.
///
/// يعمل **بدون إنترنت**: يكشف "مقاطع الكلام" (ارتفاع الصوت ثم صمت قصير)،
/// ولا يتعرّف على الكلمات نفسها. كل مقطع كلام = تكرار واحد.
class VoiceCounterEngine {
  VoiceCounterEngine({
    required this.onCount,
    required this.onLevel,
    required this.onPhase,
    this.sensitivity = 1,
  });

  /// يُستدعى عند كل تكرار
  final void Function() onCount;

  /// مستوى الصوت (0..1) لتحريك الأنيميشن
  final void Function(double level) onLevel;

  /// تغيّر الحالة (تهيئة / استماع / خطأ)
  final void Function(VoicePhase phase, String? message) onPhase;

  /// 0 = منخفضة، 1 = متوسطة، 2 = عالية
  int sensitivity;

  static const List<double> _multipliers = [4.2, 3.0, 2.2];
  static const int _sampleRate = 16000;

  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _sub;
  bool _running = false;

  // الزمن والمعايرة
  double _t = 0;
  final List<double> _calib = [];
  double _calibTime = 0;
  double _noise = 0.004;
  bool _calibrated = false;

  // كشف الكلام
  bool _speaking = false;
  double _aboveTime = 0;
  double _segStart = 0;
  double _lastLoud = 0;
  bool _segCounted = false;
  double _lastCountAt = -10;
  double _nextExtraAt = double.infinity;
  final List<double> _durations = [];
  double _smooth = 0;

  bool get isRunning => _running;

  Future<void> start() async {
    if (_running) return;
    _resetState();
    onPhase(VoicePhase.calibrating, null);

    try {
      final ok = await _recorder.hasPermission();
      if (!ok) {
        onPhase(VoicePhase.error, 'permission');
        return;
      }
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: _sampleRate,
          numChannels: 1,
        ),
      );
      _running = true;
      _sub = stream.listen(
        _onData,
        onError: (_) => onPhase(VoicePhase.error, 'stream'),
      );
    } catch (e) {
      _running = false;
      onPhase(VoicePhase.error, e.toString());
    }
  }

  Future<void> stop() async {
    _running = false;
    try {
      await _sub?.cancel();
    } catch (_) {}
    _sub = null;
    try {
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
    } catch (_) {}
    onLevel(0);
  }

  Future<void> dispose() async {
    await stop();
    try {
      await _recorder.dispose();
    } catch (_) {}
  }

  void _resetState() {
    _t = 0;
    _calib.clear();
    _calibTime = 0;
    _noise = 0.004;
    _calibrated = false;
    _speaking = false;
    _aboveTime = 0;
    _segStart = 0;
    _lastLoud = 0;
    _segCounted = false;
    _lastCountAt = -10;
    _nextExtraAt = double.infinity;
    _durations.clear();
    _smooth = 0;
  }

  void _onData(Uint8List data) {
    if (!_running) return;
    final n = data.length ~/ 2;
    if (n == 0) return;

    final bd = ByteData.sublistView(data);
    double sum = 0;
    for (var i = 0; i < n; i++) {
      final s = bd.getInt16(i * 2, Endian.little);
      sum += s * s;
    }
    final rms = math.sqrt(sum / n) / 32768.0;
    final dt = n / _sampleRate;
    _t += dt;

    // 1) معايرة الضجيج في أول ~0.9 ثانية (على المستخدم الصمت لحظة)
    if (!_calibrated) {
      _calib.add(rms);
      _calibTime += dt;
      if (_calibTime >= 0.9) {
        _calib.sort();
        final idx = (_calib.length * 0.6).floor().clamp(0, _calib.length - 1);
        _noise = math.max(0.003, _calib[idx]);
        _calibrated = true;
        onPhase(VoicePhase.listening, null);
      }
      onLevel(0);
      return;
    }

    final mult = _multipliers[sensitivity.clamp(0, 2)];
    final thr = math.max(0.015, _noise * mult);

    // مستوى الأنيميشن
    final norm = (rms / (thr * 3)).clamp(0.0, 1.0);
    _smooth = _smooth * 0.65 + norm * 0.35;
    onLevel(_smooth);

    final loud = rms > thr;

    if (!_speaking) {
      if (loud) {
        _aboveTime += dt;
      } else {
        _aboveTime = 0;
      }
      if (_aboveTime >= 0.10) {
        _speaking = true;
        _segStart = _t - _aboveTime;
        _lastLoud = _t;
        _segCounted = false;
        _nextExtraAt = double.infinity;
      }
      return;
    }

    // نحن داخل مقطع كلام
    if (rms > thr * 0.65) _lastLoud = _t;
    // مدة الكلام الفعلية (بدون فترة الصمت بعد النقرة/الكلمة)
    final loudDur = _lastLoud - _segStart;

    if (!_segCounted && loudDur >= 0.28) {
      _fire();
      _segCounted = true;
      final avg = _average();
      if (avg != null) _nextExtraAt = _segStart + avg * 1.9;
    } else if (_segCounted &&
        _t >= _nextExtraAt &&
        (_t - _lastLoud) < 0.15) {
      // ذكر متواصل بدون توقف: نعدّ تكراراً إضافياً كل متوسط مدة الذكر
      _fire();
      _nextExtraAt += (_average() ?? 1.0);
    }

    // نهاية المقطع: صمت أطول من 0.4 ثانية
    if (_t - _lastLoud >= 0.40) {
      final segDur = _lastLoud - _segStart;
      if (_segCounted && segDur >= 0.28 && segDur < 3.5) {
        _durations.add(segDur);
        if (_durations.length > 4) _durations.removeAt(0);
      }
      _speaking = false;
      _aboveTime = 0;
    }
  }

  double? _average() {
    if (_durations.length < 2) return null;
    var s = 0.0;
    for (final d in _durations) {
      s += d;
    }
    return math.max(0.5, s / _durations.length);
  }

  void _fire() {
    if (_t - _lastCountAt < 0.22) return;
    _lastCountAt = _t;
    onCount();
  }
}
