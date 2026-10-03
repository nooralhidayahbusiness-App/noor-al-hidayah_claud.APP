import 'package:flutter/material.dart';

import 'asset_icon.dart';

/// شعار واحد:
/// - 'owner' → owner.png (ذهبي مع لمعان)
/// - 'premium' → premium.png (ذهبي مع لمعان)
/// - 'me' → true.me.png (ذهبي مع لمعان)
/// - 'user' → true.users.png (ذهبي بدون لمعان)
/// - 'none' → لا شيء
class VerifiedBadge extends StatefulWidget {
  const VerifiedBadge({
    super.key,
    required this.type,
    this.size = 18,
  });

  /// 'owner' | 'premium' | 'me' | 'user' | 'none'
  final String type;
  final double size;

  @override
  State<VerifiedBadge> createState() => _VerifiedBadgeState();
}

class _VerifiedBadgeState extends State<VerifiedBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == 'none' || widget.type.isEmpty) {
      return const SizedBox.shrink();
    }

    final isSpecial = widget.type == 'owner' ||
        widget.type == 'premium' ||
        widget.type == 'me';

    final asset = switch (widget.type) {
      'owner' => 'assets/icons/owner.png',
      'premium' => 'assets/icons/premium.png',
      'me' => 'assets/icons/true.me.png',
      'user' => 'assets/icons/true.users.png',
      _ => 'assets/icons/true.users.png',
    };

    if (isSpecial) {
      return AnimatedBuilder(
        animation: _shimmer,
        builder: (context, child) {
          final t = _shimmer.value;
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment(-1.0 + 2 * t - 1, -0.3),
                end: Alignment(-1.0 + 2 * t + 1, 0.3),
                colors: const [
                  Color(0x00FFFFFF),
                  Color(0xCCFFFFFF),
                  Color(0x00FFFFFF),
                ],
                stops: const [0.35, 0.5, 0.65],
              ).createShader(rect);
            },
            child: child,
          );
        },
        child: AssetIcon(path: asset, size: widget.size),
      );
    }

    return AssetIcon(path: asset, size: widget.size);
  }
}
