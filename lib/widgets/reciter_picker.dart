import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/reciter_prefs.dart';
import '../core/theme.dart';
import '../models/reciter.dart';

/// Bottom sheet to choose a reciter. Returns the chosen reciter, or null.
Future<Reciter?> showReciterPicker(BuildContext context) {
  return showModalBottomSheet<Reciter>(
    context: context,
    backgroundColor: AppColors.deepGreen,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      return ListenableBuilder(
        listenable: Listenable.merge([appState, reciterPrefs]),
        builder: (context, _) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    appState.tr('chooseReciter'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.softGold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.55,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: kReciters.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: AppColors.gold.withValues(alpha: 0.15),
                      ),
                      itemBuilder: (context, index) {
                        final reciter = kReciters[index];
                        final selected = reciterPrefs.reciterId == reciter.id;
                        return ListTile(
                          onTap: () => Navigator.of(sheetContext).pop(reciter),
                          leading: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.gold.withValues(alpha: 0.14),
                              border: Border.all(
                                color: AppColors.gold
                                    .withValues(alpha: selected ? 1 : 0.5),
                                width: selected ? 1.8 : 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.mic_rounded,
                              color: AppColors.gold,
                            ),
                          ),
                          title: Text(
                            appState.isArabic ? reciter.nameAr : reciter.nameEn,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w500,
                              color: selected ? AppColors.gold : AppColors.cream,
                            ),
                          ),
                          trailing: selected
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.gold,
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
