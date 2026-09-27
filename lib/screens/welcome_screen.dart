import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import 'register_screen.dart';
import 'login_screen.dart';
import '../core/navigation.dart';
import '../core/fonts.dart';
import '../core/theme.dart';
import '../widgets/app_branding.dart';
import '../widgets/glass_card.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logo;
  late final Animation<double> _title;
  late final Animation<double> _body;
  late final Animation<double> _buttons;

  Animation<double> _interval(double begin, double end) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
    _logo = _interval(0.0, 0.5);
    _title = _interval(0.2, 0.65);
    _body = _interval(0.4, 0.8);
    _buttons = _interval(0.6, 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final logoSize = R.s(context, 130);
        final appNameSize = R.f(context, 30);
        final appSubSize = R.f(context, 13);
        final taglineSize = R.f(context, 16);
        final descSize = R.f(context, 13.5);
        final btnHeight = R.s(context, 52);
        final btnHeight2 = R.s(context, 48);
        final hPad = R.s(context, 28);

        return Scaffold(
          body: AppBackground(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              const Align(
                                alignment:
                                    AlignmentDirectional.centerEnd,
                                child: _LanguageButton(),
                              ),
                              const Spacer(flex: 2),
                              _Reveal(
                                animation: _logo,
                                child: AppLogo(size: logoSize),
                              ),
                              if (!kLogoHasName) ...[
                                const SizedBox(height: 12),
                                _Reveal(
                                  animation: _title,
                                  child: Column(
                                    children: [
                                      Text(
                                        appState.tr('appName'),
                                        textAlign: TextAlign.center,
                                        style: brandStyle(
                                          appState.tr('appName'),
                                          fontSize: appNameSize,
                                          fontWeight: FontWeight.w700,
                                          height: 1.3,
                                          color: AppColors.softGold,
                                          shadows: [
                                            Shadow(
                                              color: AppColors.gold
                                                  .withValues(alpha: 0.55),
                                              blurRadius: 18,
                                            ),
                                            const Shadow(
                                              color: Color(0xCC000000),
                                              blurRadius: 6,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        appState.tr('appNameSub'),
                                        style: brandStyle(
                                          appState.tr('appNameSub'),
                                          fontSize: appSubSize,
                                          letterSpacing:
                                              appState.isArabic ? 3 : 0,
                                          color: AppColors.cream
                                              .withValues(alpha: 0.65),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              _Reveal(
                                animation: _body,
                                child: GlassCard(
                                  child: Column(
                                    children: [
                                      Text(
                                        appState.tr('tagline'),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: taglineSize,
                                          fontWeight: FontWeight.w600,
                                          height: 1.5,
                                          color: AppColors.cream,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        appState.tr('description'),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: descSize,
                                          height: 1.7,
                                          color: AppColors.cream
                                              .withValues(alpha: 0.78),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(flex: 3),
                              _Reveal(
                                animation: _buttons,
                                child: Column(
                                  children: [
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.of(context).push(
                                        fadeRoute(const RegisterScreen()),
                                      ),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.gold,
                                        foregroundColor:
                                            AppColors.deepGreen,
                                        minimumSize: Size.fromHeight(
                                            btnHeight),
                                        elevation: 6,
                                        shadowColor: AppColors.gold,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(
                                                  R.s(context, 16)),
                                        ),
                                        textStyle: TextStyle(
                                          fontSize: R.f(context, 16),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      child:
                                          Text(appState.tr('getStarted')),
                                    ),
                                    const SizedBox(height: 12),
                                    OutlinedButton(
                                      onPressed: () =>
                                          Navigator.of(context).push(
                                        fadeRoute(const LoginScreen()),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            AppColors.softGold,
                                        minimumSize: Size.fromHeight(
                                            btnHeight2),
                                        side: BorderSide(
                                          color: AppColors.gold
                                              .withValues(alpha: 0.6),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(
                                                  R.s(context, 16)),
                                        ),
                                        textStyle: TextStyle(
                                          fontSize: R.f(context, 14.5),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      child:
                                          Text(appState.tr('haveAccount')),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                appState.tr('credit'),
                                style: TextStyle(
                                  fontSize: R.f(context, 11),
                                  letterSpacing: 1,
                                  color: AppColors.cream
                                      .withValues(alpha: 0.45),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Reveal extends StatelessWidget {
  const _Reveal({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return OutlinedButton.icon(
          onPressed: appState.toggleLanguage,
          icon: const Icon(Icons.language, size: 18),
          label: Text(appState.tr('switchLanguage')),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.softGold,
            side:
                BorderSide(color: AppColors.gold.withValues(alpha: 0.6)),
            shape: const StadiumBorder(),
          ),
        );
      },
    );
  }
}
