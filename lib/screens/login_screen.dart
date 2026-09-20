import 'package:flutter/material.dart';

import '../core/app_flow.dart';
import '../core/app_state.dart';
import '../core/navigation.dart';
import '../core/validators.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/dev_skip.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _loading = false);
    await goAfterAuth(context);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return AuthScaffold(
          title: appState.tr('login'),
          subtitle: appState.tr('loginSub'),
          footer: DevSkipFooter(link: AuthSwitchLink(
            question: appState.tr('noAccountQ'),
            action: appState.tr('createAccount'),
            onTap: () => Navigator.of(context)
                .pushReplacement(fadeRoute(const RegisterScreen())),
          )),
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
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: validateLoginPassword,
                  suffix: PasswordToggle(
                    hidden: _hidePassword,
                    onPressed: () =>
                        setState(() => _hidePassword = !_hidePassword),
                  ),
                ),
                const SizedBox(height: 22),
                GoldButton(
                  label: appState.tr('login'),
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
