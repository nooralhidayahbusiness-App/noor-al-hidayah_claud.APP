import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// صورة بروفايل مع حلقة ذهبية دوّارة وتوهج نابض.
///
/// - حساباتك الشخصية → Me.png
/// - حسابات نور الهداية الرسمية → logo.png
/// - المستخدم العادي → avatar_man.png / avatar_woman.png
class ProfileAvatar extends StatefulWidget {
  const ProfileAvatar({
    super.key,
    required this.email,
    required this.avatar,
    this.size = 100,
  });

  final String email;
  final String avatar; // 'man' | 'woman'
  final double size;

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar>
    with TickerProviderStateMixin {
  static const _meEmails = {
    'vevocom888@gmail.com',
    'abdelrahmenbenromdhan11@gmail.com',
  };

  static const _logoEmails = {
    'nooralimanechannel@gmail.com',
    'nooralhidayahbusiness@gmail.com',
  };

  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);

  late final AnimationController _rotate = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  String get _assetPath {
    final e = widget.email.toLowerCase();
    if (_meEmails.contains(e)) return 'assets/images/Me.png';
    if (_logoEmails.contains(e)) return 'assets/images/logo.png';
    return widget.avatar == 'woman'
        ? 'assets/images/avatar_woman.png'
        : 'assets/images/avatar_man.png';
  }

  @override
  void dispose() {
    _glow.dispose();
    _rotate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return SizedBox(
      width: s + 24,
      height: s + 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // توهج خارجي نابض
          AnimatedBuilder(
            animation: _glow,
            builder: (context, _) {
              final t = _glow.value;
              return Container(
                width: s + 8 + 8 * t,
                height: s + 8 + 8 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          AppColors.gold.withValues(alpha: 0.3 + 0.4 * t),
                      blurRadius: 18 + 22 * t,
                      spreadRadius: 1 + 4 * t,
                    ),
                  ],
                ),
              );
            },
          ),
          // حلقة ذهبية دوّارة
          AnimatedBuilder(
            animation: _rotate,
            builder: (context, _) {
              return Transform.rotate(
                angle: _rotate.value * 2 * math.pi,
                child: Container(
                  width: s + 6,
                  height: s + 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        AppColors.gold.withValues(alpha: 0.15),
                        AppColors.gold,
                        AppColors.softGold,
                        AppColors.gold.withValues(alpha: 0.15),
                      ],
                      stops: const [0.0, 0.35, 0.55, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),
          // الصورة
          Container(
            width: s,
            height: s,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF0A1F17),
            ),
            child: ClipOval(
              child: Image.asset(
                _assetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  widget.avatar == 'woman' ? Icons.face_3 : Icons.face_6,
                  size: s * 0.6,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
