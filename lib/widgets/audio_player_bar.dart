import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/reciter_prefs.dart';
import '../core/theme.dart';
import '../models/quran.dart';
import '../services/audio_download_service.dart';
import '../services/quran_audio_service.dart';
import 'auth_widgets.dart';
import 'reciter_picker.dart';

String _mmss(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Bottom mini player, shown whenever a reciter is active.
class AudioPlayerBar extends StatelessWidget {
  const AudioPlayerBar({super.key, required this.data});

  final QuranData data;

  Future<void> _download(BuildContext context) async {
    final surah = quranAudio.currentSurah;
    final reciter = quranAudio.currentReciter;
    if (surah == null || reciter == null) return;
    final already =
        await AudioDownloadService.isDownloaded(reciter.id, surah.number, surah.count);
    if (!context.mounted) return;
    if (already) {
      showAuthMessage(context, appState.tr('alreadyDownloaded'));
      return;
    }
    final progress = ValueNotifier<double>(0);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.deepGreen,
        title: Text(
          appState.tr('downloading'),
          style: const TextStyle(color: AppColors.softGold),
        ),
        content: ValueListenableBuilder<double>(
          valueListenable: progress,
          builder: (context, value, _) => LinearProgressIndicator(
            value: value,
            color: AppColors.gold,
            backgroundColor: AppColors.gold.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
    try {
      await AudioDownloadService.downloadSurah(
        reciter,
        surah.number,
        surah.count,
        (done, total) => progress.value = done / total,
      );
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        showAuthMessage(context, appState.tr('downloadDone'));
      }
    } catch (_) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        showAuthMessage(context, appState.tr('downloadFailed'), error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: quranAudio.nowPlaying,
      builder: (context, spot, _) {
        if (spot == null) return const SizedBox.shrink();
        return ListenableBuilder(
          listenable: Listenable.merge([appState, reciterPrefs]),
          builder: (context, _) {
            final surah = data.surah(spot.surah);
            final reciter = quranAudio.currentReciter;
            final surahLabel = appState.isArabic ? surah.nameAr : surah.nameEn;
            return Container(
              padding: EdgeInsets.fromLTRB(
                14,
                8,
                14,
                8 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: AppColors.deepGreen.withValues(alpha: 0.96),
                border: Border(
                  top: BorderSide(color: AppColors.gold.withValues(alpha: 0.4)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final picked = await showReciterPicker(context);
                          if (picked != null) {
                            await reciterPrefs.setReciter(picked.id);
                            quranAudio.playFrom(
                              surah,
                              surah.ayahs[spot.ayah - 1],
                              picked,
                            );
                          }
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.gold.withValues(alpha: 0.14),
                            border: Border.all(color: AppColors.gold),
                          ),
                          child: const Icon(
                            Icons.mic_rounded,
                            color: AppColors.gold,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appState.isArabic
                                  ? (reciter?.nameAr ?? '')
                                  : (reciter?.nameEn ?? ''),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gold,
                              ),
                            ),
                            Text(
                              '$surahLabel • ${appState.tr('ayahWord')} ${spot.ayah}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.cream.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: appState.tr('downloadReciter'),
                        onPressed: () => _download(context),
                        icon: const Icon(
                          Icons.download_rounded,
                          color: AppColors.softGold,
                          size: 20,
                        ),
                      ),
                      IconButton(
                        tooltip: appState.tr('back'),
                        onPressed: quranAudio.stop,
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.softGold,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  StreamBuilder<Duration>(
                    stream: quranAudio.player.positionStream,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      final duration =
                          quranAudio.player.duration ?? Duration.zero;
                      final max = duration.inMilliseconds > 0
                          ? duration.inMilliseconds.toDouble()
                          : 1.0;
                      final value = position.inMilliseconds
                          .clamp(0, max.toInt())
                          .toDouble();
                      return Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                              activeTrackColor: AppColors.gold,
                              inactiveTrackColor:
                                  AppColors.gold.withValues(alpha: 0.25),
                              thumbColor: AppColors.gold,
                            ),
                            child: Slider(
                              min: 0,
                              max: max,
                              value: value,
                              onChanged: (v) => quranAudio.player
                                  .seek(Duration(milliseconds: v.toInt())),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _mmss(position),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.cream
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                                Text(
                                  _mmss(duration),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.cream
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ModeChip(),
                      const Spacer(),
                      IconButton(
                        onPressed: () =>
                            quranAudio.seekBy(const Duration(seconds: -10)),
                        icon: const Icon(
                          Icons.replay_10_rounded,
                          color: AppColors.softGold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      ValueListenableBuilder<bool>(
                        valueListenable: quranAudio.isPlaying,
                        builder: (context, playing, _) {
                          return GestureDetector(
                            onTap: quranAudio.toggle,
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [AppColors.softGold, AppColors.gold],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.gold.withValues(alpha: 0.5),
                                    blurRadius: 14,
                                  ),
                                ],
                              ),
                              child: Icon(
                                playing
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: AppColors.deepGreen,
                                size: 30,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: () =>
                            quranAudio.seekBy(const Duration(seconds: 10)),
                        icon: const Icon(
                          Icons.forward_10_rounded,
                          color: AppColors.softGold,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 38),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip();

  @override
  Widget build(BuildContext context) {
    final auto = reciterPrefs.autoAdvance;
    return GestureDetector(
      onTap: () => reciterPrefs.setAutoAdvance(!auto),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.gold.withValues(alpha: 0.12),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
        ),
        child: Text(
          auto ? appState.tr('fullSurah') : appState.tr('ayahByAyah'),
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppColors.gold,
          ),
        ),
      ),
    );
  }
}
