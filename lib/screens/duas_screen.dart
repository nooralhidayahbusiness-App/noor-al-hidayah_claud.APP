import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../data/duas.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/themed_background.dart';
import 'duas_detail_screen.dart';

class DuasScreen extends StatelessWidget {
  const DuasScreen({super.key});

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
                  // ===== الهيدر =====
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
                          tooltip: appState.tr('back'),
                          color: AppColors.softGold,
                          iconSize: R.s(context, 22),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const Spacer(),
                        Text(
                          appState.tr('duas'),
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

                  // ===== المحتوى =====
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
                          appState.tr('duasSubtitle'),
                          style: TextStyle(
                            fontSize: R.f(context, 12),
                            color:
                                AppColors.cream.withValues(alpha: 0.7),
                          ),
                        ),
                        SizedBox(height: R.s(context, 14)),
                        ...kDuaCategories.map(
                          (cat) => Padding(
                            padding: EdgeInsets.only(
                                bottom: R.s(context, 10)),
                            child: _CategoryCard(category: cat),
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
  const _CategoryCard({required this.category});

  final DuaCategory category;

  @override
  Widget build(BuildContext context) {
    final name = appState.isArabic ? category.nameAr : category.nameEn;
    final desc = appState.isArabic ? category.descAr : category.descEn;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DuasDetailScreen(category: category),
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
                color: AppColors.gold.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.6),
                ),
              ),
              child: Icon(
                category.icon,
                color: AppColors.gold,
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
                      color: AppColors.gold.withValues(alpha: 0.85),
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
