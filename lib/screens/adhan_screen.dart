import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../core/theme_state.dart';
import '../data/adhan_timings.dart';
import '../data/adhkar.dart';
import '../services/adhan_service.dart';
import 'adhkar_detail_screen.dart';
import 'adhkar_screen.dart';
import 'qibla_screen.dart';

class AdhanScreen extends StatefulWidget {
  const AdhanScreen({
    super.key,
    required this.prayerKey,
    required this.prayerTime,
  });

  final String prayerKey;
  final DateTime prayerTime;

  @override
  State<AdhanScreen> createState() => _AdhanScreenState();
}

class _AdhanScreenState extends State<AdhanScreen>
    with TickerProviderStateMixin {
  bool _prayed = false;
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
    if (ok) _startPhraseAnimation();
  }

  void _startPhraseAnimation() {
    _phraseTimer?.cancel();
    _currentPhraseIndex = 0;

    void nextPhrase() {
      if (!mounted) return;
      if (_currentPhraseIndex >= _phrases.length - 1) return;
      final current = _phrases[_currentPhraseIndex];
      final slowDuration = Duration(
        milliseconds: (current.duration.inMilliseconds * 1.4).toInt(),
      );
      _phraseTimer = Timer(slowDuration, () {
        if (!mounted) return;
        setState(() => _currentPhraseIndex++);
        nextPhrase();
      });
    }

    nextPhrase();
  }

  Future<void> _onPrayedPressed() async {
    if (!_prayed) {
      HapticFeedback.mediumImpact();
      setState(() => _prayed = true);
    } else {
      await adhanService.stop();
      if (!mounted) return;
      Navigator.of(context).pop();
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
  }

  Future<void> _toggleMute() async {
    if (adhanService.isMuted) {
      await adhanService.unmute();
    } else {
      await adhanService.mute();
    }
    if (mounted) setState(() {});
  }

  Future<void> _stopAndClose() async {
    await adhanService.stop();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _openQibla() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const QiblaScreen()),
    );
  }

  void _openAfterPrayerAdhkar() {
    AdhkarCategory? target;
    try {
      target = kAdhkarCategories.firstWhere(
        (c) =>
            c.id.toLowerCase().contains('after') ||
            c.id.toLowerCase().contains('prayer') ||
            c.nameAr.contains('بعد الصلاة'),
      );
    } catch (_) {
      target = null;
    }

    if (target != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AdhkarDetailScreen(category: target!),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AdhkarScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeState,
      builder: (context, _) {
        final currentBg = themeState.palette;
        final bgImage = _getAdhanBgImage();

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            await _stopAndClose();
          },
          child: Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                if (bgImage != null)
                  Image.asset(
                    bgImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _fallbackBg(currentBg),
                  )
                else
                  _fallbackBg(currentBg),

                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.65),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          R.s(context, 6),
                          R.s(context, 6),
                          R.s(context, 6),
                          0,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _stopAndClose,
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
                            const Spacer(),
                            IconButton(
                              onPressed: _toggleMute,
                              color: adhanService.isMuted
                                  ? AppColors.cream.withValues(alpha: 0.5)
                                  : AppColors.gold,
                              iconSize: R.s(context, 24),
                              icon: Icon(
                                adhanService.isMuted
                                    ? Icons.volume_off_rounded
                                    : Icons.volume_up_rounded,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: R.s(context, 12)),

                      _GlowWrapper(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              appState.tr(widget.prayerKey),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.amiri(
                                fontSize: R.f(context, 72),
                                fontWeight: FontWeight.w700,
                                color: AppColors.gold,
                                height: 1.1,
                                shadows: [
                                  Shadow(
                                    color: AppColors.gold
                                        .withValues(alpha: 0.9),
                                    blurRadius: 40,
                                  ),
                                  const Shadow(
                                    color: Color(0xDD000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: R.s(context, 4)),
                            Text(
                              _formatTime(widget.prayerTime),
                              style: TextStyle(
                                fontSize: R.f(context, 26),
                                color: AppColors.softGold,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                shadows: [
                                  Shadow(
                                    color: AppColors.gold
                                        .withValues(alpha: 0.7),
                                    blurRadius: 16,
                                  ),
                                  const Shadow(
                                    color: Color(0xCC000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: R.s(context, 14)),

                      _AnimatedAdhanText(
                        phrases: _phrases,
                        currentIndex: _currentPhraseIndex,
                      ),

                      const Spacer(),

                      _RippleButton(
                        prayed: _prayed,
                        onTap: _onPrayedPressed,
                        icon: _prayed
                            ? Icons.check_circle_rounded
                            : Icons.check_circle_outline_rounded,
                        label: _prayed
                            ? appState.tr('adhanPrayedDone')
                            : appState.tr('adhanPrayed'),
                      ),

                      const Spacer(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _CircleActionButton(
                            icon: Icons.explore_rounded,
                            label: appState.tr('qibla'),
                            onTap: _openQibla,
                          ),
                          SizedBox(width: R.s(context, 36)),
                          _CircleActionButton(
                            icon: Icons.menu_book_rounded,
                            label: appState.tr('adhkarAfterPrayer'),
                            onTap: _openAfterPrayerAdhkar,
                          ),
                        ],
                      ),

                      SizedBox(height: R.s(context, 20)),
                    ],
                  ),
                ),
              ],
            ),
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

class _GlowWrapper extends StatefulWidget {
  const _GlowWrapper({required this.child});

  final Widget child;

  @override
  State<_GlowWrapper> createState() => _GlowWrapperState();
}

class _GlowWrapperState extends State<_GlowWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3500),
  )..repeat();

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: R.s(context, 260),
      height: R.s(context, 160),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _glow,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: List.generate(4, (i) {
                  final t = (_glow.value + (i / 4.0)) % 1.0;
                  final opacity = (1 - t) * 0.45;
                  final size = R.s(context, 180) + (t * R.s(context, 100));

                  return Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Container(
                      width: size,
                      height: size * 0.7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.9),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.35),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          widget.child,
        ],
      ),
    );
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
          if (previous != null)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              opacity: 0.4,
              child: Text(
                appState.isArabic ? previous.textAr : previous.textEn,
                textAlign: TextAlign.center,
                textDirection: appState.isArabic
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                style: GoogleFonts.amiri(
                  fontSize: R.f(context, 26),
                  color: AppColors.softGold.withValues(alpha: 0.7),
                  height: 1.6,
                ),
              ),
            ),
          SizedBox(height: R.s(context, 14)),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
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
                horizontal: R.s(context, 24),
                vertical: R.s(context, 14),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withValues(alpha: 0.4),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.45),
                    blurRadius: 30,
                    spreadRadius: 2,
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
                  fontSize: R.f(context, 40),
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                  height: 1.5,
                  shadows: [
                    Shadow(
                      color: AppColors.gold.withValues(alpha: 0.8),
                      blurRadius: 16,
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

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = R.s(context, 90);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.5),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.7),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: AppColors.gold,
              size: R.s(context, 38),
            ),
          ),
          SizedBox(height: R.s(context, 6)),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.softGold,
              fontSize: R.f(context, 12),
              fontWeight: FontWeight.w700,
              shadows: const [
                Shadow(color: Color(0xCC000000), blurRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RippleButton extends StatefulWidget {
  const _RippleButton({
    required this.prayed,
    required this.onTap,
    required this.icon,
    required this.label,
  });

  final bool prayed;
  final VoidCallback onTap;
  final IconData icon;
  final String label;

  @override
  State<_RippleButton> createState() => _RippleButtonState();
}

class _RippleButtonState extends State<_RippleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ripple = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _ripple.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final btnW = R.s(context, 240);
    final btnH = R.s(context, 58);
    final radius = btnH / 2;

    final activeColor = widget.prayed ? Colors.grey : AppColors.gold;

    return SizedBox(
      width: btnW * 1.6,
      height: btnH * 1.6,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: _ripple,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: List.generate(3, (i) {
                  final t = (_ripple.value + (i / 3.0)) % 1.0;
                  final opacity = (1 - t) * 0.65;
                  final scale = 1 + t * 0.55;

                  return Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: btnW,
                        height: btnH,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(radius),
                          border: Border.all(
                            color: activeColor.withValues(alpha: 0.9),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: btnW,
              height: btnH,
              decoration: BoxDecoration(
                color: widget.prayed
                    ? Colors.grey.withValues(alpha: 0.45)
                    : AppColors.gold,
                borderRadius: BorderRadius.circular(radius),
                boxShadow: widget.prayed
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.75),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                      ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.prayed
                        ? AppColors.cream.withValues(alpha: 0.6)
                        : AppColors.deepGreen,
                    size: R.s(context, 24),
                  ),
                  SizedBox(width: R.s(context, 8)),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: R.f(context, 16),
                      fontWeight: FontWeight.w900,
                      color: widget.prayed
                          ? AppColors.cream.withValues(alpha: 0.65)
                          : AppColors.deepGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
