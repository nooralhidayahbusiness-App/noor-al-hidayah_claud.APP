import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_state.dart';
import '../core/fonts.dart';
import '../core/theme.dart';
import '../models/hadith_section.dart';
import '../widgets/app_branding.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/glass_card.dart';

class HadithSectionScreen extends StatelessWidget {
  const HadithSectionScreen({super.key, required this.section});

  final HadithSection section;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final title = appState.isArabic ? section.nameAr : section.nameEn;
        return Scaffold(
          body: AppBackground(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          tooltip: appState.tr('back'),
                          color: AppColors.softGold,
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        Expanded(
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: brandStyle(title, fontSize: 24, color: AppColors.softGold),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: section.hadiths.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _HadithCard(item: section.hadiths[index]),
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

class _HadithCard extends StatelessWidget {
  const _HadithCard({required this.item});

  final HadithItem item;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final text = appState.isArabic ? item.arabic : item.english;
        return GlassCard(
          ornament: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.chapter,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gold),
                    ),
                  ),
                  IconButton(
                    tooltip: appState.tr('copy'),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: text));
                      if (context.mounted) showAuthMessage(context, appState.tr('copied'));
                    },
                    icon: Icon(Icons.copy_rounded, size: 19, color: AppColors.gold.withValues(alpha: 0.8)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                text,
                textDirection: appState.isArabic ? TextDirection.rtl : TextDirection.ltr,
                textAlign: appState.isArabic ? TextAlign.right : TextAlign.left,
                style: appState.isArabic
                    ? GoogleFonts.notoNaskhArabic(fontSize: 17, height: 1.9, color: AppColors.cream.withValues(alpha: 0.92))
                    : TextStyle(fontSize: 15, height: 1.65, color: AppColors.cream.withValues(alpha: 0.88)),
              ),
            ],
          ),
        );
      },
    );
  }
}
