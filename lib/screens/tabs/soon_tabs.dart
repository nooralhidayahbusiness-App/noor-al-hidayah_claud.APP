import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/fonts.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';

class QuranTab extends StatelessWidget {
  const QuranTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonView(
      icon: Icons.menu_book_rounded,
      titleKey: 'tabQuran',
      messageKey: 'quranSoon',
      imagePath: 'assets/images/Quran.png',
    );
  }
}

class AdhkarTab extends StatelessWidget {
  const AdhkarTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonView(
      icon: Icons.auto_stories_rounded,
      titleKey: 'tabAdhkar',
      messageKey: 'adhkarSoon',
    );
  }
}

/// Placeholder card for features that are not built yet.
class ComingSoonView extends StatelessWidget {
  const ComingSoonView({
    super.key,
    required this.icon,
    required this.titleKey,
    required this.messageKey,
    this.imagePath,
  });

  final IconData icon;
  final String titleKey;
  final String messageKey;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final title = appState.tr(titleKey);
        final iconWidget = Icon(icon, size: 64, color: AppColors.gold);
        final path = imagePath;
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (path != null)
                    Image.asset(
                      path,
                      height: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => iconWidget,
                    )
                  else
                    iconWidget,
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: brandStyle(
                      title,
                      fontSize: 30,
                      color: AppColors.softGold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appState.tr(messageKey),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: AppColors.cream.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.gold.withValues(alpha: 0.14),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      appState.tr('soonBadge'),
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
