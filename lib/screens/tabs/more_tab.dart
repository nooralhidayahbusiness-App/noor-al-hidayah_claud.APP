import 'package:flutter/material.dart';

import '../../core/app_flow.dart';
import '../../core/app_state.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../account_screen.dart';

class MoreTab extends StatelessWidget {
  const MoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final chevron = appState.isArabic
            ? Icons.chevron_left_rounded
            : Icons.chevron_right_rounded;
        Widget divider() =>
            Divider(height: 1, color: AppColors.gold.withValues(alpha: 0.2));

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            GlassCard(
              ornament: false,
              child: Column(
                children: [
                  _MoreRow(
                    icon: Icons.language,
                    title: appState.tr('language'),
                    trailing: _currentLanguageLabel(),
                    chevron: chevron,
                    onTap: () => _showLanguagePicker(context),
                  ),
                  divider(),
                  _MoreRow(
                    icon: Icons.edit_location_alt_outlined,
                    title: appState.tr('changeLocation'),
                    chevron: chevron,
                    onTap: () => openLocationPicker(context),
                  ),
                  divider(),
                  _MoreRow(
                    icon: Icons.person_outline_rounded,
                    title: appState.tr('account'),
                    chevron: chevron,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const AccountScreen()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ===== الشكر والإسناد =====
            Center(
              child: Column(
                children: [
                  Text(
                    appState.tr('credit'),
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1,
                      color: AppColors.cream.withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    appState.tr('iconsCredit'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.cream.withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // اسم اللغة الحالية
  // ============================================================
  static String _currentLanguageLabel() {
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

  // ============================================================
  // قائمة اختيار اللغة (7 لغات)
  // ============================================================
  static void _showLanguagePicker(BuildContext context) {
    const languages = <MapEntry<String, String>>[
      MapEntry('ar', 'العربية'),
      MapEntry('en', 'English'),
      MapEntry('fr', 'Français'),
      MapEntry('ur', 'اردو'),
      MapEntry('ne', 'नेपाली'),
      MapEntry('id', 'Bahasa Indonesia'),
      MapEntry('ms', 'Bahasa Melayu'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return ListenableBuilder(
          listenable: appState,
          builder: (context, _) {
            return Container(
              padding: EdgeInsets.all(R.s(context, 16)),
              decoration: const BoxDecoration(
                color: AppColors.deepGreen,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
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
                      final isSelected =
                          appState.languageCode == lang.key;
                      return Padding(
                        padding:
                            EdgeInsets.only(bottom: R.s(context, 6)),
                        child: GestureDetector(
                          onTap: () {
                            appState.setLanguage(lang.key);
                            Navigator.of(sheetContext).pop();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: R.s(context, 12),
                              vertical: R.s(context, 12),
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.gold
                                      .withValues(alpha: 0.2)
                                  : Colors.black
                                      .withValues(alpha: 0.2),
                              borderRadius:
                                  BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.gold
                                    : AppColors.gold
                                        .withValues(alpha: 0.3),
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
          },
        );
      },
    );
  }
}

class _MoreRow extends StatelessWidget {
  const _MoreRow({
    required this.icon,
    required this.title,
    required this.chevron,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final IconData chevron;
  final VoidCallback onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final trailingText = trailing;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cream,
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.softGold.withValues(alpha: 0.85),
                ),
              ),
            const SizedBox(width: 6),
            Icon(
              chevron,
              color: AppColors.softGold.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
