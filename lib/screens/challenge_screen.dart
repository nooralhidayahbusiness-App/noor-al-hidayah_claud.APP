import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import '../services/user_service.dart';
import '../widgets/asset_icon.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/glass_card.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  bool _loading = true;
  int _todayPoints = 0;
  int _totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final stats = await userService.loadStats();
      if (mounted) {
        setState(() {
          _totalPoints = (stats['points'] as num?)?.toInt() ?? 0;
          _todayPoints = 0; // سنحسبها من progress.challenges لاحقاً
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openCouponDialog() async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepGreen,
        title: Row(
          children: [
            const AssetIcon(path: 'assets/icons/coupon.png', size: 24),
            const SizedBox(width: 10),
            Text(
              appState.tr('redeemCoupon'),
              style: const TextStyle(color: AppColors.softGold),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(color: AppColors.cream),
          decoration: InputDecoration(
            hintText: appState.tr('enterCouponCode'),
            hintStyle: TextStyle(color: AppColors.cream.withValues(alpha: 0.4)),
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.25),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: AppColors.gold.withValues(alpha: 0.4)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(appState.tr('cancel'),
                style: const TextStyle(color: AppColors.softGold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(appState.tr('redeem'),
                style: const TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );

    if (code == null || code.isEmpty) return;

    // كود NAH2026 = 1000 نقطة
    if (code.toUpperCase() == 'NAH2026') {
      await userService.addPoints(1000);
      if (!mounted) return;
      showAuthMessage(context, appState.tr('couponSuccess'));
      await _load();
    } else {
      if (!mounted) return;
      showAuthMessage(context, appState.tr('couponInvalid'), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              children: [
                const AssetIcon(path: 'assets/icons/challenge.png', size: 34),
                const SizedBox(width: 12),
                Text(
                  appState.tr('challenges'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.softGold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars_rounded,
                          color: AppColors.gold, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$_totalPoints',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_loading)
              const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.gold))
            else
              GlassCard(
                child: Column(
                  children: [
                    const Icon(Icons.quiz_rounded,
                        color: AppColors.gold, size: 44),
                    const SizedBox(height: 12),
                    Text(
                      appState.tr('dailyChallengeTitle'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.softGold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appState.tr('dailyChallengeDesc'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.cream.withValues(alpha: 0.75),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$_todayPoints / 100',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GoldButton(
                      label: appState.tr('startChallenge'),
                      onPressed: () {
                        showAuthMessage(
                            context, appState.tr('comingSoon'));
                      },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            GlassCard(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _openCouponDialog,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const AssetIcon(
                          path: 'assets/icons/coupon.png', size: 34),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appState.tr('redeemCoupon'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.softGold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              appState.tr('redeemCouponDesc'),
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    AppColors.cream.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: AppColors.softGold.withValues(alpha: 0.7)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
