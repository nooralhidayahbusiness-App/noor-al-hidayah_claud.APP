import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/theme.dart';
import 'channel_view.dart';
import 'soon_tabs.dart';

enum _Section { community, channel }

/// Bottom tab with two sections: the community and "قناتي".
class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  _Section _section = _Section.community;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: AppColors.deepGreen.withValues(alpha: 0.65),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SwitchButton(
                        label: appState.tr('tabCommunity'),
                        active: _section == _Section.community,
                        onTap: () =>
                            setState(() => _section = _Section.community),
                      ),
                    ),
                    Expanded(
                      child: _SwitchButton(
                        label: appState.tr('myChannel'),
                        active: _section == _Section.channel,
                        onTap: () =>
                            setState(() => _section = _Section.channel),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _section == _Section.community
                    ? const ComingSoonView(
                        key: ValueKey('community'),
                        icon: Icons.groups_rounded,
                        titleKey: 'tabCommunity',
                        messageKey: 'communitySoon',
                      )
                    : const ChannelView(key: ValueKey('channel')),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SwitchButton extends StatelessWidget {
  const _SwitchButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: active ? AppColors.gold : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: active ? AppColors.deepGreen : AppColors.softGold,
          ),
        ),
      ),
    );
  }
}
