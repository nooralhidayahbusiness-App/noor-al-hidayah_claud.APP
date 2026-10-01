import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../services/verification_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/themed_background.dart';
import 'verification_requests_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _pending = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final count = await verificationService.pendingCount();
    if (mounted) {
      setState(() {
        _pending = count;
        _loading = false;
      });
    }
  }

  Future<void> _openRequests() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const VerificationRequestsScreen(),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThemedBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  R.s(context, 6),
                  R.s(context, 6),
                  R.s(context, 16),
                  0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      color: AppColors.softGold,
                      iconSize: R.s(context, 22),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Spacer(),
                    Text(
                      appState.tr('adminPanel'),
                      style: TextStyle(
                        fontSize: R.f(context, 15),
                        fontWeight: FontWeight.w700,
                        color: AppColors.softGold,
                      ),
                    ),
                    SizedBox(width: R.s(context, 40)),
                  ],
                ),
              ),
              SizedBox(height: R.s(context, 6)),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.gold))
                    : ListView(
                        padding: EdgeInsets.all(R.s(context, 20)),
                        children: [
                          GlassCard(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.admin_panel_settings_rounded,
                                  color: AppColors.gold,
                                  size: R.s(context, 56),
                                ),
                                SizedBox(height: R.s(context, 12)),
                                Text(
                                  appState.tr('adminPanel'),
                                  style: TextStyle(
                                    fontSize: R.f(context, 18),
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.softGold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: R.s(context, 14)),

                          // طلبات التوثيق
                          GestureDetector(
                            onTap: _openRequests,
                            child: GlassCard(
                              ornament: false,
                              child: Row(
                                children: [
                                  Container(
                                    width: R.s(context, 48),
                                    height: R.s(context, 48),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.gold
                                          .withValues(alpha: 0.15),
                                      border: Border.all(
                                        color: AppColors.gold
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.verified_user_rounded,
                                      color: AppColors.gold,
                                      size: R.s(context, 24),
                                    ),
                                  ),
                                  SizedBox(width: R.s(context, 12)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          appState.tr(
                                              'adminVerificationRequests'),
                                          style: TextStyle(
                                            fontSize: R.f(context, 14),
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.softGold,
                                          ),
                                        ),
                                        SizedBox(
                                            height: R.s(context, 3)),
                                        Text(
                                          _pending > 0
                                              ? '$_pending ${appState.tr('adminPending')}'
                                              : appState.tr(
                                                  'adminNoRequests'),
                                          style: TextStyle(
                                            fontSize: R.f(context, 11.5),
                                            color: _pending > 0
                                                ? AppColors.gold
                                                : AppColors.cream
                                                    .withValues(
                                                        alpha: 0.6),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_pending > 0)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: R.s(context, 10),
                                        vertical: R.s(context, 4),
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD32F2F),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '$_pending',
                                        style: TextStyle(
                                          fontSize: R.f(context, 12),
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  SizedBox(width: R.s(context, 6)),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.softGold
                                        .withValues(alpha: 0.7),
                                    size: R.s(context, 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
