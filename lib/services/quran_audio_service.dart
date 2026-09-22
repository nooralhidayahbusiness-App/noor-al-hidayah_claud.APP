import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../core/reciter_prefs.dart';
import '../models/quran.dart';
import '../models/reciter.dart';
import 'audio_download_service.dart';

class PlaybackSpot {
  const PlaybackSpot(this.surah, this.ayah);
  final int surah;
  final int ayah;
}

/// Plays a surah one verse-file at a time. A brand-new AudioPlayer is
/// created for every verse (instead of reusing one and swapping its
/// source), which avoids a browser quirk where the previous audio keeps
/// playing even after the source is changed.
class QuranAudioService {
  QuranAudioService._();
  static final QuranAudioService instance = QuranAudioService._();

  AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;

  final ValueNotifier<PlaybackSpot?> nowPlaying = ValueNotifier(null);
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);
  final ValueNotifier<bool> isBuffering = ValueNotifier(false);
  final ValueNotifier<Duration> sessionElapsed = ValueNotifier(Duration.zero);
  final ValueNotifier<String> currentUrl = ValueNotifier('');

  QuranSurah? _surah;
  Reciter? _reciter;
  List<int> _ayahNumbers = [];
  int _index = 0;
  Duration _elapsedBeforeCurrent = Duration.zero;
  int _playToken = 0;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<ProcessingState>? _stateSub;

  bool get isActive => nowPlaying.value != null;
  QuranSurah? get currentSurah => _surah;
  Reciter? get currentReciter => _reciter;

  Future<void> playSurah(
    QuranSurah surah,
    Reciter reciter, {
    int startAyah = 1,
  }) async {
    _surah = surah;
    _reciter = reciter;
    _ayahNumbers = [for (final a in surah.ayahs) a.number];
    _index = math.max(0, _ayahNumbers.indexOf(startAyah));
    _elapsedBeforeCurrent = Duration.zero;
    sessionElapsed.value = Duration.zero;
    final token = ++_playToken;
    await _loadAndPlay(token);
  }

  Future<void> playFrom(QuranSurah surah, QuranAyah ayah, Reciter reciter) =>
      playSurah(surah, reciter, startAyah: ayah.number);

  Future<void> _loadAndPlay(int token) async {
    final surah = _surah;
    final reciter = _reciter;
    if (surah == null || reciter == null) return;
    final number = _ayahNumbers[_index];

    // Throw away the old player entirely: a brand-new one guarantees a
    // fresh underlying audio element, with no leftover state.
    final oldPlayer = _player;
    await _positionSub?.cancel();
    await _playingSub?.cancel();
    await _stateSub?.cancel();
    _player = AudioPlayer();
    unawaited(oldPlayer.dispose());

    final local = await AudioDownloadService.localPathIfExists(
      reciter.id,
      surah.number,
      number,
    );
    if (token != _playToken) return;
    final uri = local != null
        ? Uri.file(local)
        : Uri.parse(reciter.ayahUrl(surah.number, number));
    currentUrl.value = uri.toString();

    isBuffering.value = true;
    try {
      await _player.setAudioSource(AudioSource.uri(uri));
    } catch (_) {
      isBuffering.value = false;
      return;
    }
    if (token != _playToken) return;
    isBuffering.value = false;

    nowPlaying.value = PlaybackSpot(surah.number, number);

    _positionSub = _player.positionStream.listen((pos) {
      sessionElapsed.value = _elapsedBeforeCurrent + pos;
    });
    _playingSub = _player.playingStream.listen((p) => isPlaying.value = p);
    _stateSub = _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _onAyahCompleted(token);
      }
    });

    await _player.play();
  }

  Future<void> _onAyahCompleted(int token) async {
    if (token != _playToken) return;
    _elapsedBeforeCurrent += _player.duration ?? Duration.zero;
    if (!reciterPrefs.autoAdvance) {
      await _player.pause();
      return;
    }
    if (_index + 1 >= _ayahNumbers.length) return;
    _index += 1;
    await _loadAndPlay(token);
  }

  Future<void> toggle() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seekBy(Duration delta) async {
    final duration = _player.duration ?? Duration.zero;
    var position = _player.position + delta;
    if (position < Duration.zero) position = Duration.zero;
    if (position > duration) position = duration;
    await _player.seek(position);
  }

  Future<void> stop() async {
    _playToken++;
    await _player.stop();
    nowPlaying.value = null;
    _surah = null;
  }
}

final QuranAudioService quranAudio = QuranAudioService.instance;
