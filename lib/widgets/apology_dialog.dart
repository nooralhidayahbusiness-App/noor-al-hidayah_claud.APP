import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/fonts.dart';
import '../core/theme.dart';
import 'auth_widgets.dart';
import 'glass_card.dart';

/// Blurred "sorry" box telling the user that an option does not work in the
/// current mode. It closes with the gold OK button, the red X, or a tap outside.
Future<void> showApologyDialog(BuildContext context, String option) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'close',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (dialogContext, animation, secondaryAnimation) =>
        _ApologyBox(option: option),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _ApologyBox extends StatelessWidget {
  const _ApologyBox({required this.option});

  final String option;

  @override
  Widget build(BuildContext context) {
    void close() => Navigator.of(context).pop();
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: close,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withValues(alpha: 0.35),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: GestureDetector(
              onTap: () {},
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: ListenableBuilder(
                  listenable: appState,
                  builder: (context, _) {
                    final title = appState.tr('apologyTitle');
                    return Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 34),
                          child: GlassCard(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 22),
                                Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: brandStyle(
                                    title,
                                    fontSize: 30,
                                    color: AppColors.softGold,
                                    shadows: [
                                      Shadow(
                                        color: AppColors.gold
                                            .withValues(alpha: 0.5),
                                        blurRadius: 14,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  appState
                                      .tr('apologyMsg')
                                      .replaceAll('{option}', option),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    height: 1.7,
                                    color: AppColors.cream,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  appState.tr('apologyTry'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.7,
                                    color: AppColors.gold,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                GoldButton(
                                  label: appState.tr('apologyOk'),
                                  onPressed: close,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(top: 0, child: _PulsingX(onTap: close)),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Red glowing X in a circle.
class _PulsingX extends StatefulWidget {
  const _PulsingX({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_PulsingX> createState() => _PulsingXState();
}

class _PulsingXState extends State<_PulsingX>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          return Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFC62828)],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.85),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF3B30).withValues(alpha: 0.45 + 0.4 * t),
                  blurRadius: 12 + 16 * t,
                  spreadRadius: 1 + 3 * t,
                ),
              ],
            ),
            child: child,
          );
        },
        child: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
      ),
    );
  }
}
