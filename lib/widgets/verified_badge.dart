import 'package:flutter/material.dart';

import '../core/theme.dart';

/// شعار واحد — مع تلوين ذهبي تلقائي
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

  String get _asset {
    switch (widget.type) {
      case 'owner':
        return 'assets/icons/owner.png';
      case 'premium':
        return 'assets/icons/premium.png';
      case 'me':
        return 'assets/icons/true.me.png';
      case 'user':
        return 'assets/icons/true.users.png';
      default:
        return 'assets/icons/true.users.png';
    }
  }

  bool get _isSpecial =>
      widget.type == 'owner' ||
      widget.type == 'premium' ||
      widget.type == 'me';

  @override
  Widget build(BuildContext context) {
    if (widget.type == 'none' || widget.type.isEmpty) {
      return const SizedBox.shrink();
    }

    // ✅ صورة مُلوّنة ذهبياً
    final goldIcon = ColorFiltered(
      colorFilter: const ColorFilter.mode(
        AppColors.gold,
        BlendMode.srcIn,
      ),
      child: Image.asset(
        _asset,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Icon(
          Icons.verified,
          size: widget.size,
          color: AppColors.gold,
        ),
      ),
    );

    // ===== شعارات خاصة: لمعان متحرك =====
    if (_isSpecial) {
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
        child: goldIcon,
      );
    }

    return goldIcon;
  }
}
