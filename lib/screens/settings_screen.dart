import 'package:flutter/material.dart';

import '../core/app_flow.dart';
import '../core/app_state.dart';
import '../core/reciter_prefs.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../core/theme_state.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/user_service.dart';
import '../services/verification_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/reciter_picker_sheet.dart';
import '../widgets/themed_background.dart';
import 'account_screen.dart';
import 'admin/admin_panel_screen.dart';
import 'store_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loading = true;
  Map<String, bool> _notifications = {};
  bool _isOwner = false;
  int _pendingVerifications = 0;

  static const _defaultNotifs = <String, bool>{
    'fajr': true,
    'dhuhr': true,
    'asr': true,
    'maghrib': true,
    'isha': true,
    'adhanEnabled': true,
    'dailyChallenge': true,
    'quranReminder': true,
    'dailyVerse': true,
  };

  int _adhanBeforeMinutes = 0;

  @override
  void initState() {
    super.initState();
    _notifications = Map.from(_defaultNotifs);
    _load();
    Future.delayed(const Duration(seconds: 1), () async {
      if (!mounted) return;
      await notificationService.requestPermissions();
      await _rescheduleNotifications();
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final s = await userService.loadSettings();
      final notifs = (s['notifications'] as Map?) ?? {};
      final loaded = <String, bool>{};
      _defaultNotifs.forEach((key, def) {
        loaded[key] = (notifs[key] as bool?) ?? def;
      });
      final before =
          (notifs['adhanBeforeMinutes'] as num?)?.toInt() ?? 0;

      final ownerFlag = authService.isOwner;
      int pending = 0;
      if (ownerFlag) {
        try {
          pending = await verificationService.pendingCount();
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _notifications = loaded;
          _adhanBeforeMinutes = before;
          _isOwner = ownerFlag;
          _pendingVerifications = pending;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveNotifications() async {
    try {
      await userService.saveSettings({
        'notifications': {
          ..._notifications,
          'adhanBeforeMinutes': _adhanBeforeMinutes,
        }
      });
    } catch (_) {}
  }

  Future<void> _toggleNotif(String key, bool value) async {
    setState(() => _notifications[key] = value);
    await _saveNotifications();
    await _rescheduleNotifications();
  }

  Future<void> _setAdhanBefore(int minutes) async {
    setState(() => _adhanBeforeMinutes = minutes);
    await _saveNotifications();
    await _rescheduleNotifications();
  }

  Future<void> _rescheduleNotifications() async {
    final prayers = notificationService.collectPrayerTimes();
    await notificationService.reschedule(prayers: prayers);
  }

  Future<void> _openStore() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StoreScreen()),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openAccount() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AccountScreen()),
    );
    if (mounted) _load();
  }

  Future<void> _openAdminPanel() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
    );
    if (mounted) _load();
  }

  Future<void> _openReciterPicker() async {
    final selected = await showReciterPicker(
      context,
      selectedId: reciterPrefs.reciterId,
    );
    if (selected == null || !mounted) return;
    await reciterPrefs.setReciter(selected);
    if (mounted) setState(() {});
  }

  // ✅ التعديل: بعد signOut → ننتقل لشاشة "ابدأ الآن"
  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepGreen,
        title: Text(
          appState.tr('signOutConfirmTitle'),
          style: const TextStyle(color: AppColors.softGold),
        ),
        content: Text(
          appState.tr('signOutConfirmBody'),
          style: const TextStyle(color: AppColors.cream),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(appState.tr('cancel'),
                style: const TextStyle(color: AppColors.softGold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(appState.tr('signOut'),
                style: const TextStyle(color: Color(0xFFFF8A80))),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await authService.signOut();
      if (mounted) {
        await goAfterSignOut(context);
      }
    }
  }

  void _openLanguagePicker() {
    final languages = <MapEntry<String, String>>[
      const MapEntry('ar', 'العربية'),
      const MapEntry('en', 'English'),
      const MapEntry('fr', 'Français'),
      const MapEntry('ur', 'اردو'),
      const MapEntry('ne', 'नेपाली'),
      const MapEntry('id', 'Bahasa Indonesia'),
      const MapEntry('ms', 'Bahasa Melayu'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.all(R.s(context, 16)),
        decoration: const BoxDecoration(
          color: AppColors.deepGreen,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: R.s(context, 12)),
            Text(
              appState.tr('languageChoose'),
              style: TextStyle(
                fontSize: R.f(context, 14),
                fontWeight: FontWeight.w700,
                color: AppColors.softGold,
              ),
            ),
            SizedBox(height: R.s(context, 12)),
            ...languages.map((lang) {
              final isSelected = appState.languageCode == lang.key;
              return Padding(
                padding: EdgeInsets.only(bottom: R.s(context, 6)),
                child: GestureDetector(
                  onTap: () {
                    appState.setLanguage(lang.key);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.s(context, 12),
                      vertical: R.s(context, 12),
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.gold.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.gold
                            : AppColors.gold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            lang.value,
                            style: TextStyle(
                              fontSize: R.f(context, 14),
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.gold
                                  : AppColors.cream,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.gold,
                            size: R.s(context, 20),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            SizedBox(height: R.s(context, 8)),
          ],
        ),
      ),
    );
  }

  String _currentLanguageLabel() {
    switch (appState.languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'ur':
        return 'اردو';
      case 'ne':
        return 'नेपाली';
      case 'id':
        return 'Bahasa Indonesia';
      case 'ms':
        return 'Bahasa Melayu';
      default:
        return 'العربية';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThemedBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  R.s(context, 6),
                  R.s(context, 6),
                  R.s(context, 16),
                  0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      tooltip: appState.tr('back'),
                      color: AppColors.softGold,
                      iconSize: R.s(context, 22),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Spacer(),
                    Text(
                      appState.tr('settings'),
                      style: TextStyle(
                        fontSize: R.f(context, 15),
                        fontWeight: FontWeight.w700,
                        color: AppColors.softGold,
                      ),
                    ),
                    SizedBox(width: R.s(context, 40)),
                  ],
                ),
              ),
              SizedBox(height: R.s(context, 6)),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.gold))
                    : ListView(
                        padding: EdgeInsets.fromLTRB(
                          R.s(context, 14),
                          0,
                          R.s(context, 14),
                          R.s(context, 20),
                        ),
                        children: [
                          if (_isOwner) ...[
                            _SectionHeader(
                                title: appState.tr('adminPanel')),
                            GestureDetector(
                              onTap: _openAdminPanel,
                              child: GlassCard(
                                ornament: false,
                                child: Row(
                                  children: [
                                    Container(
                                      width: R.s(context, 40),
                                      height: R.s(context, 40),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.gold
                                            .withValues(alpha: 0.15),
                                        border: Border.all(
                                          color: AppColors.gold
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons
                                            .admin_panel_settings_rounded,
                                        color: AppColors.gold,
                                        size: R.s(context, 20),
                                      ),
                                    ),
                                    SizedBox(width: R.s(context, 10)),
                                    Expanded(
                                      child: Text(
                                        appState.tr('adminPanel'),
                                        style: TextStyle(
                                          fontSize: R.f(context, 13.5),
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.softGold,
                                        ),
                                      ),
                                    ),
                                    if (_pendingVerifications > 0)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: R.s(context, 10),
                                          vertical: R.s(context, 4),
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              const Color(0xFFD32F2F),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '$_pendingVerifications',
                                          style: TextStyle(
                                            fontSize: R.f(context, 11),
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    SizedBox(width: R.s(context, 4)),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.softGold
                                          .withValues(alpha: 0.7),
                                      size: R.s(context, 18),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: R.s(context, 14)),
                          ],

                          _SectionHeader(
                              title: appState.tr('settingsAccount')),
                          GlassCard(
                            ornament: false,
                            child: _NavRow(
                              icon: Icons.person_outline_rounded,
                              title: appState.tr('account'),
                              subtitle: authService.currentUser?.email,
                              onTap: _openAccount,
                            ),
                          ),
                          SizedBox(height: R.s(context, 14)),

                          _SectionHeader(
                              title: appState.tr('settingsNotifications')),
                          GlassCard(
                            ornament: false,
                            child: Column(
                              children: [
                                _ToggleRow(
                                  icon: Icons.wb_twilight_rounded,
                                  title: appState.tr('fajr'),
                                  value: _notifications['fajr'] ?? true,
                                  onChanged: (v) =>
                                      _toggleNotif('fajr', v),
                                ),
                                _Divider(),
                                _ToggleRow(
                                  icon: Icons.wb_sunny_rounded,
                                  title: appState.tr('dhuhr'),
                                  value: _notifications['dhuhr'] ?? true,
                                  onChanged: (v) =>
                                      _toggleNotif('dhuhr', v),
                                ),
                                _Divider(),
                                _ToggleRow(
                                  icon: Icons.sunny_snowing,
                                  title: appState.tr('asr'),
                                  value: _notifications['asr'] ?? true,
                                  onChanged: (v) =>
                                      _toggleNotif('asr', v),
                                ),
                                _Divider(),
                                _ToggleRow(
                                  icon: Icons.wb_twilight,
                                  title: appState.tr('maghrib'),
                                  value:
                                      _notifications['maghrib'] ?? true,
                                  onChanged: (v) =>
                                      _toggleNotif('maghrib', v),
                                ),
                                _Divider(),
                                _ToggleRow(
                                  icon: Icons.nightlight_round,
                                  title: appState.tr('isha'),
                                  value: _notifications['isha'] ?? true,
                                  onChanged: (v) =>
                                      _toggleNotif('isha', v),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: R.s(context, 14)),

                          _SectionHeader(
                              title: appState.tr('settingsAdhan')),
                          GlassCard(
                            ornament: false,
                            child: Column(
                              children: [
                                _ToggleRow(
                                  icon:
                                      Icons.notifications_active_rounded,
                                  title: appState.tr('adhanEnabled'),
                                  subtitle:
                                      appState.tr('adhanEnabledDesc'),
                                  value: _notifications['adhanEnabled'] ??
                                      true,
                                  onChanged: (v) =>
                                      _toggleNotif('adhanEnabled', v),
                                ),
                                _Divider(),
                                _ChoiceRow(
                                  icon: Icons.timer_outlined,
                                  title:
                                      appState.tr('adhanBeforeTitle'),
                                  value: _adhanBeforeMinutes,
                                  onTap: _openAdhanBeforePicker,
                                ),
                                _Divider(),
                                _NavRow(
                                  icon: Icons.wallpaper_rounded,
                                  title: appState.tr('adhanBackground'),
                                  subtitle: themeState.adhanBackgroundId ==
                                          'default'
                                      ? appState.tr('themeDefault')
                                      : themeState.adhanBackgroundId,
                                  onTap: _openStore,
                                ),
                                _Divider(),
                                _NavRow(
                                  icon: Icons.record_voice_over_rounded,
                                  title: appState.tr('adhanReciter'),
                                  subtitle: themeState.adhanId == 'default'
                                      ? appState.tr('themeDefault')
                                      : themeState.adhanId,
                                  onTap: _openStore,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: R.s(context, 14)),

                          _SectionHeader(
                              title: appState.tr('settingsDaily')),
                          GlassCard(
                            ornament: false,
                            child: Column(
                              children: [
                                _ToggleRow(
                                  icon: Icons.quiz_rounded,
                                  title:
                                      appState.tr('dailyChallengeNotif'),
                                  value: _notifications[
                                          'dailyChallenge'] ??
                                      true,
                                  onChanged: (v) =>
                                      _toggleNotif('dailyChallenge', v),
                                ),
                                _Divider(),
                                _ToggleRow(
                                  icon: Icons.menu_book_rounded,
                                  title:
                                      appState.tr('quranReminderNotif'),
                                  value: _notifications[
                                          'quranReminder'] ??
                                      true,
                                  onChanged: (v) =>
                                      _toggleNotif('quranReminder', v),
                                ),
                                _Divider(),
                                _ToggleRow(
                                  icon: Icons.auto_awesome_rounded,
                                  title:
                                      appState.tr('dailyVerseNotif'),
                                  value:
                                      _notifications['dailyVerse'] ??
                                          true,
                                  onChanged: (v) =>
                                      _toggleNotif('dailyVerse', v),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: R.s(context, 14)),

                          _SectionHeader(
                              title: appState.tr('settingsAppearance')),
                          GlassCard(
                            ornament: false,
                            child: Column(
                              children: [
                                _ChoiceRow(
                                  icon: Icons.language_rounded,
                                  title: appState.tr('language'),
                                  textValue: _currentLanguageLabel(),
                                  onTap: _openLanguagePicker,
                                ),
                                _Divider(),
                                _NavRow(
                                  icon: Icons.palette_rounded,
                                  title: appState.tr('storeThemes'),
                                  subtitle: themeState.palette.id ==
                                          'default'
                                      ? appState.tr('themeDefault')
                                      : themeState.palette.id,
                                  onTap: _openStore,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: R.s(context, 14)),

                          _SectionHeader(
                              title: appState.tr('settingsQuran')),
                          GlassCard(
                            ornament: false,
                            child: Column(
                              children: [
                                _NavRow(
                                  icon: Icons.headphones_rounded,
                                  title: appState.tr('defaultReciter'),
                                  subtitle: reciterPrefs.reciter.nameAr,
                                  onTap: _openReciterPicker,
                                ),
                                _Divider(),
                                _ToggleRow(
                                  icon: Icons.play_circle_fill_rounded,
                                  title: appState
                                      .tr('reciterAutoAdvance'),
                                  value: reciterPrefs.autoAdvance,
                                  onChanged: (v) async {
                                    await reciterPrefs.setAutoAdvance(v);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: R.s(context, 14)),

                          _SectionHeader(
                              title: appState.tr('settingsAbout')),
                          GlassCard(
                            ornament: false,
                            child: Column(
                              children: [
                                _InfoRow(
                                  icon: Icons.info_outline_rounded,
                                  title: appState.tr('appVersion'),
                                  trailing: '1.0.0',
                                ),
                                _Divider(),
                                _InfoRow(
                                  icon: Icons.person_rounded,
                                  title: appState.tr('developer'),
                                  trailing:
                                      'Abdel Rahmen Ben Romdhan',
                                ),
                                _Divider(),
                                _InfoRow(
                                  icon: Icons.image_rounded,
                                  title: appState.tr('iconsCredit'),
                                  trailing: 'Flaticon',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: R.s(context, 14)),

                          GlassCard(
                            ornament: false,
                            child: _NavRow(
                              icon: Icons.logout_rounded,
                              title: appState.tr('signOut'),
                              color: const Color(0xFFFF8A80),
                              onTap: _signOut,
                            ),
                          ),
                          SizedBox(height: R.s(context, 20)),

                          Center(
                            child: Text(
                              appState.tr('credit'),
                              style: TextStyle(
                                fontSize: R.f(context, 10),
                                letterSpacing: 1,
                                color: AppColors.cream
                                    .withValues(alpha: 0.45),
                              ),
                            ),
                          ),
                          SizedBox(height: R.s(context, 8)),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAdhanBeforePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.all(R.s(context, 16)),
        decoration: const BoxDecoration(
          color: AppColors.deepGreen,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: R.s(context, 12)),
            Text(
              appState.tr('adhanBeforeTitle'),
              style: TextStyle(
                fontSize: R.f(context, 14),
                fontWeight: FontWeight.w700,
                color: AppColors.softGold,
              ),
            ),
            SizedBox(height: R.s(context, 10)),
            for (final min in [0, 5, 10, 15, 20])
              Padding(
                padding: EdgeInsets.only(bottom: R.s(context, 6)),
                child: GestureDetector(
                  onTap: () {
                    _setAdhanBefore(min);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: R.s(context, 10)),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _adhanBeforeMinutes == min
                          ? AppColors.gold.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _adhanBeforeMinutes == min
                            ? AppColors.gold
                            : AppColors.gold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      min == 0
                          ? appState.tr('adhanAtTime')
                          : '$min ${appState.tr('minutes')}',
                      style: TextStyle(
                        fontSize: R.f(context, 13),
                        fontWeight: FontWeight.w700,
                        color: _adhanBeforeMinutes == min
                            ? AppColors.gold
                            : AppColors.cream,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        R.s(context, 6),
        R.s(context, 4),
        R.s(context, 6),
        R.s(context, 8),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: R.f(context, 12.5),
          fontWeight: FontWeight.w700,
          color: AppColors.gold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: AppColors.gold.withValues(alpha: 0.15),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: R.s(context, 8),
        vertical: R.s(context, 6),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: R.s(context, 20)),
          SizedBox(width: R.s(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: R.f(context, 13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.cream,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: R.s(context, 2)),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: R.f(context, 10.5),
                      color: AppColors.cream.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.gold,
              activeTrackColor: AppColors.gold.withValues(alpha: 0.4),
              inactiveThumbColor: AppColors.cream.withValues(alpha: 0.7),
              inactiveTrackColor:
                  Colors.black.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.color,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.gold;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.s(context, 8),
          vertical: R.s(context, 14),
        ),
        child: Row(
          children: [
            Icon(icon, color: c, size: R.s(context, 20)),
            SizedBox(width: R.s(context, 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: R.f(context, 13),
                      fontWeight: FontWeight.w600,
                      color: color ?? AppColors.cream,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    SizedBox(height: R.s(context, 2)),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: R.f(context, 10.5),
                        color: AppColors.cream.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: R.s(context, 18),
              color: AppColors.softGold.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.value,
    this.textValue,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final int? value;
  final String? textValue;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.s(context, 8),
          vertical: R.s(context, 14),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: R.s(context, 20)),
            SizedBox(width: R.s(context, 12)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: R.f(context, 13),
                  fontWeight: FontWeight.w600,
                  color: AppColors.cream,
                ),
              ),
            ),
            Text(
              textValue ?? '$value',
              style: TextStyle(
                fontSize: R.f(context, 12),
                fontWeight: FontWeight.w700,
                color: AppColors.softGold,
              ),
            ),
            SizedBox(width: R.s(context, 4)),
            Icon(
              Icons.chevron_right_rounded,
              size: R.s(context, 18),
              color: AppColors.softGold.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: R.s(context, 8),
        vertical: R.s(context, 14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: R.s(context, 20)),
          SizedBox(width: R.s(context, 12)),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: R.f(context, 13),
                fontWeight: FontWeight.w600,
                color: AppColors.cream,
              ),
            ),
          ),
          Flexible(
            child: Text(
              trailing,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: R.f(context, 11.5),
                color: AppColors.cream.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
