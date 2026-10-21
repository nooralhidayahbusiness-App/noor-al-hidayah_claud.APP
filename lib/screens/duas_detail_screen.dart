import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../data/duas.dart';
import '../services/tts_service.dart';
import '../widgets/read_aloud_banner.dart';
import '../widgets/glass_card.dart';
import '../widgets/themed_background.dart';

class DuasDetailScreen extends StatefulWidget {
  const DuasDetailScreen({super.key, required this.category});

  final DuaCategory category;

  @override
  State<DuasDetailScreen> createState() => _DuasDetailScreenState();
}

class _DuasDetailScreenState extends State<DuasDetailScreen> {
  late final String _sessionKey = 'dua:${widget.category.id}';
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
    if (!ttsService.keepInBackground && ttsService.activeKey == _sessionKey) {
      ttsService.stop();
    }
    super.dispose();
  }

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
    return widget.category.items
        .map((d) => ar ? d.textAr : d.textEn)
        .toList();
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
                      onPressed: () => Navigator.of(context).maybePop(),
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
                              child: _DuaCard(
                                dua: category.items[i],
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

class _DuaCard extends StatelessWidget {
  const _DuaCard({required this.dua, required this.index});

  final Dua dua;
  final int index;

  Future<void> _copy(BuildContext context) async {
    final text = appState.isArabic ? dua.textAr : dua.textEn;
    final buffer = StringBuffer()
      ..writeln(text)
      ..writeln()
      ..write(dua.reference);
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.deepGreen,
            content: Text(
              appState.tr('copied'),
              style: const TextStyle(color: AppColors.cream),
            ),
          ),
        );
    }
  }

  Future<void> _share(BuildContext context) async {
    final text = appState.isArabic ? dua.textAr : dua.textEn;
    final buffer = StringBuffer()
      ..writeln(text)
      ..writeln()
      ..write(dua.reference);
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.deepGreen,
            content: Text(
              appState.tr('copiedToShare'),
              style: const TextStyle(color: AppColors.cream),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = appState.isArabic ? dua.textAr : dua.textEn;
    final virtue = appState.isArabic ? dua.virtueAr : dua.virtueEn;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // رأس البطاقة: رقم + أزرار
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
                  '$index',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: R.f(context, 11),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: appState.tr('copy'),
                onPressed: () => _copy(context),
                icon: Icon(
                  Icons.copy_rounded,
                  color: AppColors.gold.withValues(alpha: 0.85),
                  size: R.s(context, 18),
                ),
              ),
              IconButton(
                tooltip: appState.tr('share'),
                onPressed: () => _share(context),
                icon: Icon(
                  Icons.share_rounded,
                  color: AppColors.gold.withValues(alpha: 0.85),
                  size: R.s(context, 18),
                ),
              ),
            ],
          ),
          SizedBox(height: R.s(context, 8)),

          // نص الدعاء
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

          // الفضل
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

          // المرجع
          SizedBox(height: R.s(context, 8)),
          Text(
            dua.reference,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: R.f(context, 10.5),
              color: AppColors.cream.withValues(alpha: 0.55),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
