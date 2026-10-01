import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../models/reciter.dart';

/// يُظهر قائمة كل القراء — الكل مجاني.
/// يُرجع ID القارئ المختار، أو null.
Future<String?> showReciterPicker(
  BuildContext context, {
  required String selectedId,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => ReciterPickerSheet(selectedId: selectedId),
  );
}

class ReciterPickerSheet extends StatelessWidget {
  const ReciterPickerSheet({super.key, required this.selectedId});

  final String selectedId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.deepGreen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        R.s(context, 14),
        R.s(context, 12),
        R.s(context, 14),
        R.s(context, 14),
      ),
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
            appState.tr('recitationChooseReciter'),
            style: TextStyle(
              fontSize: R.f(context, 14),
              fontWeight: FontWeight.w700,
              color: AppColors.softGold,
            ),
          ),
          SizedBox(height: R.s(context, 10)),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: ListView.builder(
              itemCount: kReciters.length,
              itemBuilder: (context, i) {
                final r = kReciters[i];
                final selected = r.id == selectedId;
                return Padding(
                  padding: EdgeInsets.only(bottom: R.s(context, 6)),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, r.id),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: R.s(context, 12),
                        vertical: R.s(context, 12),
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.gold.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.gold
                              : AppColors.gold.withValues(alpha: 0.3),
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: R.s(context, 36),
                            height: R.s(context, 36),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  AppColors.gold.withValues(alpha: 0.15),
                              border: Border.all(
                                color:
                                    AppColors.gold.withValues(alpha: 0.6),
                              ),
                            ),
                            child: Icon(
                              Icons.record_voice_over_rounded,
                              color: AppColors.gold,
                              size: R.s(context, 18),
                            ),
                          ),
                          SizedBox(width: R.s(context, 10)),
                          Expanded(
                            child: Text(
                              r.nameAr,
                              style: TextStyle(
                                fontSize: R.f(context, 13.5),
                                fontWeight: FontWeight.w700,
                                color: AppColors.softGold,
                              ),
                            ),
                          ),
                          if (selected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.gold,
                              size: R.s(context, 22),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
