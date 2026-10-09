import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_flow.dart';
import '../core/app_state.dart';
import '../core/prayer_state.dart';
import '../core/profile_state.dart';
import '../core/reciter_prefs.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../core/theme_state.dart';
import '../services/ads_service.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/community_notification_service.dart';
import '../services/notification_service.dart';
import '../widgets/app_branding.dart';
import '../widgets/asset_icon.dart';
import '../widgets/language_picker_sheet.dart';
import '../widgets/premium_promo_dialog.dart';
import 'adhan_screen.dart';
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

  Timer? _prayerCheckTimer;
  Timer? _ongoingNotifTimer;
  DateTime? _lastPrayerScreenShownAt;
  bool _rescheduleInFlight = false;
  DateTime? _lastRescheduledPrayerDay;

  static const String _kOpenCount = 'app_open_count';
  static const String _kShown2 = 'premium_promo_shown_2';
  static const String _kShown5 = 'premium_promo_shown_5';

  @override
  void initState() {
    super.initState();
    debugPrint('[PRAYER] HomeShell initState');

    prayerState.start();
    profileState.load();
    reciterPrefs.load();
    themeState.load();

    adsService.initialize();

    prayerState.addListener(_onPrayerStateChanged);
    _startPrayerCheck();
    _startOngoingNotification();

    _checkPromo();

    // ✅ إشعار الإشعارات المُعلّقة بعد استقرار الشاشة
    Future.delayed(const Duration(seconds: 1), () {
      notificationService.consumePendingLaunch();
    });

    // ✅ طلب الصلاحيات + تحديث الإشعار + إعادة الجدولة بعد 3 ثوانٍ
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;
      await notificationService.requestPermissions();
      await _updateOngoing();
      await _rescheduleAfterPrayerTimesReady();
    });

    // ✅ عند تسجيل الدخول → حدّث الإشعار الدائم
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && mounted) {
        debugPrint('[PRAYER] User logged in → updating ongoing');
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _updateOngoing();
        });
      }
    });
  }

  @override
  void dispose() {
    debugPrint('[PRAYER] HomeShell dispose');
    prayerState.removeListener(_onPrayerStateChanged);
    _prayerCheckTimer?.cancel();
    _ongoingNotifTimer?.cancel();
    super.dispose();
  }

  // ============================================================
  // فحص وقت الصلاة + فتح شاشة الأذان
  // ============================================================
  void _startPrayerCheck() {
    _prayerCheckTimer =
        Timer.periodic(const Duration(seconds: 30), (_) {
      _checkForPrayerTime();
    });
  }

  void _checkForPrayerTime() {
    final data = prayerState.data;
    if (data == null) return;

    final now = DateTime.now();

    for (final entry in data.prayers) {
      final parts = entry.value.split(':');
      if (parts.length < 2) continue;

      final prayerAt = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      final diff = now.difference(prayerAt).inSeconds;

      if (diff >= 0 && diff < 60) {
        if (_lastPrayerScreenShownAt == prayerAt) return;
        _lastPrayerScreenShownAt = prayerAt;

        debugPrint('[FULLSCREEN] Opening AdhanScreen for ${entry.key}');

        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AdhanScreen(
              prayerKey: entry.key,
              prayerTime: prayerAt,
            ),
          ),
        );
        return;
      }
    }
  }

  void _startOngoingNotification() {
    Future.delayed(const Duration(seconds: 1), _updateOngoing);

    // ✅ يُعاد نشر الإشعار الدائم كل دقيقة (يتجدد مكانه بدون صوت)
    _ongoingNotifTimer =
        Timer.periodic(const Duration(minutes: 1), (_) => _updateOngoing());
  }

  void _onPrayerStateChanged() {
    if (prayerState.status == PrayerStatus.ready) {
      debugPrint('[PRAYER] prayerState ready');
      _updateOngoing();
      _rescheduleAfterPrayerTimesReady();
    }
  }

  Future<void> _rescheduleAfterPrayerTimesReady() async {
    if (_rescheduleInFlight || prayerState.data == null) return;

    final day = DateTime.now();
    final key = DateTime(day.year, day.month, day.day);

    if (_lastRescheduledPrayerDay == key) return;

    _rescheduleInFlight = true;

    try {
      final prayers = notificationService.collectPrayerTimes();

      if (prayers.isNotEmpty) {
        await notificationService.reschedule(prayers: prayers);
        _lastRescheduledPrayerDay = key;
        debugPrint('[ALARM] All prayers scheduled');
      }
    } catch (e) {
      debugPrint('[ERROR] Reschedule failed: $e');
    } finally {
      _rescheduleInFlight = false;
    }

    // ✅ نعيد نشر الإشعار الدائم بعد الجدولة
    if (mounted) _updateOngoing();
  }

  Future<void> _updateOngoing() async {
    final next = prayerState.nextPrayer();
    if (next == null) {
      debugPrint('[NOTIFICATION] No next prayer yet');
      return;
    }

    final now = DateTime.now();
    final diff = next.at.difference(now);

    if (diff.isNegative) return;

    final isUrgent = diff.inMinutes < 10;

    debugPrint('[NOTIFICATION] Next: ${next.key} · ${next.at} · urgent=$isUrgent');

    final data = prayerState.data;
    final hijri =
        appState.isArabic ? data?.hijriAr : data?.hijriEn;

    await notificationService.showOngoingPrayer(
      prayerName: appState.tr(next.key),
      targetTime: next.at,
      urgent: isUrgent,
      hijriDate: hijri,
    );
  }

  // ============================================================
  // 🐛 اختبار الأذان
  // ============================================================
  Future<void> _scheduleTestAdhan() async {
    final ok = await notificationService.scheduleTestAdhan();
    if (!mounted) return;

    final err = notificationService.lastError;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? (appState.isArabic
                  ? '✅ تم الجدولة — اقفل الشاشة وانتظر 30 ثانية'
                  : '✅ Scheduled — lock the screen and wait 30s')
              : (appState.isArabic
                  ? '❌ فشلت الجدولة\n$err'
                  : '❌ Scheduling failed\n$err'),
        ),
        backgroundColor: ok ? AppColors.emerald : Colors.redAccent,
        duration: Duration(seconds: ok ? 5 : 15),
      ),
    );
  }

  Future<void> _showImmediate() async {
    await notificationService.showImmediateNotification();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          appState.isArabic
              ? '🔔 يجب أن يظهر الإشعار الآن'
              : '🔔 Notification should appear now',
        ),
        backgroundColor: AppColors.emerald,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _checkPromo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = (prefs.getInt(_kOpenCount) ?? 0) + 1;

      await prefs.setInt(_kOpenCount, count);

      final email =
          FirebaseAuth.instance.currentUser?.email?.toLowerCase() ?? '';

      const ownerEmails = [
        'abdelrahmenbenromdhan11@gmail.com',
        'vevocom888@gmail.com',
        'nooralimanechannel@gmail.com',
        'nooralhidayahbusiness@gmail.com',
      ];

      if (ownerEmails.contains(email)) return;

      bool shouldShow = false;

      if (count == 2 && prefs.getBool(_kShown2) != true) {
        shouldShow = true;
        await prefs.setBool(_kShown2, true);
      } else if (count == 5 && prefs.getBool(_kShown5) != true) {
        shouldShow = true;
        await prefs.setBool(_kShown5, true);
      }

      if (!shouldShow || !mounted) return;

      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;

      await showPremiumPromoDialog(context);
    } catch (_) {}
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
                            Icons.edit_location_alt_outlined,
                          ),
                        ),
                        const Spacer(),
                        _buildChatButton(context),
                        SizedBox(width: R.s(context, 4)),
                        _buildNotifButton(context),
                        SizedBox(width: R.s(context, 4)),
                        if (authService.isOwner) ...[
                          IconButton(
                            onPressed: _scheduleTestAdhan,
                            tooltip: appState.isArabic
                                ? 'اختبار الأذان (30 ثوان)'
                                : 'Test Adhan (30s)',
                            color: const Color(0xFFFFA000),
                            iconSize: R.s(context, 24),
                            icon: const Icon(Icons.bug_report_rounded),
                          ),
                          IconButton(
                            onPressed: _showImmediate,
                            tooltip: appState.isArabic
                                ? 'عرض إشعار فوري'
                                : 'Show immediate',
                            color: const Color(0xFF4CAF50),
                            iconSize: R.s(context, 24),
                            icon: const Icon(
                                Icons.notifications_active_rounded),
                          ),
                        ],
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
                          onPressed: () =>
                              showLanguagePicker(context),
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
            child: _BottomBar(
              index: _index,
              onSelected: _select,
            ),
          ),
        );
      },
    );
  }

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
              iconSize: R.s(context, 22),
              icon: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  AppColors.gold,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/icons/chat.png',
                  width: R.s(context, 22),
                  height: R.s(context, 22),
                  errorBuilder: (_, _, _) => Icon(
                    Icons.chat_bubble_outline,
                    color: AppColors.gold,
                    size: R.s(context, 22),
                  ),
                ),
              ),
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
                  constraints:
                      const BoxConstraints(minWidth: 16),
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
                  constraints:
                      const BoxConstraints(minWidth: 16),
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
  const _BottomBar({
    required this.index,
    required this.onSelected,
  });

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
                color: AppColors.gold.withValues(alpha: 0.3),
              ),
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
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
          vertical: 4,
        ),
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
