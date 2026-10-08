import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/adhan_reciters.dart';

/// خدمة تشغيل الأذان + إدارة الصوت.
class AdhanService {
  AdhanService._();
  static final AdhanService instance = AdhanService._();

  final AudioPlayer _player = AudioPlayer();
  String _currentReciterId = 'default';
  bool _isPlaying = false;
  Timer? _autoStopTimer;
  bool _contextSet = false;

  bool get isPlaying => _isPlaying;
  String get currentReciterId => _currentReciterId;

  Stream<PlayerState> get stateStream => _player.onPlayerStateChanged;
  Stream<Duration> get positionStream => _player.onPositionChanged;
  Stream<void> get completeStream => _player.onPlayerComplete;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentReciterId = prefs.getString('active_adhan_reciter') ?? 'default';
    await _setupAudioContext();
  }

  /// ✅ ضبط AudioContext للأذان (نمط منبّه — صوت عالٍ + خلفية)
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
            options: const {
              AVAudioSessionOptions.mixWithOthers,
            },
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_adhan_reciter', id);
  }

  /// يشغل الأذان للمؤذن المختار.
  Future<bool> play({String? reciterId}) async {
    try {
      await _setupAudioContext();

      final id = reciterId ?? _currentReciterId;
      final reciter = adhanReciterById(id) ?? kAdhanReciters.first;

      // أوقف أي تشغيل سابق
      await _player.stop();

      // اضبط النمط
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setVolume(1.0);

      // شغّل الرابط
      await _player.play(UrlSource(reciter.mp3Url));

      _isPlaying = true;

      // إيقاف تلقائي بعد 3 دقائق (احتياط)
      _autoStopTimer?.cancel();
      _autoStopTimer = Timer(const Duration(minutes: 3), () {
        stop();
      });

      return true;
    } catch (e) {
      debugPrint('Adhan play error: $e');
      _isPlaying = false;
      return false;
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
    } catch (_) {}
  }

  Future<void> dispose() async {
    _autoStopTimer?.cancel();
    await _player.dispose();
  }
}

final adhanService = AdhanService.instance;
