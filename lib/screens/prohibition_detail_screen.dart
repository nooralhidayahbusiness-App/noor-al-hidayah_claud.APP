import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../data/haram.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/themed_background.dart';

class ProhibitionDetailScreen extends StatelessWidget {
  const ProhibitionDetailScreen({
    super.key,
    required this.category,
    required this.accent,
  });

  final ProhibitionCategory category;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final title = appState.isArabic ? category.nameAr : category.nameEn;

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
                      color: AppColors.softGold,
                      iconSize: R.s(context, 22),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Spacer(),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: R.f(context, 15),
                          fontWeight: FontWeight.w700,
                          color: AppColors.softGold,
                        ),
                      ),
                    ),
                    SizedBox(width: R.s(context, 40)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(R.s(context, 16)),
                  itemCount: category.items.length,
                  itemBuilder: (context, i) => Padding(
                    padding: EdgeInsets.only(bottom: R.s(context, 12)),
                    child: _ProhibitionCard(
                      item: category.items[i],
                      index: i + 1,
                      accent: accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProhibitionCard extends StatelessWidget {
  const _ProhibitionCard({
    required this.item,
    required this.index,
    required this.accent,
  });

  final ProhibitionItem item;
  final int index;
  final Color accent;

  Future<void> _copy(BuildContext context) async {
    final title = appState.isArabic ? item.titleAr : item.titleEn;
    final desc = appState.isArabic ? item.descAr : item.descEn;
    final evidence =
        appState.isArabic ? item.evidenceAr : item.evidenceEn;

    final buffer = StringBuffer()
      ..writeln('❌ $title')
      ..writeln()
      ..writeln(desc)
      ..writeln()
      ..writeln('📖 $evidence')
      ..write('(${item.reference})');

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.deepGreen,
            content: Text(
              appState.tr('copied'),
              style: const TextStyle(color: AppColors.cream),
            ),
          ),
        );
    }
  }

  Future<void> _share(BuildContext context) async {
    await _copy(context);
  }

  @override
  Widget build(BuildContext context) {
    final title = appState.isArabic ? item.titleAr : item.titleEn;
    final desc = appState.isArabic ? item.descAr : item.descEn;
    final evidence =
        appState.isArabic ? item.evidenceAr : item.evidenceEn;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // رأس البطاقة
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: R.s(context, 8),
                  vertical: R.s(context, 3),
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.6),
                  ),
                ),
                child: Text(
                  '$index',
                  style: TextStyle(
                    color: accent,
                    fontSize: R.f(context, 11),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: R.s(context, 8)),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: R.f(context, 15),
                    fontWeight: FontWeight.w700,
                    color: AppColors.softGold,
                    height: 1.3,
                  ),
                ),
              ),
              IconButton(
                tooltip: appState.tr('copy'),
                onPressed: () => _copy(context),
                icon: Icon(
                  Icons.copy_rounded,
                  color: accent.withValues(alpha: 0.85),
                  size: R.s(context, 18),
                ),
              ),
              IconButton(
                tooltip: appState.tr('share'),
                onPressed: () => _share(context),
                icon: Icon(
                  Icons.share_rounded,
                  color: accent.withValues(alpha: 0.85),
                  size: R.s(context, 18),
                ),
              ),
            ],
          ),

          SizedBox(height: R.s(context, 8)),

          // الوصف
          Text(
            desc,
            textAlign: appState.isArabic
                ? TextAlign.right
                : TextAlign.left,
            textDirection: appState.isArabic
                ? TextDirection.rtl
                : TextDirection.ltr,
            style: TextStyle(
              fontSize: R.f(context, 13),
              height: 1.8,
              color: AppColors.cream.withValues(alpha: 0.92),
            ),
          ),

          SizedBox(height: R.s(context, 10)),

          // الدليل
          Container(
            padding: EdgeInsets.all(R.s(context, 10)),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: accent.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      color: accent,
                      size: R.s(context, 14),
                    ),
                    SizedBox(width: R.s(context, 6)),
                    Text(
                      appState.tr('evidence'),
                      style: TextStyle(
                        fontSize: R.f(context, 10.5),
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: R.s(context, 6)),
                Text(
                  evidence,
                  textAlign: TextAlign.center,
                  textDirection: appState.isArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: TextStyle(
                    fontSize: R.f(context, 12),
                    height: 1.7,
                    color: AppColors.softGold.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: R.s(context, 4)),
                Text(
                  item.reference,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: R.f(context, 10),
                    color: AppColors.cream.withValues(alpha: 0.55),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
