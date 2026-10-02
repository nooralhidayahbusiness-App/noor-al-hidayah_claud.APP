import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../community_feed_screen.dart';
import 'channel_view.dart';

enum _Section { community, channel }

/// Bottom tab with two sections: the community and "قناتي".
class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  _Section _section = _Section.community;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: AppColors.deepGreen.withValues(alpha: 0.65),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SwitchButton(
                        label: appState.tr('tabCommunity'),
                        active: _section == _Section.community,
                        onTap: () =>
                            setState(() => _section = _Section.community),
                      ),
                    ),
                    Expanded(
                      child: _SwitchButton(
                        label: appState.tr('myChannel'),
                        active: _section == _Section.channel,
                        onTap: () =>
                            setState(() => _section = _Section.channel),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _section == _Section.community
                    ? const _CommunitySection(key: ValueKey('community'))
                    : const ChannelView(key: ValueKey('channel')),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// _CommunitySection — يحمّل بيانات المستخدم ثم يعرض الشاشة
// ============================================================
class _CommunitySection extends StatelessWidget {
  const _CommunitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const _CommunityAuthError();
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // لسا يحمّل
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          );
        }

        // خطأ
        if (snapshot.hasError) {
          return _CommunityError(message: snapshot.error.toString());
        }

        final data = snapshot.data?.data() ?? {};
        final profile =
            (data['profile'] as Map<String, dynamic>?) ?? <String, dynamic>{};

        // الاسم: من profile.name أولاً، وإلا displayName
        final rawName = (profile['name'] as String?)?.trim();
        final userName = (rawName != null && rawName.isNotEmpty)
            ? rawName
            : (user.displayName?.trim().isNotEmpty == true
                ? user.displayName!
                : 'مستخدم');

        // نوع الأفاتار: 'man' | 'woman'
        final userAvatar = (data['avatar'] as String?) ?? 'man';

        // التوثيق
        final userVerified = (profile['verified'] as bool?) ?? false;

        return CommunityFeedScreen(
          uid: user.uid,
          userName: userName,
          userEmail: user.email ?? '',
          userAvatar: userAvatar,
          userVerified: userVerified,
        );
      },
    );
  }
}

// ============================================================
// حالات الخطأ
// ============================================================
class _CommunityAuthError extends StatelessWidget {
  const _CommunityAuthError();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline,
              color: AppColors.gold,
              size: 42,
            ),
            const SizedBox(height: 12),
            const Text(
              'يجب تسجيل الدخول لعرض المجتمع',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.softGold,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityError extends StatelessWidget {
  final String message;

  const _CommunityError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 42,
            ),
            const SizedBox(height: 12),
            const Text(
              'تعذّر تحميل بيانات المستخدم',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.softGold,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.cream.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// _SwitchButton
// ============================================================
class _SwitchButton extends StatelessWidget {
  const _SwitchButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: active ? AppColors.gold : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: active ? AppColors.deepGreen : AppColors.softGold,
          ),
        ),
      ),
    );
  }
}
