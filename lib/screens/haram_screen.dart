import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../data/haram.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/themed_background.dart';
import 'prohibition_detail_screen.dart';

class HaramScreen extends StatelessWidget {
  const HaramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ProhibitionListScreen(
      titleKey: 'haram',
      subtitleKey: 'haramSubtitle',
      categories: kHaramCategories,
      accent: const Color(0xFFFF8A80),
      accentIcon: Icons.block_rounded,
    );
  }
}

class MakruhScreen extends StatelessWidget {
  const MakruhScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ProhibitionListScreen(
      titleKey: 'makruh',
      subtitleKey: 'makruhSubtitle',
      categories: kMakruhCategories,
      accent: AppColors.softGold,
      accentIcon: Icons.warning_amber_rounded,
    );
  }
}

class _ProhibitionListScreen extends StatelessWidget {
  const _ProhibitionListScreen({
    required this.titleKey,
    required this.subtitleKey,
    required this.categories,
    required this.accent,
    required this.accentIcon,
  });

  final String titleKey;
  final String subtitleKey;
  final List<ProhibitionCategory> categories;
  final Color accent;
  final IconData accentIcon;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Scaffold(
          body: ThemedBackground(
            child: SafeArea(
              child: Column(
                children: [
                  // الهيدر
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
                          onPressed: () =>
                              Navigator.of(context).maybePop(),
                          color: AppColors.softGold,
                          iconSize: R.s(context, 22),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const Spacer(),
                        Text(
                          appState.tr(titleKey),
                          style: TextStyle(
                            fontSize: R.f(context, 15),
                            fontWeight: FontWeight.w700,
                            color: AppColors.softGold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const AuthLanguageButton(),
                      ],
                    ),
                  ),
                  SizedBox(height: R.s(context, 6)),

                  // المحتوى
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        R.s(context, 16),
                        R.s(context, 4),
                        R.s(context, 16),
                        R.s(context, 20),
                      ),
                      children: [
                        Text(
                          appState.tr(subtitleKey),
                          style: TextStyle(
                            fontSize: R.f(context, 12),
                            color:
                                AppColors.cream.withValues(alpha: 0.7),
                          ),
                        ),
                        SizedBox(height: R.s(context, 14)),
                        ...categories.map(
                          (cat) => Padding(
                            padding: EdgeInsets.only(
                                bottom: R.s(context, 10)),
                            child: _CategoryCard(
                              category: cat,
                              accent: accent,
                              accentIcon: accentIcon,
                            ),
                          ),
                        ),
                      ],
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

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.accent,
    required this.accentIcon,
  });

  final ProhibitionCategory category;
  final Color accent;
  final IconData accentIcon;

  @override
  Widget build(BuildContext context) {
    final name = appState.isArabic ? category.nameAr : category.nameEn;
    final desc = appState.isArabic ? category.descAr : category.descEn;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProhibitionDetailScreen(
            category: category,
            accent: accent,
          ),
        ),
      ),
      child: GlassCard(
        child: Row(
          children: [
            Container(
              width: R.s(context, 56),
              height: R.s(context, 56),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.15),
                border: Border.all(
                  color: accent.withValues(alpha: 0.6),
                ),
              ),
              child: Icon(
                category.icon,
                color: accent,
                size: R.s(context, 26),
              ),
            ),
            SizedBox(width: R.s(context, 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: R.f(context, 16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.softGold,
                    ),
                  ),
                  SizedBox(height: R.s(context, 3)),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: R.f(context, 11.5),
                      color: AppColors.cream.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: R.s(context, 4)),
                  Text(
                    '${category.items.length} ${appState.tr('items')}',
                    style: TextStyle(
                      fontSize: R.f(context, 10.5),
                      color: accent.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.softGold.withValues(alpha: 0.7),
              size: R.s(context, 24),
            ),
          ],
        ),
      ),
    );
  }
}
