import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/profile_state.dart';
import '../core/theme.dart';
import 'ornament_medallion.dart';

/// Bottom sheet to choose the profile picture.
Future<void> showAvatarPicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.deepGreen,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      return ListenableBuilder(
        listenable: Listenable.merge([appState, profileState]),
        builder: (context, _) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    appState.tr('chooseAvatar'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.softGold,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _AvatarChoice(
                        value: 'man',
                        imagePath: 'assets/images/arabian.png',
                        label: appState.tr('avatarMan'),
                        onTap: () {
                          profileState.setAvatar('man');
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                      _AvatarChoice(
                        value: 'woman',
                        imagePath: 'assets/images/hijab.png',
                        label: appState.tr('avatarWoman'),
                        onTap: () {
                          profileState.setAvatar('woman');
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _AvatarChoice extends StatelessWidget {
  const _AvatarChoice({
    required this.value,
    required this.imagePath,
    required this.label,
    required this.onTap,
  });

  final String value;
  final String imagePath;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = profileState.avatar == value;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OrnamentMedallion(
            size: 112,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.person_rounded,
                color: AppColors.gold,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.gold : AppColors.cream,
            ),
          ),
        ],
      ),
    );
  }
}
