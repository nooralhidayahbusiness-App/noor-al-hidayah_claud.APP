import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../services/khatm_service.dart';
import '../services/user_service.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/glass_card.dart';
import '../widgets/themed_background.dart';

class KhatmPlanScreen extends StatefulWidget {
  const KhatmPlanScreen({super.key});

  @override
  State<KhatmPlanScreen> createState() => _KhatmPlanScreenState();
}

class _KhatmPlanScreenState extends State<KhatmPlanScreen> {
  bool _loading = true;
  KhatmPlan _plan = KhatmPlan.empty;
  bool _showSetup = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final p = await khatmService.load();
    if (mounted) {
      setState(() {
        _plan = p;
        _showSetup = !p.active;
        _loading = false;
      });
    }
  }

  Future<void> _startPlan(int days) async {
    final perDay = (604 / days).ceil();
    await khatmService.startPlan(days: days, pagesPerDay: perDay);
    await _load();
  }

  Future<void> _openUpdateDialog() async {
    final controller = TextEditingController(
      text: _plan.lastReadPage == 0 ? '' : '${_plan.lastReadPage}',
    );
    final page = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepGreen,
        title: Text(
          appState.tr('khatmUpdateTitle'),
          style: const TextStyle(color: AppColors.softGold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              appState.tr('khatmUpdateBody'),
              style: TextStyle(
                color: AppColors.cream.withValues(alpha: 0.8),
                fontSize: R.f(context, 12),
              ),
            ),
            SizedBox(height: R.s(context, 12)),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: AppColors.cream),
              decoration: InputDecoration(
                hintText: '1 - 604',
                hintStyle: TextStyle(
                    color: AppColors.cream.withValues(alpha: 0.4)),
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.25),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: AppColors.gold.withValues(alpha: 0.4)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(appState.tr('cancel'),
                style: const TextStyle(color: AppColors.softGold)),
          ),
          TextButton(
            onPressed: () {
              final n = int.tryParse(controller.text.trim());
              if (n == null) return;
              Navigator.pop(ctx, n);
            },
            child: Text(appState.tr('save'),
                style: const TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
    if (page == null) return;
    if (page < 1 || page > 604) {
      if (mounted) {
        showAuthMessage(context, appState.tr('khatmInvalidPage'),
            error: true);
      }
      return;
    }

    final delta = await khatmService.updatePage(plan: _plan, newPage: page);
    await _load();

    if (!mounted) return;
    if (delta > 0) {
      HapticFeedback.mediumImpact();
      showAuthMessage(
        context,
        '${appState.tr('khatmAdded')} $delta ${appState.tr('khatmPages')} ✓',
      );
    }

    // لو كمل الختمة
    if (_plan.isComplete) {
      await _celebrate();
    }
  }

  Future<void> _celebrate() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepGreen,
        title: Row(
          children: [
            const Icon(Icons.celebration_rounded,
                color: AppColors.gold, size: 24),
            const SizedBox(width: 8),
            Text(
              appState.tr('khatmCompleteTitle'),
              style: const TextStyle(color: AppColors.softGold),
            ),
          ],
        ),
        content: Text(
          appState.tr('khatmCompleteBody'),
          style: const TextStyle(color: AppColors.cream, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await khatmService.completeKhatma(_plan);
              await _load();
            },
            child: Text(
              appState.tr('khatmStartNew'),
              style: const TextStyle(color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _reset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepGreen,
        title: Text(
          appState.tr('khatmResetTitle'),
          style: const TextStyle(color: AppColors.softGold),
        ),
        content: Text(
          appState.tr('khatmResetBody'),
          style: const TextStyle(color: AppColors.cream),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(appState.tr('cancel'),
                style: const TextStyle(color: AppColors.softGold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(appState.tr('reset'),
                style: const TextStyle(color: Color(0xFFFF8A80))),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await khatmService.reset();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThemedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ===== الهيدر =====
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
                      appState.tr('khatmPlan'),
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
                    : _showSetup
                        ? _SetupView(onStart: _startPlan)
                        : _ActiveView(
                            plan: _plan,
                            onUpdate: _openUpdateDialog,
                            onReset: _reset,
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== شاشة الإعداد ====================
class _SetupView extends StatelessWidget {
  const _SetupView({required this.onStart});

  final ValueChanged<int> onStart;

  @override
  Widget build(BuildContext context) {
    final options = [
      _Option(days: 30, labelAr: '30 يوم', labelEn: '30 days', subAr: '~21 صفحة/يوم', subEn: '~21 pages/day'),
      _Option(days: 60, labelAr: '60 يوم', labelEn: '60 days', subAr: '~11 صفحة/يوم', subEn: '~11 pages/day'),
      _Option(days: 90, labelAr: '90 يوم', labelEn: '90 days', subAr: '~7 صفحات/يوم', subEn: '~7 pages/day'),
      _Option(days: 180, labelAr: '180 يوم', labelEn: '180 days', subAr: '~4 صفحات/يوم', subEn: '~4 pages/day'),
    ];

    return ListView(
      padding: EdgeInsets.all(R.s(context, 16)),
      children: [
        GlassCard(
          child: Column(
            children: [
              Icon(Icons.auto_stories_rounded,
                  color: AppColors.gold, size: R.s(context, 40)),
              SizedBox(height: R.s(context, 10)),
              Text(
                appState.tr('khatmWelcome'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.f(context, 18),
                  fontWeight: FontWeight.w700,
                  color: AppColors.softGold,
                ),
              ),
              SizedBox(height: R.s(context, 6)),
              Text(
                appState.tr('khatmWelcomeDesc'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.f(context, 12),
                  height: 1.6,
                  color: AppColors.cream.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: R.s(context, 14)),
        Text(
          appState.tr('khatmChooseDuration'),
          style: TextStyle(
            fontSize: R.f(context, 14),
            fontWeight: FontWeight.w700,
            color: AppColors.softGold,
          ),
        ),
        SizedBox(height: R.s(context, 10)),
        ...options.map((o) => Padding(
              padding: EdgeInsets.only(bottom: R.s(context, 10)),
              child: GestureDetector(
                onTap: () => onStart(o.days),
                child: GlassCard(
                  child: Row(
                    children: [
                      Container(
                        width: R.s(context, 50),
                        height: R.s(context, 50),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gold.withValues(alpha: 0.15),
                          border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.6)),
                        ),
                        child: Center(
                          child: Text(
                            '${o.days}',
                            style: TextStyle(
                              fontSize: R.f(context, 16),
                              fontWeight: FontWeight.w900,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: R.s(context, 12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appState.isArabic ? o.labelAr : o.labelEn,
                              style: TextStyle(
                                fontSize: R.f(context, 15),
                                fontWeight: FontWeight.w700,
                                color: AppColors.softGold,
                              ),
                            ),
                            SizedBox(height: R.s(context, 2)),
                            Text(
                              appState.isArabic ? o.subAr : o.subEn,
                              style: TextStyle(
                                fontSize: R.f(context, 11.5),
                                color: AppColors.cream
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_rounded,
                          color: AppColors.gold.withValues(alpha: 0.8),
                          size: R.s(context, 20)),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

class _Option {
  final int days;
  final String labelAr;
  final String labelEn;
  final String subAr;
  final String subEn;

  const _Option({
    required this.days,
    required this.labelAr,
    required this.labelEn,
    required this.subAr,
    required this.subEn,
  });
}

// ==================== الشاشة الرئيسية للخطة النشطة ====================
class _ActiveView extends StatelessWidget {
  const _ActiveView({
    required this.plan,
    required this.onUpdate,
    required this.onReset,
  });

  final KhatmPlan plan;
  final VoidCallback onUpdate;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final percent = (plan.progress * 100).toStringAsFixed(1);

    return ListView(
      padding: EdgeInsets.all(R.s(context, 16)),
      children: [
        // ===== الدائرة الكبيرة =====
        Center(
          child: _ProgressCircle(plan: plan),
        ),

        SizedBox(height: R.s(context, 16)),

        // ===== ورد اليوم =====
        GlassCard(
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.today_rounded,
                      color: AppColors.gold, size: R.s(context, 18)),
                  SizedBox(width: R.s(context, 6)),
                  Text(
                    appState.tr('khatmTodayWard'),
                    style: TextStyle(
                      fontSize: R.f(context, 13),
                      fontWeight: FontWeight.w700,
                      color: AppColors.softGold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${plan.todayRead} / ${plan.todayWard}',
                    style: TextStyle(
                      fontSize: R.f(context, 13),
                      fontWeight: FontWeight.w700,
                      color: plan.todayRemaining == 0
                          ? AppColors.gold
                          : AppColors.cream,
                    ),
                  ),
                ],
              ),
              SizedBox(height: R.s(context, 8)),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: plan.todayWard == 0
                      ? 0
                      : (plan.todayRead / plan.todayWard).clamp(0.0, 1.0),
                  minHeight: R.s(context, 8),
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.gold),
                ),
              ),
              SizedBox(height: R.s(context, 6)),
              Text(
                plan.todayRemaining == 0
                    ? appState.tr('khatmTodayDone')
                    : '${appState.tr('khatmTodayRemaining')} ${plan.todayRemaining} ${appState.tr('khatmPages')}',
                style: TextStyle(
                  fontSize: R.f(context, 11),
                  color: plan.todayRemaining == 0
                      ? AppColors.gold
                      : AppColors.cream.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: R.s(context, 12)),

        // ===== الإحصائيات =====
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.local_fire_department_rounded,
                label: appState.tr('streak'),
                value: '${plan.streak}',
              ),
            ),
            SizedBox(width: R.s(context, 8)),
            Expanded(
              child: _StatCard(
                icon: Icons.event_available_rounded,
                label: appState.tr('khatmDaysLeft'),
                value: '${plan.daysLeft}',
              ),
            ),
            SizedBox(width: R.s(context, 8)),
            Expanded(
              child: _StatCard(
                icon: Icons.trending_up_rounded,
                label: appState.tr('khatmPercent'),
                value: '$percent%',
              ),
            ),
          ],
        ),

        SizedBox(height: R.s(context, 12)),

        // ===== الصفحة الحالية =====
        GlassCard(
          child: Row(
            children: [
              Icon(Icons.bookmark_rounded,
                  color: AppColors.gold, size: R.s(context, 22)),
              SizedBox(width: R.s(context, 10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appState.tr('khatmCurrentPage'),
                      style: TextStyle(
                        fontSize: R.f(context, 11.5),
                        color: AppColors.cream.withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: R.s(context, 2)),
                    Text(
                      '${plan.lastReadPage} / 604',
                      style: TextStyle(
                        fontSize: R.f(context, 18),
                        fontWeight: FontWeight.w900,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.menu_book_rounded,
                  color: AppColors.gold.withValues(alpha: 0.6),
                  size: R.s(context, 30)),
            ],
          ),
        ),

        SizedBox(height: R.s(context, 16)),

        // ===== زر التحديث =====
        ElevatedButton.icon(
          onPressed: onUpdate,
          icon: Icon(Icons.edit_rounded, size: R.s(context, 20)),
          label: Text(
            appState.tr('khatmUpdatePage'),
            style: TextStyle(
              fontSize: R.f(context, 15),
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.deepGreen,
            minimumSize: Size.fromHeight(R.s(context, 56)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 6,
            shadowColor: AppColors.gold,
          ),
        ),

        SizedBox(height: R.s(context, 8)),

        // ===== زر الإعادة =====
        TextButton.icon(
          onPressed: onReset,
          icon: Icon(Icons.refresh_rounded,
              color: AppColors.softGold, size: R.s(context, 18)),
          label: Text(
            appState.tr('khatmResetPlan'),
            style: TextStyle(
              color: AppColors.softGold,
              fontSize: R.f(context, 13),
            ),
          ),
        ),

        // ===== سجل آخر 7 أيام =====
        if (plan.history.isNotEmpty) ...[
          SizedBox(height: R.s(context, 8)),
          Text(
            appState.tr('khatmHistory'),
            style: TextStyle(
              fontSize: R.f(context, 13),
              fontWeight: FontWeight.w700,
              color: AppColors.softGold,
            ),
          ),
          SizedBox(height: R.s(context, 8)),
          ...plan.history.reversed.take(7).map((h) {
            final date = h['date'] as String? ?? '';
            final pages = (h['pages'] as num?)?.toInt() ?? 0;
            return Padding(
              padding: EdgeInsets.only(bottom: R.s(context, 6)),
              child: GlassCard(
                ornament: false,
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: AppColors.gold, size: R.s(context, 16)),
                    SizedBox(width: R.s(context, 8)),
                    Expanded(
                      child: Text(
                        date,
                        style: TextStyle(
                          fontSize: R.f(context, 12),
                          color: AppColors.cream,
                        ),
                      ),
                    ),
                    Text(
                      '$pages ${appState.tr('khatmPages')}',
                      style: TextStyle(
                        fontSize: R.f(context, 12),
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],

        SizedBox(height: R.s(context, 20)),
      ],
    );
  }
}

class _ProgressCircle extends StatelessWidget {
  const _ProgressCircle({required this.plan});

  final KhatmPlan plan;

  @override
  Widget build(BuildContext context) {
    final size = R.s(context, 180);
    final percent = (plan.progress * 100).toStringAsFixed(1);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: plan.progress,
              strokeWidth: R.s(context, 10),
              backgroundColor: Colors.black.withValues(alpha: 0.3),
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.gold),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: R.f(context, 30),
                  fontWeight: FontWeight.w900,
                  color: AppColors.gold,
                  height: 1,
                ),
              ),
              SizedBox(height: R.s(context, 4)),
              Text(
                '${plan.pagesRead} / ${plan.totalPages}',
                style: TextStyle(
                  fontSize: R.f(context, 12),
                  color: AppColors.cream.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: R.s(context, 2)),
              Text(
                appState.tr('khatmPages'),
                style: TextStyle(
                  fontSize: R.f(context, 10),
                  color: AppColors.cream.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      ornament: false,
      child: Column(
        children: [
          Icon(icon, color: AppColors.gold, size: R.s(context, 20)),
          SizedBox(height: R.s(context, 6)),
          Text(
            value,
            style: TextStyle(
              fontSize: R.f(context, 16),
              fontWeight: FontWeight.w900,
              color: AppColors.softGold,
            ),
          ),
          SizedBox(height: R.s(context, 2)),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: R.f(context, 9.5),
              color: AppColors.cream.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
