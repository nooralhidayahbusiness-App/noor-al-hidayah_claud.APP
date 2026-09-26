import 'package:flutter/material.dart';

import '../core/app_flow.dart';
import '../core/app_state.dart';
import '../core/navigation.dart';
import '../core/validators.dart';
import '../services/auth_service.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/dev_skip.dart';
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
      // ✅ استدعاء Firebase لإنشاء الحساب في Auth و Firestore
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return AuthScaffold(
          title: appState.tr('createAccount'),
          subtitle: appState.tr('createAccountSub'),
          footer: DevSkipFooter(
            link: AuthSwitchLink(
              question: appState.tr('haveAccountQ'),
              action: appState.tr('login'),
              onTap: () => Navigator.of(context)
                  .pushReplacement(fadeRoute(const LoginScreen())),
            ),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
