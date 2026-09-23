import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/navigation.dart';
import '../../core/theme.dart';
import '../../models/hadith_section.dart';
import '../../services/hadith_service.dart';
import '../../widgets/ornament_medallion.dart';
import '../hadith_section_screen.dart';

class HadithTab extends StatelessWidget {
  const HadithTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return FutureBuilder<List<HadithSection>>(
          future: HadithService.load(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Text(
                    appState.tr('hadithLoadError'),
                    textAlign: TextAlign.center,
                    style: TextStyle(height: 1.6, color: AppColors.cream.withValues(alpha: 0.8)),
                  ),
                ),
              );
            }
            final sections = snapshot.data;
            if (sections == null) {
              return const Center(child: CircularProgressIndicator(color: AppColors.gold));
            }
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.95,
              ),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                return _SectionTile(
                  section: section,
                  onTap: () => Navigator.of(context).push(fadeRoute(HadithSectionScreen(section: section))),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({required this.section, required this.onTap});

  final HadithSection section;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = appState.isArabic ? section.nameAr : section.nameEn;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OrnamentMedallion(
              size: 88,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Center(
                  child: Text(
                    '${section.hadiths.length}',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.gold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.cream),
            ),
          ],
        ),
      ),
    );
  }
}
