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
                // ===== زر Google Sign-In =====
                _GoogleButton(
                  loading: _googleLoading,
                  onPressed: _googleSignIn,
                ),
                const SizedBox(height: 20),
                _OrDivider(text: appState.tr('locOr')),
                const SizedBox(height: 20),

                // ===== نموذج Email/Password =====
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
// _GoogleButton — زر Google
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
                  // G Icon (Google colors)
                  const _GoogleGIcon(size: 22),
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
// _GoogleGIcon — أيقونة G بألوان Google
// ============================================================
class _GoogleGIcon extends StatelessWidget {
  const _GoogleGIcon({this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleGPainter(),
      ),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()..style = PaintingStyle.fill;

    // رسم G بحلقات ملونة (مبسّط)
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final colors = [
      const Color(0xFF4285F4), // Blue
      const Color(0xFF34A853), // Green
      const Color(0xFFFBBC05), // Yellow
      const Color(0xFFEA4335), // Red
    ];

    // Blue arc (top-right)
    paint.color = colors[0];
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -0.5,
      1.5,
      false,
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.22,
    );

    // Green arc (bottom-right)
    paint.color = colors[1];
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      1.0,
      1.2,
      false,
      paint,
    );

    // Yellow arc (bottom-left)
    paint.color = colors[2];
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      2.2,
      1.0,
      false,
      paint,
    );

    // Red arc (top-left)
    paint.color = colors[3];
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      3.2,
      0.9,
      false,
      paint,
    );

    // Horizontal blue bar (G crossbar)
    paint
      ..color = colors[0]
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(
        cx,
        cy - size.height * 0.11,
        r * 1.05,
        size.height * 0.22,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// _OrDivider — خط فاصل "أو"
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
