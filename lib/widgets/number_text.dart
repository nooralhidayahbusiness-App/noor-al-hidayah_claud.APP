import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/fonts.dart';
import '../core/theme.dart';

final RegExp _timePattern = RegExp(r'^(\d{1,2}:\d{2})\s*(.*)$');

/// A clock time like "4:54 ص" with elegant Cinzel digits.
class TimeText extends StatelessWidget {
  const TimeText(
    this.value, {
    super.key,
    required this.fontSize,
    this.color = AppColors.cream,
    this.fontWeight = FontWeight.w600,
  });

  final String value;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final match = _timePattern.firstMatch(value);
    final digits = match?.group(1) ?? value;
    final suffix = match?.group(2) ?? '';
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: digits,
            style: GoogleFonts.cinzel(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color,
              letterSpacing: 1,
            ),
          ),
          if (suffix.isNotEmpty)
            TextSpan(
              text: ' $suffix',
              style: brandStyle(
                suffix,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}

/// Countdown like "01:45:11". Every character sits in a fixed-width slot,
/// so the numbers do not jump around every second.
class CountdownText extends StatelessWidget {
  const CountdownText(
    this.value, {
    super.key,
    required this.fontSize,
    required this.color,
  });

  final String value;
  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.cinzel(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.1,
      shadows: [
        Shadow(color: color.withValues(alpha: 0.4), blurRadius: 12),
      ],
    );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final ch in value.split(''))
            SizedBox(
              width: fontSize * (ch == ':' ? 0.4 : 0.8),
              child: Text(
                ch,
                textAlign: TextAlign.center,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: style,
              ),
            ),
        ],
      ),
    );
  }
}
