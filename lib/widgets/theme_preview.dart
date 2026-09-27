import 'package:flutter/material.dart';

import '../core/theme_palette.dart';

/// معاينة مصغّرة للتطبيق بألوان الثيم.
class ThemePreview extends StatelessWidget {
  const ThemePreview({
    super.key,
    required this.palette,
    this.compact = false,
  });

  final ThemePalette palette;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final pad = compact ? 6.0 : 10.0;
    final gap = compact ? 4.0 : 6.0;

    return Container(
      color: palette.accent,
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // شريط علوي
          Container(
            height: compact ? 10 : 14,
            decoration: BoxDecoration(
              color: palette.accentLight,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: palette.gold.withValues(alpha: 0.6),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 4),
                Container(
                  width: compact ? 3 : 4,
                  height: compact ? 3 : 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: palette.gold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: gap),

          // بطاقة كبيرة
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: palette.accentDark,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: palette.gold.withValues(alpha: 0.5),
                  width: 0.8,
                ),
              ),
              padding: EdgeInsets.all(compact ? 4 : 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: compact ? 14 : 18,
                    height: compact ? 14 : 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: palette.accentLight.withValues(alpha: 0.5),
                      border: Border.all(
                        color: palette.gold,
                        width: 0.8,
                      ),
                    ),
                  ),
                  SizedBox(height: gap / 2),
                  Container(
                    height: 2,
                    width: compact ? 30 : 40,
                    decoration: BoxDecoration(
                      color: palette.gold.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: gap),

          // بطاقة صغيرة
          Container(
            height: compact ? 14 : 18,
            decoration: BoxDecoration(
              color: palette.accentDark,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: palette.gold.withValues(alpha: 0.5),
                width: 0.8,
              ),
            ),
          ),
          SizedBox(height: gap),

          // شريط سفلي (شريط التنقل)
          Container(
            height: compact ? 14 : 20,
            decoration: BoxDecoration(
              color: palette.accentLight,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: palette.gold.withValues(alpha: 0.5),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5,
                (i) => Container(
                  width: compact ? 3 : 4,
                  height: compact ? 3 : 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == 0
                        ? palette.gold
                        : palette.gold.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
