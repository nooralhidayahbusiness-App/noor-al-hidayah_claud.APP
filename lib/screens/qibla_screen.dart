import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_state.dart';
import '../core/prayer_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../services/qibla_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/themed_background.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double _deviceHeading = 0;
  bool _hasSensor = false;
  bool _sensorError = false;

  @override
  void initState() {
    super.initState();
    _listenCompass();
  }

  void _listenCompass() {
    try {
      FlutterCompass.events?.listen(
        (event) {
          if (event.heading == null) {
            if (mounted && !_sensorError) {
              setState(() {
                _sensorError = true;
                _hasSensor = false;
              });
            }
            return;
          }
          if (!mounted) return;
          setState(() {
            _deviceHeading = event.heading!;
            _hasSensor = true;
            _sensorError = false;
          });
        },
        onError: (_) {
          if (mounted) {
            setState(() {
              _sensorError = true;
              _hasSensor = false;
            });
          }
        },
      );
    } catch (_) {
      _sensorError = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = prayerState.location;
    final hasLocation = loc?.latitude != null && loc?.longitude != null;

    final qibla = hasLocation
        ? QiblaService.qiblaDirection(
            latitude: loc!.latitude!,
            longitude: loc.longitude!,
          )
        : 0.0;

    final distance = hasLocation
        ? QiblaService.distanceToKaaba(
            latitude: loc!.latitude!,
            longitude: loc.longitude!,
          )
        : 0.0;

    // الفرق بين اتجاه الجهاز واتجاه القبلة
    final diff = _normalizeDiff(qibla - _deviceHeading);
    final absDiff = diff.abs();
    final aligned = absDiff < 5 && _hasSensor;

    return Scaffold(
      body: ThemedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ===== الهيدر =====
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  R.s(context, 6),
                  R.s(context, 6),
                  R.s(context, 16),
                  0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      color: AppColors.softGold,
                      iconSize: R.s(context, 22),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Spacer(),
                    Text(
                      appState.tr('qibla'),
                      style: TextStyle(
                        fontSize: R.f(context, 15),
                        fontWeight: FontWeight.w700,
                        color: AppColors.softGold,
                      ),
                    ),
                    SizedBox(width: R.s(context, 40)),
                  ],
                ),
              ),

              SizedBox(height: R.s(context, 6)),

              if (!hasLocation)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(R.s(context, 20)),
                      child: GlassCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_off_rounded,
                                color: AppColors.gold,
                                size: R.s(context, 40)),
                            SizedBox(height: R.s(context, 10)),
                            Text(
                              appState.tr('qiblaNeedLocation'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: R.f(context, 13),
                                color: AppColors.cream,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      R.s(context, 16),
                      0,
                      R.s(context, 16),
                      R.s(context, 20),
                    ),
                    children: [
                      // ===== البوصلة =====
                      Center(
                        child: _Compass(
                          deviceHeading: _deviceHeading,
                          qiblaDirection: qibla,
                          hasSensor: _hasSensor,
                          aligned: aligned,
                        ),
                      ),

                      SizedBox(height: R.s(context, 16)),

                      // ===== حالة الإشارة =====
                      if (!_hasSensor)
                        _InfoBanner(
                          icon: Icons.info_outline_rounded,
                          text: appState.tr('qiblaNoSensor'),
                          color: AppColors.softGold,
                        )
                      else if (aligned)
                        _InfoBanner(
                          icon: Icons.check_circle_rounded,
                          text: appState.tr('qiblaAligned'),
                          color: const Color(0xFF4CAF50),
                        )
                      else
                        _InfoBanner(
                          icon: Icons.rotate_right_rounded,
                          text: appState.tr('qiblaRotate'),
                          color: AppColors.gold,
                        ),

                      SizedBox(height: R.s(context, 14)),

                      // ===== التفاصيل =====
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.explore_rounded,
                              label: appState.tr('qiblaAngle'),
                              value:
                                  '${qibla.toStringAsFixed(0)}° ${appState.isArabic ? QiblaService.cardinalAr(qibla) : QiblaService.cardinalEn(qibla)}',
                            ),
                          ),
                          SizedBox(width: R.s(context, 8)),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.straighten_rounded,
                              label: appState.tr('qiblaDistance'),
                              value:
                                  '${distance.toStringAsFixed(0)} km',
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: R.s(context, 12)),

                      // ===== معلومات الموقع =====
                      GlassCard(
                        ornament: false,
                        child: Row(
                          children: [
                            Icon(Icons.location_on_rounded,
                                color: AppColors.gold,
                                size: R.s(context, 18)),
                            SizedBox(width: R.s(context, 8)),
                            Expanded(
                              child: Text(
                                loc?.label ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: R.f(context, 12),
                                  color: AppColors.cream,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  double _normalizeDiff(double d) {
    // يرجع الفرق في نطاق -180 إلى 180
    var x = d % 360;
    if (x > 180) x -= 360;
    if (x < -180) x += 360;
    return x;
  }
}

// ==================== البوصلة ====================
class _Compass extends StatelessWidget {
  const _Compass({
    required this.deviceHeading,
    required this.qiblaDirection,
    required this.hasSensor,
    required this.aligned,
  });

  final double deviceHeading;
  final double qiblaDirection;
  final bool hasSensor;
  final bool aligned;

  @override
  Widget build(BuildContext context) {
    final size = R.s(context, 300);

    // زاوية دوران القرص (نطرح اتجاه الجهاز ليظهر الشمال ثابتًا)
    final dialRotation = -deviceHeading * math.pi / 180.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // الهالة الخارجية
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: aligned
                      ? const Color(0xFF4CAF50)
                          .withValues(alpha: 0.55)
                      : AppColors.gold.withValues(alpha: 0.35),
                  blurRadius: aligned ? 40 : 24,
                  spreadRadius: aligned ? 6 : 2,
                ),
              ],
            ),
          ),

          // القرص الثابت (يحتوي على N/E/S/W + نقشات)
          Transform.rotate(
            angle: dialRotation,
            child: SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: _DialPainter(),
              ),
            ),
          ),

          // سهم القبلة (يدور مع الفرق بين القبلة والجهاز)
          Transform.rotate(
            angle: (qiblaDirection - deviceHeading) * math.pi / 180.0,
            child: _QiblaArrow(size: size * 0.42, aligned: aligned),
          ),

          // مركز: أيقونة الكعبة
          Container(
            width: size * 0.24,
            height: size * 0.24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.deepGreen.withValues(alpha: 0.95),
              border: Border.all(
                color: AppColors.gold,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              Icons.mosque_rounded,
              color: AppColors.gold,
              size: size * 0.12,
            ),
          ),
        ],
      ),
    );
  }
}

