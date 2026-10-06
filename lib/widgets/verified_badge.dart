import 'package:flutter/material.dart';

import '../core/theme.dart';

/// شعار واحد — مع تلوين ذهبي تلقائي + لمعان متحرك
/// - 'owner' → owner.png (ذهبي + لمعان + نبض)
/// - 'premium' → premium.png (ذهبي + لمعان + نبض)
/// - 'me' → true.me.png (ذهبي + لمعان)
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
    with TickerProviderStateMixin {
  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _shimmer.dispose();
    _pulse.dispose();
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

  bool get _hasShimmer =>
      widget.type == 'owner' ||
      widget.type == 'premium' ||
      widget.type == 'me';

  bool get _hasPulse =>
      widget.type == 'owner' || widget.type == 'premium';

  @override
  Widget build(BuildContext context) {
    if (widget.type == 'none' || widget.type.isEmpty) {
      return const SizedBox.shrink();
    }

    // 1) صورة ذهبية
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

    Widget result = goldIcon;

    // 2) لمعان (owner / premium / me)
    if (_hasShimmer) {
      result = AnimatedBuilder(
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
                  Color(0xDDFFFFFF),
                  Color(0x00FFFFFF),
                ],
                stops: const [0.35, 0.5, 0.65],
              ).createShader(rect);
            },
            child: child,
          );
        },
        child: result,
      );
    }

    // 3) نبض خفيف (owner / premium)
    if (_hasPulse) {
      result = AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final t = _pulse.value;
          final scale = 1.0 + 0.08 * t;
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: result,
      );
    }

    return result;
  }
}
