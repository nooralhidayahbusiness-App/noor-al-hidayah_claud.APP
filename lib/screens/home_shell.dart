import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/app_flow.dart';
import '../core/app_state.dart';
import '../core/prayer_state.dart';
import '../core/profile_state.dart';
import '../core/reciter_prefs.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../core/theme_state.dart';
import '../services/chat_service.dart';
import '../services/community_notification_service.dart';
import '../services/notification_service.dart';
import '../widgets/app_branding.dart';
import '../widgets/asset_icon.dart';
import '../widgets/language_picker_sheet.dart';
import 'challenge_screen.dart';
import 'chats_list_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import 'tabs/community_tab.dart';
import 'tabs/home_tab.dart';
import 'tabs/more_tab.dart';
import 'tabs/quran_browser_tab.dart';
import 'tabs/soon_tabs.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final CommunityNotificationService _notifService =
      CommunityNotificationService();

  @override
  void initState() {
    super.initState();
    prayerState.start();
    profileState.load();
    reciterPrefs.load();
    themeState.load();
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;
      final prayers = notificationService.collectPrayerTimes();
      if (prayers.isNotEmpty) {
        await notificationService.reschedule(prayers: prayers);
      }
    });
  }

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([appState, profileState]),
      builder: (context, _) {
        return Scaffold(
          body: AppBackground(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      R.s(context, 8),
                      R.s(context, 8),
                      R.s(context, 16),
                      0,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => openLocationPicker(context),
                          tooltip: appState.tr('changeLocation'),
                          color: AppColors.softGold,
                          iconSize: R.s(context, 26),
                          icon: const Icon(
                              Icons.edit_location_alt_outlined),
                        ),
                        const Spacer(),
                        _buildChatButton(context),
                        SizedBox(width: R.s(context, 4)),
                        _buildNotifButton(context),
                        SizedBox(width: R.s(context, 4)),
                        IconButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          ),
                          tooltip: appState.tr('settings'),
                          iconSize: R.s(context, 26),
                          icon: const AssetIcon(
                            path: 'assets/icons/Setting.png',
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: () => showLanguagePicker(context),
                          tooltip: currentLanguageLabel(),
                          color: AppColors.softGold,
                          iconSize: R.s(context, 24),
                          icon: const Icon(Icons.language),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: _index,
                      children: [
                        HomeTab(onOpenTab: _select),
                        const QuranBrowserTab(),
                        const AdhkarTab(),
                        const ChallengeScreen(),
                        const CommunityTab(),
                        const MoreTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: _BottomBar(index: _index, onSelected: _select),
          ),
        );
      },
    );
  }

  // ============================================================
  // زر الشات
  // ============================================================
  Widget _buildChatButton(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<int>(
      stream: chatService.totalUnreadStream(uid),
      builder: (context, snap) {
        final count = snap.data ?? 0;
        return Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ChatsListScreen(),
                ),
              ),
              color: AppColors.softGold,
              iconSize: R.s(context, 24),
              icon: const Icon(Icons.chat_bubble_outline),
            ),
            if (count > 0)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  constraints: const BoxConstraints(minWidth: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ============================================================
  // زر الإشعارات
  // ============================================================
  Widget _buildNotifButton(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<int>(
      stream: _notifService.unreadCountStream(uid),
      builder: (context, snap) {
        final count = snap.data ?? 0;
        return Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              ),
              color: AppColors.softGold,
              iconSize: R.s(context, 24),
              icon: const Icon(Icons.notifications_none),
            ),
            if (count > 0)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  constraints: const BoxConstraints(minWidth: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TabData {
  const _TabData({
    this.icon,
    this.activeIcon,
    this.assetIcon,
    required this.label,
  });
  final IconData? icon;
  final IconData? activeIcon;
  final String? assetIcon;
  final String label;
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.onSelected});

  final int index;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeState,
      builder: (context, _) {
        final accent = themeState.palette.accentLight;
        final iconSize = R.s(context, 24);
        final labelSize = R.f(context, 10);
        final barHeight = R.s(context, 62);

        final tabs = <_TabData>[
          _TabData(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: appState.tr('tabHome'),
          ),
          _TabData(
            icon: Icons.menu_book_outlined,
            activeIcon: Icons.menu_book_rounded,
            label: appState.tr('tabQuran'),
          ),
          _TabData(
            icon: Icons.auto_stories_outlined,
            activeIcon: Icons.auto_stories_rounded,
            label: appState.tr('tabAdhkar'),
          ),
          _TabData(
            assetIcon: 'assets/icons/challenge.png',
            label: appState.tr('tabChallenge'),
          ),
          _TabData(
            assetIcon: 'assets/icons/community.png',
            label: appState.tr('tabCommunity'),
          ),
          _TabData(
            assetIcon: 'assets/icons/more.png',
            label: appState.tr('tabMore'),
          ),
        ];

        return DecoratedBox(
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.94),
            border: Border(
              top: BorderSide(
                  color: AppColors.gold.withValues(alpha: 0.3)),
            ),
          ),
          child: SizedBox(
            height: barHeight,
            child: Row(
              children: [
                for (int i = 0; i < tabs.length; i++)
                  Expanded(
                    child: _BottomTab(
                      data: tabs[i],
                      selected: i == index,
                      iconSize: iconSize,
                      labelSize: labelSize,
                      onTap: () => onSelected(i),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BottomTab extends StatelessWidget {
  const _BottomTab({
    required this.data,
    required this.selected,
    required this.iconSize,
    required this.labelSize,
    required this.onTap,
  });

  final _TabData data;
  final bool selected;
  final double iconSize;
  final double labelSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.gold
        : AppColors.softGold.withValues(alpha: 0.7);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (data.assetIcon != null)
              AssetIcon(
                path: data.assetIcon!,
                size: iconSize,
                opacity: selected ? 1.0 : 0.75,
              )
            else
              Icon(
                selected
                    ? (data.activeIcon ?? data.icon)
                    : data.icon,
                size: iconSize,
                color: color,
              ),
            const SizedBox(height: 2),
            Text(
              data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: labelSize,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
