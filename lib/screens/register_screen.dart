import 'package:flutter/material.dart';

import '../core/app_flow.dart';
import '../core/app_state.dart';
import '../core/navigation.dart';
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
  bool _googleLoading = false; // ✅ جديد

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

  // ✅ جديد: تسجيل الدخول بـ Google
  Future<void> _signInWithGoogle() async {
    FocusScope.of(context).unfocus();
    setState(() => _googleLoading = true);
    try {
      await authService.signInWithGoogle();
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

                // ✅ جديد: فاصل "أو"
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.gold.withValues(alpha: 0.3),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          appState.isArabic ? 'أو' : 'OR',
                          style: TextStyle(
                            color: AppColors.cream.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.gold.withValues(alpha: 0.3),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ جديد: زر الدخول بـ Google
                _buildGoogleButton(),

                const SizedBox(height: 8),
                Text(
                  appState.isArabic
                      ? 'الدخول السريع بحساب Google'
                      : 'Quick sign in with Google',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.cream.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ جديد: زر Google
  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _googleLoading ? null : _signInWithGoogle,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          side: BorderSide(
            color: AppColors.gold.withValues(alpha: 0.5),
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _googleLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF4285F4),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // أيقونة Google من assets
                  Image.asset(
                    'assets/icons/google.png',
                    width: 22,
                    height: 22,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.g_mobiledata_rounded,
                      size: 26,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    appState.isArabic
                        ? 'المتابعة بـ Google'
                        : 'Continue with Google',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
