import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../core/theme_state.dart';
import '../data/adhan_reciters.dart';
import '../data/adhan_timings.dart';
import '../services/adhan_service.dart';
import '../widgets/glass_card.dart';
import 'qibla_screen.dart';

class AdhanScreen extends StatefulWidget {
  const AdhanScreen({
    super.key,
    required this.prayerKey,
    required this.prayerTime,
  });

  /// 'fajr' | 'dhuhr' | 'asr' | 'maghrib' | 'isha'
  final String prayerKey;
  final DateTime prayerTime;

  @override
  State<AdhanScreen> createState() => _AdhanScreenState();
}

class _AdhanScreenState extends State<AdhanScreen>
    with TickerProviderStateMixin {
  bool _playing = false;
  int _currentPhraseIndex = 0;
  Timer? _phraseTimer;

  late final List<AdhanPhrase> _phrases;

  @override
  void initState() {
    super.initState();
    _phrases = AdhanTimings.forReciter(adhanService.currentReciterId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAdhan();
    });
  }

  @override
  void dispose() {
    _phraseTimer?.cancel();
    adhanService.stop();
    super.dispose();
  }

  Future<void> _startAdhan() async {
    final ok = await adhanService.play();
    if (!mounted) return;
    setState(() => _playing = ok);
    if (ok) _startPhraseAnimation();
  }

  void _startPhraseAnimation() {
    _phraseTimer?.cancel();
    _currentPhraseIndex = 0;

    void nextPhrase() {
      if (!mounted) return;
      if (_currentPhraseIndex >= _phrases.length - 1) return;
      final current = _phrases[_currentPhraseIndex];
      _phraseTimer = Timer(current.duration, () {
        if (!mounted) return;
        setState(() => _currentPhraseIndex++);
        nextPhrase();
      });
    }

    nextPhrase();
  }

  Future<void> _stopAndClose({required bool prayed}) async {
    await adhanService.stop();
    if (!mounted) return;
    if (prayed) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.deepGreen,
          content: Text(
            appState.tr('adhanPrayedThanks'),
            style: const TextStyle(color: AppColors.cream),
          ),
        ),
      );
    }
    Navigator.of(context).pop();
  }

  Future<void> _snooze() async {
    await adhanService.stop();
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.deepGreen,
        content: Text(
          appState.tr('adhanSnoozeInfo'),
          style: const TextStyle(color: AppColors.cream),
        ),
      ),
    );
  }

  Future<void> _togglePlay() async {
    if (_playing) {
      await adhanService.pause();
      if (!mounted) return;
      setState(() => _playing = false);
      _phraseTimer?.cancel();
    } else {
      await adhanService.resume();
      if (!mounted) return;
      setState(() => _playing = true);
      _startPhraseAnimation();
    }
  }

  void _openQibla() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const QiblaScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeState,
      builder: (context, _) {
        final currentBg = themeState.palette;
        final bgImage = _getAdhanBgImage();

        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              // خلفية الأذان
              if (bgImage != null)
                Image.asset(
                  bgImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _fallbackBg(currentBg),
                )
              else
                _fallbackBg(currentBg),

              // طبقة تعتيم
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.55),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // ===== الهيدر =====
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        R.s(context, 6),
                        R.s(context, 6),
                        R.s(context, 16),
                        0,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => _stopAndClose(prayed: false),
                            tooltip: appState.tr('close'),
                            color: AppColors.softGold,
                            iconSize: R.s(context, 24),
                            icon: const Icon(Icons.close_rounded),
                          ),
                          const Spacer(),
                          Text(
                            appState.tr('adhanTitle'),
                            style: TextStyle(
                              fontSize: R.f(context, 14),
                              fontWeight: FontWeight.w700,
                              color: AppColors.softGold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(width: R.s(context, 40)),
                        ],
                      ),
                    ),

                    // ===== اسم الصلاة + الوقت =====
                    SizedBox(height: R.s(context, 10)),
                    Text(
                      appState.tr(widget.prayerKey),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: R.f(context, 48),
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                        height: 1.1,
                        shadows: [
                          Shadow(
                            color: AppColors.gold.withValues(alpha: 0.7),
                            blurRadius: 24,
                          ),
                          const Shadow(
                            color: Color(0xCC000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: R.s(context, 4)),
                    Text(
                      _formatTime(widget.prayerTime),
                      style: TextStyle(
                        fontSize: R.f(context, 16),
                        color: AppColors.cream.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const Spacer(),

                    // ===== النص المتحرك =====
                    _AnimatedAdhanText(
                      phrases: _phrases,
                      currentIndex: _currentPhraseIndex,
                    ),

                    const Spacer(),

                    // ===== المؤذن (مُحدَّث) =====
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: R.s(context, 16)),
                      child: GlassCard(
                        ornament: false,
                        child: Row(
                          children: [
                            Container(
                              width: R.s(context, 36),
                              height: R.s(context, 36),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.gold.withValues(alpha: 0.15),
                                border: Border.all(
                                  color:
                                      AppColors.gold.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Icon(
                                Icons.record_voice_over_rounded,
                                color: AppColors.gold,
                                size: R.s(context, 18),
                              ),
                            ),
                            SizedBox(width: R.s(context, 10)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appState.isArabic
                                        ? _currentReciterNameAr()
                                        : _currentReciterNameEn(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: R.f(context, 13),
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.softGold,
                                    ),
                                  ),
                                  if (_currentReciterCountry().isNotEmpty) ...[
                                    SizedBox(height: R.s(context, 2)),
                                    Text(
                                      _currentReciterCountry(),
                                      style: TextStyle(
                                        fontSize: R.f(context, 10.5),
                                        color: AppColors.cream
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: R.s(context, 10)),

                    // ===== الأزرار =====
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: R.s(context, 16)),
                      child: Row(
                        children: [
                          // زر القبلة
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.explore_rounded,
                              label: appState.tr('qibla'),
                              onTap: _openQibla,
                            ),
                          ),
                          SizedBox(width: R.s(context, 8)),
                          // زر الإيقاف المؤقت/التشغيل
                          Expanded(
                            child: _ActionButton(
                              icon: _playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              label: _playing
                                  ? appState.tr('pause')
                                  : appState.tr('play'),
                              onTap: _togglePlay,
                            ),
                          ),
                          SizedBox(width: R.s(context, 8)),
                          // زر التأجيل
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.snooze_rounded,
                              label: appState.tr('adhanSnooze'),
                              onTap: _snooze,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: R.s(context, 10)),

                    // ===== زر "صليت" =====
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: R.s(context, 16)),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _stopAndClose(prayed: true),
                          icon: Icon(
                            Icons.check_circle_rounded,
                            size: R.s(context, 22),
                          ),
                          label: Text(
                            appState.tr('adhanPrayed'),
                            style: TextStyle(
                              fontSize: R.f(context, 15),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.deepGreen,
                            minimumSize:
                                Size.fromHeight(R.s(context, 54)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 6,
                            shadowColor: AppColors.gold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: R.s(context, 20)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _fallbackBg(dynamic palette) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.accent, palette.accentDark],
        ),
      ),
    );
  }

  String? _getAdhanBgImage() {
    final id = themeState.adhanBackgroundId;
    if (id == 'default' || id.isEmpty) return null;
    return 'assets/images/adhan_backgrounds/$id.png';
  }

  // ===== اسم المؤذن (مُحدَّث) =====
  String _currentReciterNameAr() {
    final r = adhanReciterById(adhanService.currentReciterId);
    return r?.nameAr ?? 'الأذان الأساسي';
  }

  String _currentReciterNameEn() {
    final r = adhanReciterById(adhanService.currentReciterId);
    return r?.nameEn ?? 'Default Adhan';
  }

  String _currentReciterCountry() {
    final r = adhanReciterById(adhanService.currentReciterId);
    if (r == null) return '';
    return appState.isArabic ? r.countryAr : r.countryEn;
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final isPm = h >= 12;
    var hour12 = h % 12;
    if (hour12 == 0) hour12 = 12;
    final suffix = appState.isArabic
        ? (isPm ? 'م' : 'ص')
        : (isPm ? 'PM' : 'AM');
    return '$hour12:$m $suffix';
  }
}

class _AnimatedAdhanText extends StatelessWidget {
  const _AnimatedAdhanText({
    required this.phrases,
    required this.currentIndex,
  });

  final List<AdhanPhrase> phrases;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    if (phrases.isEmpty || currentIndex >= phrases.length) {
      return const SizedBox.shrink();
    }

    final current = phrases[currentIndex];
    final previous = currentIndex > 0 ? phrases[currentIndex - 1] : null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.s(context, 20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // السطر السابق (باهت)
          if (previous != null)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: 0.4,
              child: Text(
                appState.isArabic ? previous.textAr : previous.textEn,
                textAlign: TextAlign.center,
                textDirection: appState.isArabic
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                style: GoogleFonts.amiri(
                  fontSize: R.f(context, 22),
                  color: AppColors.softGold.withValues(alpha: 0.7),
                  height: 1.6,
                ),
              ),
            ),
          SizedBox(height: R.s(context, 12)),
          // السطر الحالي (بارز + توهج)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Container(
              key: ValueKey(currentIndex),
              padding: EdgeInsets.symmetric(
                horizontal: R.s(context, 16),
                vertical: R.s(context, 8),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.black.withValues(alpha: 0.35),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.35),
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                appState.isArabic ? current.textAr : current.textEn,
                textAlign: TextAlign.center,
                textDirection: appState.isArabic
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                style: GoogleFonts.amiri(
                  fontSize: R.f(context, 30),
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                  height: 1.5,
                  shadows: [
                    Shadow(
                      color: AppColors.gold.withValues(alpha: 0.7),
                      blurRadius: 12,
                    ),
                    const Shadow(
                      color: Color(0xCC000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: R.s(context, 10)),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.gold, size: R.s(context, 24)),
            SizedBox(height: R.s(context, 3)),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: R.f(context, 10.5),
                fontWeight: FontWeight.w600,
                color: AppColors.cream,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
