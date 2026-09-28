import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../data/adhkar.dart';
import '../widgets/glass_card.dart';
import '../widgets/themed_background.dart';

class AdhkarDetailScreen extends StatelessWidget {
  const AdhkarDetailScreen({super.key, required this.category});

  final AdhkarCategory category;

  @override
  Widget build(BuildContext context) {
    final title = appState.isArabic ? category.nameAr : category.nameEn;

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
                      onPressed: () =>
                          Navigator.of(context).maybePop(),
                      color: AppColors.softGold,
                      iconSize: R.s(context, 22),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Spacer(),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: R.f(context, 15),
                          fontWeight: FontWeight.w700,
                          color: AppColors.softGold,
                        ),
                      ),
                    ),
                    SizedBox(width: R.s(context, 40)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(R.s(context, 16)),
                  itemCount: category.items.length,
                  itemBuilder: (context, i) => Padding(
                    padding: EdgeInsets.only(bottom: R.s(context, 12)),
                    child: _DhikrCard(
                      dhikr: category.items[i],
                      index: i + 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DhikrCard extends StatefulWidget {
  const _DhikrCard({required this.dhikr, required this.index});

  final Dhikr dhikr;
  final int index;

  @override
  State<_DhikrCard> createState() => _DhikrCardState();
}

class _DhikrCardState extends State<_DhikrCard> {
  int _current = 0;
  bool _done = false;

  void _increment() {
    if (_done) return;
    setState(() {
      _current++;
      if (_current >= widget.dhikr.count) {
        _done = true;
      }
    });
  }

  void _reset() {
    setState(() {
      _current = 0;
      _done = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dhikr = widget.dhikr;
    final text = appState.isArabic ? dhikr.textAr : dhikr.textEn;
    final virtue =
        appState.isArabic ? dhikr.virtueAr : dhikr.virtueEn;

    return GestureDetector(
      onTap: _increment,
      onLongPress: _reset,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: R.s(context, 8),
                    vertical: R.s(context, 3),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    '${widget.index}',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: R.f(context, 11),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                if (_done)
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.gold,
                        size: R.s(context, 18),
                      ),
                      SizedBox(width: R.s(context, 4)),
                      Text(
                        appState.tr('done'),
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: R.f(context, 11),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: R.s(context, 10)),
            Text(
              text,
              textAlign: TextAlign.center,
              textDirection: appState.isArabic
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              style: TextStyle(
                fontSize: R.f(context, 16),
                height: 1.9,
                color: AppColors.cream,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (virtue != null && virtue.isNotEmpty) ...[
              SizedBox(height: R.s(context, 10)),
              Container(
                padding: EdgeInsets.all(R.s(context, 8)),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: AppColors.gold,
                      size: R.s(context, 14),
                    ),
                    SizedBox(width: R.s(context, 6)),
                    Expanded(
                      child: Text(
                        virtue,
                        style: TextStyle(
                          fontSize: R.f(context, 10.5),
                          height: 1.5,
                          color: AppColors.softGold.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (dhikr.reference != null) ...[
              SizedBox(height: R.s(context, 6)),
              Text(
                dhikr.reference!,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: R.f(context, 10),
                  color: AppColors.cream.withValues(alpha: 0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            SizedBox(height: R.s(context, 10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: R.s(context, 14),
                    vertical: R.s(context, 6),
                  ),
                  decoration: BoxDecoration(
                    color: _done
                        ? AppColors.gold
                        : Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Text(
                    _done
                        ? appState.tr('completed')
                        : '$_current / ${dhikr.count}',
                    style: TextStyle(
                      color: _done
                          ? AppColors.deepGreen
                          : AppColors.gold,
                      fontSize: R.f(context, 13),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (_done) ...[
                  SizedBox(width: R.s(context, 8)),
                  IconButton(
                    onPressed: _reset,
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: AppColors.softGold,
                      size: R.s(context, 18),
                    ),
                    tooltip: appState.tr('reset'),
                  ),
                ],
              ],
            ),
            if (!_done) ...[
              SizedBox(height: R.s(context, 4)),
              Text(
                appState.tr('tapToCount'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.f(context, 9.5),
                  color: AppColors.cream.withValues(alpha: 0.4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
