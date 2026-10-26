import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../services/sheikh_audio_service.dart';

/// شريط كبير للاستماع إلى تسجيل شيخ (أذكار الصباح/المساء، الأدعية).
/// - خيار واحد أو أكثر من المقرئين (زر تبديل).
/// - ملفات متعددة تُشغَّل تلقائياً بالترتيب، مع السابق/التالي.
class SheikhAudioBanner extends StatefulWidget {
  const SheikhAudioBanner({
    super.key,
    required this.sessionKey,
    required this.title,
    required this.options,
  });

  /// مفتاح القسم (مثل adhkar:morning أو dua:all)
  final String sessionKey;

  /// عنوان الشريط (مثل: استمع إلى أذكار الصباح)
  final String title;

  /// المقرئون المتاحون (واحد أو أكثر)
  final List<AudioOption> options;

  @override
  State<SheikhAudioBanner> createState() => _SheikhAudioBannerState();
}

class _SheikhAudioBannerState extends State<SheikhAudioBanner> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _loadSelection();
  }

  Future<void> _loadSelection() async {
    final saved = await sheikhAudio.loadSelection(widget.sessionKey);
    if (!mounted) return;
    if (saved != null && widget.options.any((o) => o.id == saved)) {
      setState(() => _selectedId = saved);
    }
  }

  AudioOption get _selected {
    return widget.options.firstWhere(
      (o) => o.id == _selectedId,
      orElse: () => widget.options.first,
    );
  }

  Future<void> _select(AudioOption option) async {
    if (option.id == _selected.id) return;
    // تبديل المقرئ أثناء التشغيل → نوقف ثم يضغط المستخدم تشغيل
    if (sheikhAudio.activeKey == widget.sessionKey) {
      await sheikhAudio.stop();
    }
    setState(() => _selectedId = option.id);
    await sheikhAudio.saveSelection(widget.sessionKey, option.id);
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final ar = appState.isArabic;

    return ListenableBuilder(
      listenable: sheikhAudio,
      builder: (context, _) {
        final selected = _selected;
        final active = sheikhAudio.activeKey == widget.sessionKey;
        final playing = active && sheikhAudio.status == SheikhStatus.playing;
        final paused = active && sheikhAudio.status == SheikhStatus.paused;
        final multi = selected.assets.length > 1;
        final label = ar ? selected.label : selected.labelEn;
        final hasError = sheikhAudio.errorKey == widget.sessionKey &&
            (sheikhAudio.error ?? '').isNotEmpty;

        final part = (active && multi)
            ? (ar
                ? ' — الجزء ${sheikhAudio.index + 1} من ${sheikhAudio.total}'
                : ' — Part ${sheikhAudio.index + 1} of ${sheikhAudio.total}')
            : '';

        String subtitle;
        if (playing) {
          subtitle = (ar ? 'جارٍ التشغيل' : 'Playing') + part;
        } else if (paused) {
          subtitle = (ar ? 'متوقف مؤقتاً' : 'Paused') + part;
        } else {
          subtitle = ar ? 'بصوت $label' : 'Voice of $label';
        }

        return Container(
          padding: EdgeInsets.all(R.s(context, 12)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.gold.withValues(alpha: 0.22),
                AppColors.deepGreen.withValues(alpha: 0.92),
              ],
            ),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: playing ? 0.95 : 0.55),
              width: playing ? 2 : 1.4,
            ),
            boxShadow: playing
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.35),
                      blurRadius: 16,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // زر التشغيل الكبير
                  GestureDetector(
                    onTap: () =>
                        sheikhAudio.toggle(widget.sessionKey, selected.assets),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.5),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: Icon(
                        playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: AppColors.deepGreen,
                        size: 36,
                      ),
                    ),
                  ),
                  SizedBox(width: R.s(context, 12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: R.f(context, 15),
                            fontWeight: FontWeight.w800,
                            color: AppColors.softGold,
                          ),
                        ),
                        SizedBox(height: R.s(context, 2)),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: R.f(context, 12),
                            fontWeight: FontWeight.w600,
                            color: AppColors.cream.withValues(alpha: 0.88),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (active && multi)
                    IconButton(
                      tooltip: ar ? 'الجزء السابق' : 'Previous part',
                      onPressed: sheikhAudio.previous,
                      icon: const Icon(Icons.skip_previous_rounded),
                      color: AppColors.gold,
                      iconSize: 30,
                    ),
                  if (active && multi)
                    IconButton(
                      tooltip: ar ? 'الجزء التالي' : 'Next part',
                      onPressed: sheikhAudio.next,
                      icon: const Icon(Icons.skip_next_rounded),
                      color: AppColors.gold,
                      iconSize: 30,
                    ),
                  if (active)
                    IconButton(
                      tooltip: ar ? 'إيقاف' : 'Stop',
                      onPressed: sheikhAudio.stop,
                      icon: const Icon(Icons.stop_circle_rounded),
                      color: const Color(0xFFFF8A80),
                      iconSize: 34,
                    ),
                ],
              ),

              // شريط التقدّم
              if (active)
                _ProgressBar(
                  key: ValueKey('${widget.sessionKey}-${sheikhAudio.index}'),
                  format: _fmt,
                ),

              // اختيار المقرئ
              if (widget.options.length > 1) ...[
                SizedBox(height: R.s(context, 8)),
                Row(
                  children: [
                    for (final o in widget.options)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: GestureDetector(
                            onTap: () => _select(o),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: o.id == selected.id
                                    ? AppColors.gold
                                    : Colors.black.withValues(alpha: 0.25),
                                border: Border.all(
                                  color: AppColors.gold
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              child: Text(
                                ar ? o.label : o.labelEn,
                                style: TextStyle(
                                  fontSize: R.f(context, 13),
                                  fontWeight: FontWeight.w800,
                                  color: o.id == selected.id
                                      ? AppColors.deepGreen
                                      : AppColors.cream,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],

              if (hasError)
                Padding(
                  padding: EdgeInsets.only(top: R.s(context, 6)),
                  child: Text(
                    sheikhAudio.error!,
                    style: TextStyle(
                      fontSize: R.f(context, 12),
                      height: 1.5,
                      color: const Color(0xFFFFB4A9),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// شريط تقدّم الملف الحالي (يسحبه المستخدم للتقديم/التأخير)
class _ProgressBar extends StatefulWidget {
  const _ProgressBar({super.key, required this.format});

  final String Function(Duration) format;

  @override
  State<_ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<_ProgressBar> {
  Duration _pos = Duration.zero;
  Duration _dur = Duration.zero;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration?>? _durSub;

  @override
  void initState() {
    super.initState();
    final p = sheikhAudio.player;
    _posSub = p.positionStream.listen((v) {
      if (mounted) setState(() => _pos = v);
    });
    _durSub = p.durationStream.listen((v) {
      if (mounted) setState(() => _dur = v ?? Duration.zero);
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final max = _dur.inMilliseconds.toDouble();
    final value = _pos.inMilliseconds
        .toDouble()
        .clamp(0.0, max > 0 ? max : 1.0)
        .toDouble();

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            activeTrackColor: AppColors.gold,
            inactiveTrackColor: AppColors.gold.withValues(alpha: 0.25),
            thumbColor: AppColors.gold,
          ),
          child: Slider(
            min: 0,
            max: max > 0 ? max : 1.0,
            value: value,
            onChanged: max > 0
                ? (v) => sheikhAudio.seek(Duration(milliseconds: v.round()))
                : null,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.format(_pos),
              style: TextStyle(
                fontSize: R.f(context, 11),
                color: AppColors.cream.withValues(alpha: 0.8),
              ),
            ),
            Text(
              widget.format(_dur),
              style: TextStyle(
                fontSize: R.f(context, 11),
                color: AppColors.cream.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
