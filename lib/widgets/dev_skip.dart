import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/app_flow.dart';
import '../core/theme.dart';

/// Sign-in footer plus a "skip" button that only exists while developing.
/// In a release build (the APK) kDebugMode is false, so the button disappears.
class DevSkipFooter extends StatelessWidget {
  const DevSkipFooter({super.key, required this.link});

  final Widget link;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return link;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        link,
        const SizedBox(height: 6),
        TextButton.icon(
          onPressed: () => goAfterAuth(context),
          icon: const Icon(Icons.fast_forward_rounded, size: 18),
          label: const Text('تخطي (للمطور فقط)'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.softGold.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}
