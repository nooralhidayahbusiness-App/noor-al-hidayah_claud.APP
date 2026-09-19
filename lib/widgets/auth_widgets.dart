import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/fonts.dart';
import '../core/theme.dart';
import 'app_branding.dart';
import 'glass_card.dart';

const Color _errorColor = Color(0xFFFF8A80);

/// Shared layout for the sign-up and login screens.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.footer,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      tooltip: appState.tr('back'),
                      color: AppColors.softGold,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Spacer(),
                    const AuthLanguageButton(),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + keyboard),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 32,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const AppLogo(size: 90),
                              const SizedBox(height: 4),
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
                              const SizedBox(height: 6),
                              Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.6,
                                  color:
                                      AppColors.cream.withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(height: 22),
                              GlassCard(child: child),
                              const SizedBox(height: 14),
                              footer,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthLanguageButton extends StatelessWidget {
  const AuthLanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) => OutlinedButton.icon(
        onPressed: appState.toggleLanguage,
        icon: const Icon(Icons.language, size: 18),
        label: Text(appState.tr('switchLanguage')),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.softGold,
          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.6)),
          shape: const StadiumBorder(),
        ),
      ),
    );
  }
}

/// Text field with a gold outline, used in the auth forms.
class GoldTextField extends StatelessWidget {
  const GoldTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final FormFieldValidator<String>? validator;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      textDirection: TextDirection.ltr,
      textAlign: appState.isArabic ? TextAlign.right : TextAlign.left,
      style: const TextStyle(color: AppColors.cream, fontSize: 16),
      cursorColor: AppColors.gold,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.cream.withValues(alpha: 0.7)),
        floatingLabelStyle: const TextStyle(color: AppColors.softGold),
        prefixIcon: Icon(icon, color: AppColors.gold.withValues(alpha: 0.85)),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.25),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: border(AppColors.gold.withValues(alpha: 0.3)),
        focusedBorder: border(AppColors.gold, 1.6),
        errorBorder: border(_errorColor),
        focusedErrorBorder: border(_errorColor, 1.6),
        errorStyle: const TextStyle(color: _errorColor),
      ),
    );
  }
}

class PasswordToggle extends StatelessWidget {
  const PasswordToggle({
    super.key,
    required this.hidden,
    required this.onPressed,
  });

  final bool hidden;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: appState.tr(hidden ? 'showPassword' : 'hidePassword'),
      onPressed: onPressed,
      icon: Icon(
        hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.gold.withValues(alpha: 0.85),
      ),
    );
  }
}

/// Gold button that turns into a spinner while loading.
class GoldButton extends StatelessWidget {
  const GoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.deepGreen,
        disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.6),
        disabledForegroundColor: AppColors.deepGreen,
        minimumSize: const Size.fromHeight(56),
        elevation: 6,
        shadowColor: AppColors.gold,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: loading
            ? const SizedBox(
                key: ValueKey('loading'),
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  color: AppColors.deepGreen,
                ),
              )
            : Text(label, key: const ValueKey('label')),
      ),
    );
  }
}

/// "Already have an account? Sign in" style link.
class AuthSwitchLink extends StatelessWidget {
  const AuthSwitchLink({
    super.key,
    required this.question,
    required this.action,
    required this.onTap,
  });

  final String question;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          question,
          style: TextStyle(color: AppColors.cream.withValues(alpha: 0.8)),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: const TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

void showAuthMessage(BuildContext context, String text, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? const Color(0xFF5C1F1F) : AppColors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.5)),
        ),
        content: Row(
          children: [
            Icon(
              error ? Icons.error_outline : Icons.check_circle_outline,
              color: error ? _errorColor : AppColors.gold,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: AppColors.cream, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
}
