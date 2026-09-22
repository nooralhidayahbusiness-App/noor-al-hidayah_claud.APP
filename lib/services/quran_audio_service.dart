import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../core/reciter_prefs.dart';
import '../models/quran.dart';
import '../models/reciter.dart';
import 'audio_download_service.dart';

/// Where playback currently is: which surah and which verse.
class PlaybackSpot {
  const PlaybackSpot(this.surah, this.ayah);
  final int surah;
  final int ayah;
}

/// Plays a surah verse by verse and reports which verse is currently playing.
class QuranAudioService {
  QuranAudioService._();
  static final QuranAudioService instance = QuranAudioService._();

  final AudioPlayer player = AudioPlayer();
  final ValueNotifier<PlaybackSpot?> nowPlaying = ValueNotifier(null);
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);
  final ValueNotifier<bool> isBuffering = ValueNotifier(false);

  QuranSurah? _surah;
  Reciter? _reciter;
  List<int> _ayahNumbers = [];
  StreamSubscription<int?>? _indexSub;
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

    final sources = <AudioSource>[];
    for (final number in _ayahNumbers) {
      final local = await AudioDownloadService.localPathIfExists(
        reciter.id,
        surah.number,
        number,
      );
      final uri = local != null
          ? Uri.file(local)
          : Uri.parse(reciter.ayahUrl(surah.number, number));
      sources.add(AudioSource.uri(uri));
    }
    final startIndex = math.max(0, _ayahNumbers.indexOf(startAyah));

    await _indexSub?.cancel();
    await _playingSub?.cancel();
    await _stateSub?.cancel();

    isBuffering.value = true;
    try {
      await player.setAudioSources(sources, initialIndex: startIndex);
    } finally {
      isBuffering.value = false;
    }

    _indexSub = player.currentIndexStream.listen((index) {
      if (index == null || _surah == null) return;
      nowPlaying.value = PlaybackSpot(_surah!.number, _ayahNumbers[index]);
    });
    _playingSub = player.playingStream.listen((p) => isPlaying.value = p);
    _stateSub = player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed && !reciterPrefs.autoAdvance) {
        player.pause();
      }
    });

    nowPlaying.value = PlaybackSpot(surah.number, startAyah);
    await player.play();
  }

  Future<void> playFrom(
    QuranSurah surah,
    QuranAyah ayah,
    Reciter reciter,
  ) =>
      playSurah(surah, reciter, startAyah: ayah.number);

  Future<void> toggle() async {
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }
  }

  Future<void> seekBy(Duration delta) async {
    final duration = player.duration ?? Duration.zero;
    var position = player.position + delta;
    if (position < Duration.zero) position = Duration.zero;
    if (position > duration) position = duration;
    await player.seek(position);
  }

  Future<void> stop() async {
    await player.stop();
    nowPlaying.value = null;
    _surah = null;
  }
}

final QuranAudioService quranAudio = QuranAudioService.instance;
