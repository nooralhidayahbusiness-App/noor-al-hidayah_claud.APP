import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsStatus { idle, playing, paused }

/// قراءة الأذكار والأدعية بصوت مسموع (محرك تحويل النص إلى كلام في الهاتف).
///
/// - كل قسم له جلسة مستقلة (مفتاح فريد) — لا ينتقل لقسم آخر تلقائياً.
/// - تشغيل / إيقاف مؤقت / إيقاف، مع تحكم بالسرعة.
/// - يمكنه الاستمرار في الخلفية (إن فعّل المستخدم ذلك).
class TtsService extends ChangeNotifier with WidgetsBindingObserver {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  String? _activeKey;
  TtsStatus _status = TtsStatus.idle;
  int _index = 0;
  List<String> _items = const [];
  String _lang = 'ar-SA';
  double _rate = 0.45;
  int _session = 0;
  Completer<void>? _done;

  String? _errorKey;
  String? _error;

  /// هل تستمر القراءة عند الخروج من الشاشة / قفل الهاتف؟
  bool keepInBackground = true;

  void setKeepInBackground(bool value) {
    keepInBackground = value;
    notifyListeners();
  }

  String? get activeKey => _activeKey;
  TtsStatus get status => _status;
  int get index => _index;
  int get total => _items.length;
  double get rate => _rate;
  String? get errorKey => _errorKey;
  String? get error => _error;

  Future<void> _init() async {
    if (_ready) return;
    _ready = true;
    WidgetsBinding.instance.addObserver(this);
    try {
      _tts.setCompletionHandler(_finishUtterance);
      _tts.setCancelHandler(_finishUtterance);
      _tts.setErrorHandler((_) => _finishUtterance());
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (_) {}
  }

  void _finishUtterance() {
    final d = _done;
    if (d != null && !d.isCompleted) d.complete();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused &&
        !keepInBackground &&
        _status == TtsStatus.playing) {
      stop();
    }
  }

  /// زر التشغيل: يبدأ / يوقف مؤقتاً / يستأنف حسب الحالة.
  Future<void> toggle(String key, List<String> items, String lang) async {
    await _init();
    if (_activeKey == key) {
      if (_status == TtsStatus.playing) {
        await pause();
        return;
      }
      if (_status == TtsStatus.paused) {
        await resume();
        return;
      }
    }
    await _start(key, items, lang);
  }

  Future<void> _start(String key, List<String> items, String lang) async {
    await _stopInternal();
    _session++;
    final s = _session;
    _activeKey = key;
    _items = items;
    _lang = lang;
    _index = 0;
    _error = null;
    _errorKey = null;
    _status = TtsStatus.playing;
    notifyListeners();

    final ok = await _prepare(key);
    if (!ok) {
      _status = TtsStatus.idle;
      _activeKey = null;
      notifyListeners();
      return;
    }
    unawaited(_run(s));
  }

  Future<bool> _prepare(String key) async {
    try {
      final r = await _tts.setLanguage(_lang);
      await _tts.setSpeechRate(_rate);
      final ok = (r == 1 || r == true);
      if (!ok) {
        _errorKey = key;
        _error = _lang.startsWith('ar')
            ? 'الصوت العربي غير مثبّت على هاتفك. من الإعدادات ← اللغة ← تحويل النص إلى كلام ← ثبّت الصوت العربي.'
            : 'The voice for this language is not installed. Settings ▸ Language ▸ Text-to-speech.';
      }
      return ok;
    } catch (_) {
      _errorKey = key;
      _error = _lang.startsWith('ar')
          ? 'تعذّر تشغيل القراءة الصوتية على هذا الهاتف.'
          : 'Text-to-speech is not available on this phone.';
      return false;
    }
  }

  Future<void> _run(int session) async {
    try {
      while (_index < _items.length) {
        if (session != _session || _status != TtsStatus.playing) return;
        notifyListeners();

        for (final chunk in _chunks(_items[_index])) {
          if (session != _session || _status != TtsStatus.playing) return;
          _done = Completer<void>();
          await _tts.speak(chunk);
          await _done!.future.timeout(
            const Duration(seconds: 180),
            onTimeout: () {},
          );
        }

        if (session != _session || _status != TtsStatus.playing) return;
        await Future.delayed(const Duration(milliseconds: 700));
        if (session != _session || _status != TtsStatus.playing) return;
        _index++;
      }

      // انتهت القراءة
      if (session == _session) {
        _status = TtsStatus.idle;
        _activeKey = null;
        _index = 0;
        notifyListeners();
      }
    } catch (_) {
      if (session == _session) {
        _status = TtsStatus.idle;
        _activeKey = null;
        notifyListeners();
      }
    }
  }

  /// تقسيم النصوص الطويلة (محرك الصوت يرفض النص الأطول من ~4000 حرف)
  List<String> _chunks(String text) {
    const max = 3000;
    if (text.length <= max) return [text];
    final out = <String>[];
    var rest = text;
    while (rest.length > max) {
      var cut = rest.lastIndexOf(' ', max);
      if (cut <= 0) cut = max;
      out.add(rest.substring(0, cut));
      rest = rest.substring(cut).trimLeft();
    }
    if (rest.isNotEmpty) out.add(rest);
    return out;
  }

  Future<void> pause() async {
    if (_status != TtsStatus.playing) return;
    _status = TtsStatus.paused;
    _session++;
    _finishUtterance();
    try {
      await _tts.stop();
    } catch (_) {}
    notifyListeners();
  }

  Future<void> resume() async {
    if (_status != TtsStatus.paused || _activeKey == null) return;
    _status = TtsStatus.playing;
    _session++;
    final s = _session;
    notifyListeners();
    final ok = await _prepare(_activeKey!);
    if (!ok) {
      _status = TtsStatus.idle;
      _activeKey = null;
      notifyListeners();
      return;
    }
    unawaited(_run(s));
  }

  Future<void> stop() async {
    await _stopInternal();
    _activeKey = null;
    _index = 0;
    notifyListeners();
  }

  Future<void> _stopInternal() async {
    _session++;
    _status = TtsStatus.idle;
    _finishUtterance();
    try {
      await _tts.stop();
    } catch (_) {}
  }

  Future<void> setSpeed(double rate) async {
    _rate = rate;
    notifyListeners();
    if (_status == TtsStatus.playing) {
      _session++;
      final s = _session;
      _finishUtterance();
      try {
        await _tts.stop();
        await _tts.setSpeechRate(_rate);
      } catch (_) {}
      unawaited(_run(s));
    }
  }
}

final TtsService ttsService = TtsService.instance;