class _QiblaArrow extends StatelessWidget {
  const _QiblaArrow({required this.size, required this.aligned});

  final double size;
  final bool aligned;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ArrowPainter(aligned: aligned),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter({required this.aligned});

  final bool aligned;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final top = 0.0;
    final bottom = size.height;

    // شكل سهم من الأعلى للأسفل (الرأس في الأعلى)
    final path = Path()
      ..moveTo(cx, top)
      ..lineTo(cx + size.width * 0.12, size.height * 0.18)
      ..lineTo(cx + size.width * 0.04, size.height * 0.18)
      ..lineTo(cx + size.width * 0.04, bottom)
      ..lineTo(cx - size.width * 0.04, bottom)
      ..lineTo(cx - size.width * 0.04, size.height * 0.18)
      ..lineTo(cx - size.width * 0.12, size.height * 0.18)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = aligned ? const Color(0xFF4CAF50) : AppColors.gold
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.softGold.withValues(alpha: 0.9)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter old) =>
      old.aligned != aligned;
}

class _DialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;

    // الحلقة الخارجية الذهبية
    canvas.drawCircle(
      c,
      r - 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.gold.withValues(alpha: 0.75),
    );

    canvas.drawCircle(
      c,
      r - 14,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.gold.withValues(alpha: 0.35),
    );

    // علامات الدرجات
    for (int i = 0; i < 72; i++) {
      final angle = (i * 5) * math.pi / 180.0;
      final isMajor = i % 9 == 0; // كل 45 درجة
      final isMain = i % 18 == 0; // كل 90 درجة (N, E, S, W)
      final len = isMain
          ? 18.0
          : isMajor
              ? 12.0
              : 6.0;
      final w = isMain ? 3.0 : 1.2;
      final color = isMain
          ? AppColors.gold
          : AppColors.gold.withValues(alpha: 0.5);

      final p1 = Offset(
        c.dx + (r - 18) * math.cos(angle - math.pi / 2),
        c.dy + (r - 18) * math.sin(angle - math.pi / 2),
      );
      final p2 = Offset(
        c.dx + (r - 18 - len) * math.cos(angle - math.pi / 2),
        c.dy + (r - 18 - len) * math.sin(angle - math.pi / 2),
      );

      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..strokeWidth = w
          ..color = color
          ..strokeCap = StrokeCap.round,
      );
    }

    // الحروف N / E / S / W
    final letters = ['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final angle = i * 90 * math.pi / 180.0 - math.pi / 2;
      final p = Offset(
        c.dx + (r - 42) * math.cos(angle),
        c.dy + (r - 42) * math.sin(angle),
      );
      final color = i == 0 ? const Color(0xFFFF8A80) : AppColors.gold;

      final tp = TextPainter(
        text: TextSpan(
          text: letters[i],
          style: GoogleFonts.cinzel(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(p.dx - tp.width / 2, p.dy - tp.height / 2));
    }

    // النقشات الداخلية
    for (int i = 0; i < 24; i++) {
      final angle = i * 15 * math.pi / 180.0 - math.pi / 2;
      final p = Offset(
        c.dx + (r - 80) * math.cos(angle),
        c.dy + (r - 80) * math.sin(angle),
      );
      canvas.drawCircle(
        p,
        2,
        Paint()..color = AppColors.gold.withValues(alpha: 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      ornament: false,
      child: Column(
        children: [
          Icon(icon, color: AppColors.gold, size: R.s(context, 22)),
          SizedBox(height: R.s(context, 6)),
          Text(
            label,
            style: TextStyle(
              fontSize: R.f(context, 10.5),
              color: AppColors.cream.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: R.s(context, 3)),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: R.f(context, 13),
              fontWeight: FontWeight.w800,
              color: AppColors.softGold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      ornament: false,
      child: Row(
        children: [
          Icon(icon, color: color, size: R.s(context, 20)),
          SizedBox(width: R.s(context, 8)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: R.f(context, 12),
                fontWeight: FontWeight.w600,
                color: AppColors.cream,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
