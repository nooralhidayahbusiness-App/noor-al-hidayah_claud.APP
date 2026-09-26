import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import '../services/user_service.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/glass_card.dart';

class ChallengeResultScreen extends StatelessWidget {
  const ChallengeResultScreen({
    super.key,
    required this.correct,
    required this.total,
  });

  final int correct;
  final int total;

  @override
  Widget build(BuildContext context) {
    final points = correct * 20;
    final ratio = correct / total;
    final great = ratio >= 0.8;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.deepGreen, Color(0xFF0A1F17)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  great
                      ? Icons.emoji_events_rounded
                      : Icons.auto_awesome_rounded,
                  size: 90,
                  color: AppColors.gold,
                ),
                const SizedBox(height: 20),
                Text(
                  appState.tr(great ? 'challengeGreatJob' : 'challengeKeepTrying'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.softGold,
                  ),
                ),
                const SizedBox(height: 30),
                GlassCard(
                  child: Column(
                    children: [
                      Text(
                        appState.tr('challengeResult'),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.cream.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$correct',
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              color: AppColors.gold,
                              height: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              ' / $total',
                              style: TextStyle(
                                fontSize: 22,
                                color:
                                    AppColors.cream.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Divider(
                          color: AppColors.gold.withValues(alpha: 0.25)),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.stars_rounded,
                              color: AppColors.gold, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            '+$points ${appState.tr('points')}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                GoldButton(
                  label: appState.tr('challengeBack'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
