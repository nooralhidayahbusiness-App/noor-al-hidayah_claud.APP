import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';

/// حالة فارغة موحدة بزخرفة إسلامية:
/// نجمة ثمانية ذهبية + عنوان + وصف + زر اختياري
class IslamicEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onButtonTap;

  const IslamicEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appState.direction,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(R.s(context, 24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ===== الأيقونة داخل نجمة ثمانية =====
              _StarMedallion(icon: icon),
              SizedBox(height: R.s(context, 20)),

              // ===== العنوان =====
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.softGold,
                  fontSize: R.f(context, 16),
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
              SizedBox(height: R.s(context, 8)),

              // ===== الوصف =====
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.cream.withValues(alpha: 0.65),
                  fontSize: R.f(context, 12.5),
                  height: 1.6,
                ),
              ),

              // ===== الزر =====
              if (buttonLabel != null && onButtonTap != null) ...[
                SizedBox(height: R.s(context, 22)),
                ElevatedButton.icon(
                  onPressed: onButtonTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.deepGreen,
                    padding: EdgeInsets.symmetric(
                      horizontal: R.s(context, 24),
                      vertical: R.s(context, 12),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.s(context, 24)),
                    ),
                    elevation: 6,
                    shadowColor: AppColors.gold.withValues(alpha: 0.5),
                  ),
                  icon: Icon(
                    Icons.add_rounded,
                    size: R.s(context, 18),
                  ),
                  label: Text(
                    buttonLabel!,
                    style: TextStyle(
                      fontSize: R.f(context, 14),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// _StarMedallion — نجمة ثمانية ذهبية بها أيقونة
// ============================================================
class _StarMedallion extends StatefulWidget {
  final IconData icon;

  const _StarMedallion({required this.icon});

  @override
  State<_StarMedallion> createState() => _StarMedallionState();
}

class _StarMedallionState extends State<_StarMedallion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = R.s(context, 130);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ===== النجمة الدوّارة =====
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              return Transform.rotate(
                angle: _ctrl.value * 2 * math.pi,
                child: CustomPaint(
                  size: Size(size, size),
                  painter: _StarPainter(
                    color: AppColors.gold.withValues(alpha: 0.35),
                  ),
                ),
              );
            },
          ),

          // ===== الحلقة الذهبية =====
          Container(
            width: size * 0.55,
            height: size * 0.55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.gold.withValues(alpha: 0.2),
                  AppColors.deepGreen,
                ],
              ),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.7),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.3),
                  blurRadius: 16,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              color: AppColors.gold,
              size: size * 0.22,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// _StarPainter — رسم نجمة ثمانية
// ============================================================
class _StarPainter extends CustomPainter {
  final Color color;

  _StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2 - 2;
    final innerR = outerR * 0.42;

    final path = Path();
    for (int i = 0; i < 16; i++) {
      final angle = (i * math.pi) / 8 - math.pi / 2;
      final r = i.isEven ? outerR : innerR;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) => false;
}
