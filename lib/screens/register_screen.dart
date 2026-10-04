import 'package:flutter/material.dart';

import '../core/app_flow.dart';
import '../core/app_state.dart';
import '../core/navigation.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../core/validators.dart';
import '../services/auth_service.dart';
import '../widgets/auth_widgets.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _hidePassword = true;
  bool _hideConfirm = true;
  bool _loading = false;
  bool _googleLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);
    try {
      await authService.register(_email.text, _password.text);
      if (!mounted) return;
      await goAfterAuth(context);
    } on AuthException catch (e) {
      if (mounted) {
        showAuthMessage(context, appState.tr(e.key), error: true);
      }
    } catch (e) {
      if (mounted) {
        showAuthMessage(context, 'حدث خطأ غير متوقع: $e', error: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _googleLoading = true);
    try {
      final ok = await authService.signInWithGoogle();
      if (!mounted) return;
      if (ok) {
        await goAfterAuth(context);
      }
    } on AuthException catch (e) {
      if (mounted) {
        showAuthMessage(context, appState.tr(e.key), error: true);
      }
    } catch (e) {
      if (mounted) {
        showAuthMessage(context, 'حدث خطأ غير متوقع: $e', error: true);
      }
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return AuthScaffold(
          title: appState.tr('createAccount'),
          subtitle: appState.tr('createAccountSub'),
          footer: AuthSwitchLink(
            question: appState.tr('haveAccountQ'),
            action: appState.tr('login'),
            onTap: () => Navigator.of(context)
                .pushReplacement(fadeRoute(const LoginScreen())),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _GoogleButton(
                  loading: _googleLoading,
                  onPressed: _googleSignIn,
                ),
                const SizedBox(height: 20),
                _OrDivider(text: appState.tr('locOr')),
                const SizedBox(height: 20),
                GoldTextField(
                  controller: _email,
                  label: appState.tr('email'),
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: validateEmail,
                ),
                const SizedBox(height: 16),
                GoldTextField(
                  controller: _password,
                  label: appState.tr('password'),
                  icon: Icons.lock_outline_rounded,
                  obscure: _hidePassword,
                  textInputAction: TextInputAction.next,
                  validator: validateNewPassword,
                  suffix: PasswordToggle(
                    hidden: _hidePassword,
                    onPressed: () =>
                        setState(() => _hidePassword = !_hidePassword),
                  ),
                ),
                const SizedBox(height: 16),
                GoldTextField(
                  controller: _confirm,
                  label: appState.tr('confirmPassword'),
                  icon: Icons.lock_reset_rounded,
                  obscure: _hideConfirm,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return appState.tr('errPasswordEmpty');
                    }
                    if (value != _password.text) {
                      return appState.tr('errPasswordMismatch');
                    }
                    return null;
                  },
                  suffix: PasswordToggle(
                    hidden: _hideConfirm,
                    onPressed: () =>
                        setState(() => _hideConfirm = !_hideConfirm),
                  ),
                ),
                const SizedBox(height: 22),
                GoldButton(
                  label: appState.tr('createAccount'),
                  loading: _loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// _GoogleButton
// ============================================================
class _GoogleButton extends StatelessWidget {
  const _GoogleButton({
    required this.loading,
    required this.onPressed,
  });

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F1F1F),
          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.6)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF1F1F1F),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/google.png',
                    width: R.s(context, 22),
                    height: R.s(context, 22),
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.g_mobiledata_rounded,
                      size: 26,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    appState.isArabic
                        ? 'متابعة عبر Google'
                        : 'Continue with Google',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ============================================================
// _OrDivider
// ============================================================
class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Divider(color: AppColors.gold.withValues(alpha: 0.3)),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.cream.withValues(alpha: 0.65),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        line,
      ],
    );
  }
}
