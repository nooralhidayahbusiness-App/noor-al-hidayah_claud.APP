import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../data/adhkar.dart';
import '../services/tts_service.dart';
import '../widgets/read_aloud_banner.dart';
import '../widgets/glass_card.dart';
import '../widgets/themed_background.dart';

class AdhkarDetailScreen extends StatefulWidget {
  const AdhkarDetailScreen({super.key, required this.category});

  final AdhkarCategory category;

  @override
  State<AdhkarDetailScreen> createState() => _AdhkarDetailScreenState();
}

class _AdhkarDetailScreenState extends State<AdhkarDetailScreen> {
  late final String _sessionKey = 'adhkar:${widget.category.id}';
  late final List<GlobalKey> _keys =
      List.generate(widget.category.items.length, (_) => GlobalKey());
  int _lastScrolled = -1;

  @override
  void initState() {
    super.initState();
    ttsService.addListener(_onTts);
  }

  @override
  void dispose() {
    ttsService.removeListener(_onTts);
    // إن أوقف المستخدم "القراءة في الخلفية" نوقف القراءة عند مغادرة القسم
    if (!ttsService.keepInBackground && ttsService.activeKey == _sessionKey) {
      ttsService.stop();
    }
    super.dispose();
  }

  /// يمرّر القائمة إلى الذكر الجاري قراءته
  void _onTts() {
    if (ttsService.activeKey != _sessionKey ||
        ttsService.status != TtsStatus.playing) {
      return;
    }
    final i = ttsService.index;
    if (i == _lastScrolled || i < 0 || i >= _keys.length) return;
    _lastScrolled = i;
    final ctx = _keys[i].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.1,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    }
  }

  List<String> _readItems() {
    final ar = appState.isArabic;
    return widget.category.items.map((d) {
      final text = ar ? d.textAr : d.textEn;
      if (d.count > 1) {
        return ar
            ? '$text. تُقال ${d.count} مرات.'
            : '$text. Repeat ${d.count} times.';
      }
      return text;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
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

              // ✅ شريط الاستماع الكبير
              Padding(
                padding: EdgeInsets.fromLTRB(
                  R.s(context, 16),
                  R.s(context, 8),
                  R.s(context, 16),
                  0,
                ),
                child: ReadAloudBanner(
                  sessionKey: _sessionKey,
                  title: title,
                  items: _readItems(),
                  lang: appState.isArabic ? 'ar-SA' : 'en-US',
                ),
              ),

              Expanded(
                child: ListenableBuilder(
                  listenable: ttsService,
                  builder: (context, _) {
                    final activeIndex =
                        (ttsService.activeKey == _sessionKey &&
                                ttsService.status != TtsStatus.idle)
                            ? ttsService.index
                            : -1;
                    return ListView(
                      padding: EdgeInsets.all(R.s(context, 16)),
                      children: [
                        for (int i = 0; i < category.items.length; i++)
                          Padding(
                            key: _keys[i],
                            padding:
                                EdgeInsets.only(bottom: R.s(context, 12)),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: i == activeIndex
                                      ? AppColors.gold
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: _DhikrCard(
                                dhikr: category.items[i],
                                index: i + 1,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
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
