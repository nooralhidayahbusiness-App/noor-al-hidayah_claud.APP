import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../models/user_brief.dart';
import '../services/follow_service.dart';
import '../widgets/profile_avatar.dart';
import 'user_profile_screen.dart';

// ============ ترجمات إضافية (لهذه الشاشة فقط) ============
const Map<String, String> _emptyFollowers = {
  'ar': 'لا يوجد متابعون بعد',
  'en': 'No followers yet',
  'fr': 'Aucun abonné pour le moment',
  'ur': 'ابھی کوئی پیروکار نہیں',
  'ne': 'अझै कुनै फलोअर छैन',
  'id': 'Belum ada pengikut',
  'ms': 'Belum ada pengikut',
};

const Map<String, String> _emptyFollowing = {
  'ar': 'لا يتابع أحداً بعد',
  'en': 'Not following anyone yet',
  'fr': 'Ne suit personne pour le moment',
  'ur': 'ابھی کسی کو فالو نہیں',
  'ne': 'अझै कसैलाई फलो गरेको छैन',
  'id': 'Belum mengikuti siapa pun',
  'ms': 'Belum mengikuti sesiapa',
};

String _trEmpty(Map<String, String> m) =>
    m[appState.languageCode] ?? m['ar']!;

class FollowListScreen extends StatefulWidget {
  final String profileUid;
  final String profileName;
  final int initialTab; // 0 = followers, 1 = following

  const FollowListScreen({
    super.key,
    required this.profileUid,
    required this.profileName,
    this.initialTab = 0,
  });

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final FollowService _service = FollowService();
  String? _currentUid;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _currentUid = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Directionality(
          textDirection: appState.direction,
          child: Scaffold(
            backgroundColor: AppColors.deepGreen,
            appBar: _buildAppBar(),
            body: TabBarView(
              controller: _tabs,
              children: [
                _buildList(isFollowers: true),
                _buildList(isFollowers: false),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.green,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.cream),
      centerTitle: true,
      title: Text(
        widget.profileName,
        style: TextStyle(
          color: AppColors.softGold,
          fontSize: R.f(context, 16),
          fontWeight: FontWeight.bold,
        ),
      ),
      bottom: TabBar(
        controller: _tabs,
        indicatorColor: AppColors.gold,
        indicatorWeight: 2,
        labelColor: AppColors.gold,
        unselectedLabelColor: AppColors.cream.withValues(alpha: 0.6),
        labelStyle: TextStyle(
          fontSize: R.f(context, 13),
          fontWeight: FontWeight.bold,
        ),
        tabs: [
          Tab(text: appState.tr('cFollowers')),
          Tab(text: appState.tr('cFollowing')),
        ],
      ),
    );
  }

  Widget _buildList({required bool isFollowers}) {
    final stream = isFollowers
        ? _service.followersStream(widget.profileUid)
        : _service.followingStream(widget.profileUid);

    return StreamBuilder<List<UserBrief>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting &&
            !snap.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          );
        }
        if (snap.hasError) {
          return _buildError(appState.tr('cUserDataError'));
        }
        final users = snap.data ?? [];
        if (users.isEmpty) {
          return _buildEmpty(isFollowers: isFollowers);
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: R.s(context, 6)),
          itemCount: users.length,
          itemBuilder: (context, i) {
            final user = users[i];
            return _UserTile(
              user: user,
              currentUid: _currentUid,
              onTap: () => _openProfile(user.uid),
            );
          },
        );
      },
    );
  }

  Widget _buildEmpty({required bool isFollowers}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(R.s(context, 24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFollowers ? Icons.people_outline : Icons.person_outline,
              color: AppColors.cream.withValues(alpha: 0.35),
              size: R.s(context, 42),
            ),
            SizedBox(height: R.s(context, 10)),
            Text(
              _trEmpty(isFollowers ? _emptyFollowers : _emptyFollowing),
              style: TextStyle(
                color: AppColors.cream.withValues(alpha: 0.6),
                fontSize: R.f(context, 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _openProfile(String uid) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(profileUid: uid),
      ),
    );
  }
}

// ============================================================
// _UserTile
// ============================================================
class _UserTile extends StatelessWidget {
  final UserBrief user;
  final String? currentUid;
  final VoidCallback onTap;

  const _UserTile({
    required this.user,
    required this.currentUid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = currentUid == user.uid;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.s(context, 14),
          vertical: R.s(context, 8),
        ),
        child: Row(
          children: [
            ProfileAvatar(
              email: user.email,
              avatar: user.avatar,
              size: R.s(context, 44),
              photoBytes: user.photoBytes,
            ),
            SizedBox(width: R.s(context, 10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.cream,
                            fontSize: R.f(context, 14),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (user.verified) ...[
                        SizedBox(width: R.s(context, 4)),
                        Icon(
                          Icons.verified,
                          color: AppColors.gold,
                          size: R.s(context, 15),
                        ),
                      ],
                    ],
                  ),
                  if (user.bio.trim().isNotEmpty) ...[
                    SizedBox(height: R.s(context, 2)),
                    Text(
                      user.bio.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.cream.withValues(alpha: 0.6),
                        fontSize: R.f(context, 11.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isMe && currentUid != null)
              _FollowButton(
                currentUid: currentUid!,
                targetUid: user.uid,
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// _FollowButton
// ============================================================
class _FollowButton extends StatelessWidget {
  final String currentUid;
  final String targetUid;

  const _FollowButton({
    required this.currentUid,
    required this.targetUid,
  });

  @override
  Widget build(BuildContext context) {
    final service = FollowService();
    return StreamBuilder<bool>(
      stream: service.isFollowingStream(
        followerUid: currentUid,
        followingUid: targetUid,
      ),
      builder: (context, snap) {
        final isFollowing = snap.data ?? false;
        return SizedBox(
          height: R.s(context, 32),
          child: isFollowing
              ? OutlinedButton(
                  onPressed: () => _toggle(service),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.cream,
                    side: BorderSide(
                      color: AppColors.gold.withValues(alpha: 0.5),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: R.s(context, 12),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(R.s(context, 16)),
                    ),
                  ),
                  child: Text(
                    appState.tr('cFollowingState'),
                    style: TextStyle(
                      fontSize: R.f(context, 11.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : ElevatedButton(
                  onPressed: () => _toggle(service),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.deepGreen,
                    padding: EdgeInsets.symmetric(
                      horizontal: R.s(context, 14),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(R.s(context, 16)),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    appState.tr('cFollow'),
                    style: TextStyle(
                      fontSize: R.f(context, 11.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        );
      },
    );
  }

  Future<void> _toggle(FollowService service) async {
    try {
      await service.toggleFollow(
        followerUid: currentUid,
        followingUid: targetUid,
      );
    } catch (_) {}
  }
}
