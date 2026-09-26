import 'package:flutter/material.dart';

import '../core/app_flow.dart';
import '../core/app_state.dart';
import '../core/prayer_state.dart';
import '../core/profile_state.dart';
import '../core/theme.dart';
import '../widgets/app_branding.dart';
import '../widgets/asset_icon.dart';
import '../widgets/auth_widgets.dart';
import 'challenge_screen.dart';
import 'tabs/community_tab.dart';
import 'tabs/home_tab.dart';
import 'tabs/more_tab.dart';
import 'tabs/quran_browser_tab.dart';
import 'tabs/soon_tabs.dart';

/// Main app frame: top bar, six tabs and the bottom navigation bar.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    prayerState.start();
    profileState.load();
  }

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Scaffold(
          body: AppBackground(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(8, 8, 20, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => openLocationPicker(context),
                          tooltip: appState.tr('changeLocation'),
                          color: AppColors.softGold,
                          icon: const Icon(
                              Icons.edit_location_alt_outlined),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            // TODO: شاشة الإعدادات (سنبنيها لاحقاً)
                            showAuthMessage(
                              context,
                              appState.tr('comingSoon'),
                            );
                          },
                          tooltip: appState.tr('settings'),
                          icon: const AssetIcon(
                            path: 'assets/icons/Setting.png',
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const AuthLanguageButton(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: _index,
                      children: [
                        HomeTab(onOpenTab: _select),
                        const QuranBrowserTab(),
                        const AdhkarTab(),
                        const ChallengeScreen(),
                        const CommunityTab(),
                        const MoreTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar:
              _BottomBar(index: _index, onSelected: _select),
        );
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.onSelected});

  final int index;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.gold.withValues(alpha: 0.3)),
        ),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 70,
          backgroundColor: AppColors.deepGreen.withValues(alpha: 0.94),
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.gold.withValues(alpha: 0.18),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? AppColors.gold
                  : AppColors.softGold.withValues(alpha: 0.7),
            ),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: states.contains(WidgetState.selected)
                  ? AppColors.gold
                  : AppColors.softGold.withValues(alpha: 0.7),
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: onSelected,
          labelBehavior:
              NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: appState.tr('tabHome'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              selectedIcon: const Icon(Icons.menu_book_rounded),
              label: appState.tr('tabQuran'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.auto_stories_outlined),
              selectedIcon: const Icon(Icons.auto_stories_rounded),
              label: appState.tr('tabAdhkar'),
            ),
            NavigationDestination(
              icon: const AssetIcon(
                path: 'assets/icons/challenge.png',
                size: 26,
                opacity: 0.75,
              ),
              selectedIcon: const AssetIcon(
                path: 'assets/icons/challenge.png',
                size: 26,
              ),
              label: appState.tr('tabChallenge'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.groups_outlined),
              selectedIcon: const Icon(Icons.groups_rounded),
              label: appState.tr('tabCommunity'),
            ),
            NavigationDestination(
              icon: const AssetIcon(
                path: 'assets/icons/more.png',
                size: 26,
                opacity: 0.75,
              ),
              selectedIcon: const AssetIcon(
                path: 'assets/icons/more.png',
                size: 26,
              ),
              label: appState.tr('tabMore'),
            ),
          ],
        ),
      ),
    );
  }
}
