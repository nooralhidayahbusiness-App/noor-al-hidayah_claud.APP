import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../services/user_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/themed_background.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  static const List<Map<String, String>> _dhikrOptions = [
    {
      'ar': 'سُبْحَانَ اللَّهِ',
      'en': 'Glory be to Allah',
    },
    {
      'ar': 'الْحَمْدُ لِلَّهِ',
      'en': 'Praise be to Allah',
    },
    {
      'ar': 'اللَّهُ أَكْبَرُ',
      'en': 'Allah is the Greatest',
    },
    {
      'ar': 'لَا إِلَهَ إِلَّا اللَّهُ',
      'en': 'None has the right to be worshipped but Allah',
    },
    {
      'ar': 'أَسْتَغْفِرُ اللَّهَ',
      'en': 'I seek forgiveness from Allah',
    },
    {
      'ar': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      'en': 'There is no might nor power except with Allah',
    },
    {
      'ar': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
      'en': 'O Allah, send peace upon Muhammad',
    },
  ];

  int _selectedDhikr = 0;
  int _count = 0;
  int _totalAll = 0;
  int _todayTotal = 0;
  int _target = 33;
  bool _loading = true;

  bool get _isTargetReached => _target > 0 && _count >= _target;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _load();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _pulse.dispose();
    super.dispose();
  }

  String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  Future<void> _load() async {
    try {
      final progress = await userService.loadProgress('tasbeeh');
      final lastDate = progress['lastDate'] as String?;
      final todayCount = lastDate == _todayKey()
          ? ((progress['todayCount'] as num?)?.toInt() ?? 0)
          : 0;
      if (mounted) {
        setState(() {
          _totalAll = (progress['totalCount'] as num?)?.toInt() ?? 0;
          _todayTotal = todayCount;
          _count = todayCount;
          _target = (progress['target'] as num?)?.toInt() ?? 33;
          _selectedDhikr = (progress['lastDhikr'] as num?)?.toInt() ?? 0;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    try {
      await userService.saveProgress('tasbeeh', {
        'totalCount': _totalAll,
        'todayCount': _todayTotal,
        'lastDate': _todayKey(),
        'target': _target,
        'lastDhikr': _selectedDhikr,
      });
    } catch (_) {}
  }

  void _increment() {
    HapticFeedback.lightImpact();
    _pulse.forward(from: 0);
    setState(() {
      _count++;
      _todayTotal++;
      _totalAll++;
    });
    if (_count == _target && _target > 0) {
      HapticFeedback.mediumImpact();
    }
    _save();
  }

  Future<void> _reset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepGreen,
        title: Text(
          appState.tr('tasbeehResetTitle'),
          style: const TextStyle(color: AppColors.softGold),
        ),
        content: Text(
          appState.tr('tasbeehResetBody'),
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
    setState(() => _count = 0);
    await _save();
  }

  void _setTarget(int t) {
    setState(() => _target = t);
    _save();
  }

  void _openDhikrPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DhikrPickerSheet(
        options: _dhikrOptions,
        selected: _selectedDhikr,
        onSelect: (i) {
          setState(() {
            _selectedDhikr = i;
            _count = 0;
          });
          _save();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dhikr = _dhikrOptions[_selectedDhikr];
    final dhikrText =
        appState.isArabic ? dhikr['ar']! : dhikr['en']!;

    return Scaffold(
      body: ThemedBackground(
        child: SafeArea(
          child: _loading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.gold))
              : Column(
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
                            onPressed: () =>
                                Navigator.of(context).maybePop(),
                            color: AppColors.softGold,
                            iconSize: R.s(context, 22),
                            icon:
                                const Icon(Icons.arrow_back_rounded),
                          ),
                          const Spacer(),
                          Text(
                            appState.tr('tasbeeh'),
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

                    SizedBox(height: R.s(context, 8)),

                    // ===== الهدف =====
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: R.s(context, 16)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _TargetChip(
                            label: '33',
                            selected: _target == 33,
                            onTap: () => _setTarget(33),
                          ),
                          SizedBox(width: R.s(context, 6)),
                          _TargetChip(
                            label: '100',
                            selected: _target == 100,
                            onTap: () => _setTarget(100),
                          ),
                          SizedBox(width: R.s(context, 6)),
                          _TargetChip(
                            label: appState.tr('tasbeehOpen'),
                            selected: _target == 0,
                            onTap: () => _setTarget(0),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: R.s(context, 16)),

                    // ===== الذكر المختار =====
                    GestureDetector(
                      onTap: _openDhikrPicker,
                      child: GlassCard(
                        child: Row(
                          children: [
                            Icon(
                              Icons.touch_app_rounded,
                              color: AppColors.gold,
                              size: R.s(context, 20),
                            ),
                            SizedBox(width: R.s(context, 10)),
                            Expanded(
                              child: Text(
                                dhikrText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: R.f(context, 18),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.softGold,
                                  height: 1.6,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.unfold_more_rounded,
                              color: AppColors.softGold
                                  .withValues(alpha: 0.7),
                              size: R.s(context, 20),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ===== العداد الكبير =====
                    Expanded(
                      child: Center(
                        child: GestureDetector(
                          onTap: _increment,
                          child: AnimatedBuilder(
                            animation: _pulse,
                            builder: (context, _) {
                              final t = _pulse.value;
                              final scale = 1.0 +
                                  (t < 0.5 ? t : (1 - t)) * 0.10;
                              return Transform.scale(
                                scale: scale,
                                child: _CounterCircle(
                                  count: _count,
                                  target: _target,
                                  done: _isTargetReached,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: R.s(context, 8)),

                    // ===== الإحصائيات =====
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: R.s(context, 16)),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatBox(
                              icon: Icons.today_rounded,
                              label: appState.tr('tasbeehToday'),
                              value: '$_todayTotal',
                            ),
                          ),
                          SizedBox(width: R.s(context, 8)),
                          Expanded(
                            child: _StatBox(
                              icon: Icons.auto_graph_rounded,
                              label: appState.tr('tasbeehTotal'),
                              value: '$_totalAll',
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: R.s(context, 10)),

                    // ===== زر الإعادة =====
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: R.s(context, 16)),
                      child: TextButton.icon(
                        onPressed: _reset,
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: AppColors.softGold,
                          size: R.s(context, 18),
                        ),
                        label: Text(
                          appState.tr('reset'),
                          style: TextStyle(
                            color: AppColors.softGold,
                            fontSize: R.f(context, 13),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: R.s(context, 8)),

                    Text(
                      appState.tr('tasbeehTapAnywhere'),
                      style: TextStyle(
                        fontSize: R.f(context, 10.5),
                        color:
                            AppColors.cream.withValues(alpha: 0.5),
                      ),
                    ),

                    SizedBox(height: R.s(context, 12)),
                  ],
                ),
        ),
      ),
    );
  }
}

class _CounterCircle extends StatelessWidget {
  const _CounterCircle({
    required this.count,
    required this.target,
    required this.done,
  });

  final int count;
  final int target;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final size = R.s(context, 220);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: done
              ? [
                  AppColors.gold.withValues(alpha: 0.35),
                  AppColors.gold.withValues(alpha: 0.08),
                ]
              : [
                  AppColors.gold.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.15),
                ],
        ),
        border: Border.all(
          color: AppColors.gold,
          width: done ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: done ? 0.55 : 0.3),
            blurRadius: done ? 30 : 18,
            spreadRadius: done ? 4 : 0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$count',
            style: GoogleFonts.cinzel(
              fontSize: R.f(context, 72),
              fontWeight: FontWeight.w700,
              color: AppColors.gold,
              height: 1,
            ),
          ),
          if (target > 0) ...[
            SizedBox(height: R.s(context, 6)),
            Text(
              '/ $target',
              style: TextStyle(
                fontSize: R.f(context, 18),
                color: AppColors.softGold.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (done) ...[
            SizedBox(height: R.s(context, 4)),
            Text(
              appState.tr('tasbeehCompleted'),
              style: TextStyle(
                fontSize: R.f(context, 12),
                color: AppColors.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TargetChip extends StatelessWidget {
  const _TargetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: R.s(context, 14),
          vertical: R.s(context, 6),
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.gold
              : AppColors.gold.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.6),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: R.f(context, 12),
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.deepGreen : AppColors.gold,
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
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
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: R.s(context, 22)),
          SizedBox(width: R.s(context, 10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: R.f(context, 11),
                    color: AppColors.cream.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: R.s(context, 2)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: R.f(context, 16),
                    fontWeight: FontWeight.w700,
                    color: AppColors.softGold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DhikrPickerSheet extends StatelessWidget {
  const _DhikrPickerSheet({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final List<Map<String, String>> options;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.deepGreen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.all(R.s(context, 16)),
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
            appState.tr('tasbeehChooseDhikr'),
            style: TextStyle(
              fontSize: R.f(context, 15),
              fontWeight: FontWeight.w700,
              color: AppColors.softGold,
            ),
          ),
          SizedBox(height: R.s(context, 12)),
          ...List.generate(options.length, (i) {
            final opt = options[i];
            final text =
                appState.isArabic ? opt['ar']! : opt['en']!;
            final isSelected = i == selected;
            return Padding(
              padding: EdgeInsets.only(bottom: R.s(context, 6)),
              child: GestureDetector(
                onTap: () => onSelect(i),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: R.s(context, 12),
                    vertical: R.s(context, 10),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.gold.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.gold
                          : AppColors.gold.withValues(alpha: 0.3),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: R.f(context, 14),
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.gold
                                : AppColors.cream,
                            height: 1.5,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded,
                            color: AppColors.gold,
                            size: R.s(context, 18)),
                    ],
                  ),
                ),
              ),
            );
          }),
          SizedBox(height: R.s(context, 8)),
        ],
      ),
    );
  }
}
