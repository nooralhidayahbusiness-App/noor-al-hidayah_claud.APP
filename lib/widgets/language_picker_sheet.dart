import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';

/// اللغات السبع المدعومة
const List<MapEntry<String, String>> kSupportedLanguages = [
  MapEntry('ar', 'العربية'),
  MapEntry('en', 'English'),
  MapEntry('fr', 'Français'),
  MapEntry('ur', 'اردو'),
  MapEntry('ne', 'नेपाली'),
  MapEntry('id', 'Bahasa Indonesia'),
  MapEntry('ms', 'Bahasa Melayu'),
];

/// اسم اللغة الحالية (للتصنيف السريع)
String currentLanguageLabel() {
  final code = appState.languageCode;
  for (final l in kSupportedLanguages) {
    if (l.key == code) return l.value;
  }
  return 'العربية';
}

/// يفتح bottom sheet لاختيار اللغة (7 لغات)
Future<void> showLanguagePicker(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return Directionality(
            textDirection: appState.direction,
            child: Container(
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
                    ...kSupportedLanguages.map((lang) {
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
            ),
          );
        },
      );
    },
  );
}
