import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import '../widgets/app_branding.dart';
import '../widgets/auth_widgets.dart';
import 'tabs/prayer_times_tab.dart';

/// Full-screen prayer times, opened from the quick access on the home tab.
class PrayerTimesPage extends StatelessWidget {
  const PrayerTimesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Scaffold(
          body: AppBackground(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 20, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          tooltip: appState.tr('back'),
                          color: AppColors.softGold,
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const Spacer(),
                        const AuthLanguageButton(),
                      ],
                    ),
                  ),
                  const Expanded(child: PrayerTimesTab()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
