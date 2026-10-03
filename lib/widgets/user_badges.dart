import 'package:flutter/material.dart';

import '../core/responsive.dart';
import 'verified_badge.dart';

/// يعرض قائمة الشارات جنب بعضها
/// - ['owner'] → owner فقط
/// - ['premium', 'me'] → premium + me
/// - ['me'] → me فقط
/// - [] → لا شيء
class UserBadges extends StatelessWidget {
  const UserBadges({
    super.key,
    required this.badges,
    this.size = 15,
    this.spacing = 3,
  });

  final List<String> badges;
  final double size;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < badges.length; i++) ...[
          if (i > 0) SizedBox(width: R.s(context, spacing)),
          VerifiedBadge(
            type: badges[i],
            size: R.s(context, size),
          ),
        ],
      ],
    );
  }
}
