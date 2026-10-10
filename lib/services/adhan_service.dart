import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/adhan_reciters.dart';

class AdhanService {
  AdhanService._();
  static final AdhanService instance = AdhanService._();

  final AudioPlayer _player = AudioPlayer();
  String _currentReciterId = 'default';
  bool _isPlaying = false;
  bool _isMuted = false;
  Timer? _autoStopTimer;
  bool _contextSet = false;

  /// المؤذنون الجاري تحميلهم الآن (لتفادي التحميل المزدوج)
  final Set<String> _downloading = {};

  static const String _prefsKey = 'active_adhan';

  /// أقل حجم مقبول لملف صوتي صالح (يمنع حفظ صفحات خطأ HTML)
  static const int _minValidBytes = 20 * 1024;

  bool get isPlaying => _isPlaying;
  bool get isMuted => _isMuted;
  String get currentReciterId => _currentReciterId;

  Stream<PlayerState> get stateStream => _player.onPlayerStateChanged;
  Stream<Duration> get positionStream => _player.onPositionChanged;
  Stream<void> get completeStream => _player.onPlayerComplete;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentReciterId = prefs.getString(_prefsKey) ?? 'default';
    } catch (_) {}
    await _setupAudioContext();

    // ✅ نحمّل الأذان المختار + الافتراضي في الخلفية ليعملا بدون إنترنت
    Future.delayed(const Duration(seconds: 6), () {
      unawaited(precache(_currentReciterId));
      if (_currentReciterId != 'default') {
        unawaited(precache('default'));
      }
    });
  }

  Future<void> _setupAudioContext() async {
    if (_contextSet) return;
    try {
      await _player.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.alarm,
            audioFocus: AndroidAudioFocus.gain,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {AVAudioSessionOptions.mixWithOthers},
          ),
        ),
      );
      _contextSet = true;
    } catch (e) {
      debugPrint('Adhan AudioContext error: $e');
    }
  }

  Future<void> setReciter(String id) async {
    _currentReciterId = id;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, id);
    } catch (_) {}
    // ✅ حمّل المؤذن الجديد فوراً للعمل بدون إنترنت
    unawaited(precache(id));
  }

  // ============================================================
  // ✅ تخزين الأذان محلياً (للعمل بدون إنترنت)
  // ============================================================
  Future<Directory> _cacheDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/adhan_cache');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File?> _cachedFile(String id) async {
    try {
      final dir = await _cacheDir();
      final file = File('${dir.path}/$id.mp3');
      if (await file.exists() && await file.length() >= _minValidBytes) {
        return file;
      }
    } catch (_) {}
    return null;
  }

  /// أي أذان محفوظ على الجهاز (آخر حل عند انقطاع الإنترنت)
  Future<File?> _anyCachedFile() async {
    try {
      final dir = await _cacheDir();
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.mp3'))
          .toList();
      for (final f in files) {
        if (await f.length() >= _minValidBytes) return f;
      }
    } catch (_) {}
    return null;
  }

  /// يحمّل صوت المؤذن ويحفظه على الجهاز. يعيد true عند النجاح.
  Future<bool> precache(String id) async {
    if (kIsWeb) return false;
    if (_downloading.contains(id)) return false;

    final existing = await _cachedFile(id);
    if (existing != null) return true;

    final reciter = adhanReciterById(id);
    if (reciter == null) return false;

    _downloading.add(id);
    try {
      final response = await http
          .get(Uri.parse(reciter.mp3Url))
          .timeout(const Duration(seconds: 60));

      if (response.statusCode != 200 ||
          response.bodyBytes.length < _minValidBytes) {
        debugPrint('[ADHAN] precache bad response for $id');
        return false;
      }

      final dir = await _cacheDir();
      final tmp = File('${dir.path}/$id.tmp');
      await tmp.writeAsBytes(response.bodyBytes, flush: true);
      await tmp.rename('${dir.path}/$id.mp3');
      debugPrint('[ADHAN] ✅ cached $id (${response.bodyBytes.length} bytes)');
      return true;
    } catch (e) {
      debugPrint('[ADHAN] precache failed for $id: $e');
      return false;
    } finally {
      _downloading.remove(id);
    }
  }

  Future<bool> play({String? reciterId}) async {
    try {
      await _setupAudioContext();

      String id = reciterId ?? _currentReciterId;
      try {
        final prefs = await SharedPreferences.getInstance();
        id = reciterId ?? prefs.getString(_prefsKey) ?? _currentReciterId;
      } catch (_) {}

      final reciter = adhanReciterById(id) ?? kAdhanReciters.first;

      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setVolume(_isMuted ? 0.0 : 1.0);

      bool started = false;

      // 1) الملف المحفوظ على الجهاز (يعمل بدون إنترنت)
      final cached = await _cachedFile(id);
      if (cached != null) {
        try {
          await _player.play(DeviceFileSource(cached.path));
          started = true;
        } catch (e) {
          debugPrint('[ADHAN] cached play failed: $e');
        }
      }

      // 2) من الإنترنت (ونحمّله في الخلفية للمرات القادمة)
      if (!started) {
        try {
          await _player
              .play(UrlSource(reciter.mp3Url))
              .timeout(const Duration(seconds: 10));
          started = true;
          unawaited(precache(id));
        } catch (e) {
          debugPrint('[ADHAN] network play failed: $e');
        }
      }

      // 3) أي أذان محفوظ على الجهاز
      if (!started) {
        final any = await _anyCachedFile();
        if (any != null) {
          try {
            await _player.play(DeviceFileSource(any.path));
            started = true;
          } catch (e) {
            debugPrint('[ADHAN] any-cached play failed: $e');
          }
        }
      }

      // 4) ملف مدمج داخل التطبيق (اختياري: assets/audio/adhan_default.mp3)
      if (!started) {
        try {
          await _player.play(AssetSource('audio/adhan_default.mp3'));
          started = true;
        } catch (e) {
          debugPrint('[ADHAN] asset fallback failed: $e');
        }
      }

      if (!started) {
        _isPlaying = false;
        return false;
      }

      _isPlaying = true;
      _autoStopTimer?.cancel();
      _autoStopTimer = Timer(const Duration(minutes: 3), stop);

      return true;
    } catch (e) {
      debugPrint('Adhan play error: $e');
      _isPlaying = false;
      return false;
    }
  }

  // ✅ كتم الصوت (بدون إيقاف التشغيل)
  Future<void> mute() async {
    try {
      _isMuted = true;
      await _player.setVolume(0.0);
    } catch (e) {
      debugPrint('Adhan mute error: $e');
    }
  }

  // ✅ إلغاء الكتم
  Future<void> unmute() async {
    try {
      _isMuted = false;
      await _player.setVolume(1.0);
    } catch (e) {
      debugPrint('Adhan unmute error: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (_) {}
  }

  Future<void> resume() async {
    try {
      await _player.resume();
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      _autoStopTimer?.cancel();
      await _player.stop();
      _isPlaying = false;
      _isMuted = false;
    } catch (_) {}
  }

  Future<void> dispose() async {
    _autoStopTimer?.cancel();
    await _player.dispose();
  }
}

final adhanService = AdhanService.instance;
