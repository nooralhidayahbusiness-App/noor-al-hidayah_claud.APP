import 'package:flutter/material.dart';
import '../account_screen.dart';
import '../../core/app_flow.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/glass_card.dart';

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
                    trailing: appState.tr('switchLanguage'),
                    chevron: chevron,
                    onTap: appState.toggleLanguage,
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
    MaterialPageRoute(builder: (_) => const AccountScreen()),
  ),
),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Center(
              child: Text(
                appState.tr('credit'),
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1,
                  color: AppColors.cream.withValues(alpha: 0.45),
                ),
              ),
            ),
          ],
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
