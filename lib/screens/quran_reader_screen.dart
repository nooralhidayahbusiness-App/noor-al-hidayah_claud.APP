import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_state.dart';
import '../core/divine_names.dart';
import '../core/quran_prefs.dart';
import '../core/theme.dart';
import '../models/quran.dart';
import '../widgets/apology_dialog.dart';
import '../widgets/app_branding.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/ayah_card.dart';
import '../widgets/glass_card.dart';
import '../widgets/star_badge.dart';

/// Reads a surah in two modes: lines (one verse per card) or full mushaf pages.
class QuranReaderScreen extends StatefulWidget {
  const QuranReaderScreen({
    super.key,
    required this.data,
    required this.surah,
  });

  final QuranData data;
  final QuranSurah surah;

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  bool _pageMode = false;
  bool _fullscreen = false;
  bool _showHint = false;
  bool _zoomed = false;
  late int _page;
  PageController? _pageController;
  final TransformationController _transform = TransformationController();

  @override
  void initState() {
    super.initState();
    final total = widget.data.pages.length;
    _page = math.min(math.max(widget.data.firstPageOf(widget.surah), 1), total);
    _transform.addListener(_onTransform);
    quranPrefs.load();
    // The page size is fitted using the real font: redraw once it is loaded.
    GoogleFonts.pendingFonts([GoogleFonts.amiriQuran()]).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _transform.removeListener(_onTransform);
    _transform.dispose();
    _pageController?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onTransform() {
    final zoomed = _transform.value.getMaxScaleOnAxis() > 1.05;
    if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
  }

  void _setPageMode(bool value) {
    if (value == _pageMode) return;
    setState(() {
      _pageMode = value;
      if (value) {
        _pageController?.dispose();
        _pageController = PageController(initialPage: _page - 1);
      }
    });
  }

  Future<void> _setFullscreen(bool value) async {
    _transform.value = Matrix4.identity();
    setState(() {
      _fullscreen = value;
      _showHint = value;
    });
    try {
      await SystemChrome.setEnabledSystemUIMode(
        value ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
      );
    } catch (_) {}
    if (value) {
      await Future<void>.delayed(const Duration(seconds: 4));
      if (mounted && _fullscreen) setState(() => _showHint = false);
    }
  }

  void _onFont() {
    if (_pageMode) {
      showApologyDialog(context, appState.tr('fontSimple'));
    } else {
      quranPrefs.toggleFont();
    }
  }

  void _onTranslation() {
    if (_pageMode) {
      showApologyDialog(context, appState.tr('translationBtn'));
    } else {
      quranPrefs.toggleTranslation();
    }
  }

  void _onTafsir() {
    if (_pageMode) {
      showApologyDialog(context, appState.tr('tafsirBtn'));
    } else {
      showAuthMessage(context, appState.tr('tafsirSoon'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([appState, quranPrefs]),
      builder: (context, _) {
        final entries = widget.data.pages[_page - 1];
        final title = _pageMode && entries.isNotEmpty
            ? entries.first.surah.nameAr
            : widget.surah.nameAr;
        return Scaffold(
          body: AppBackground(
            child: SafeArea(
              top: !_fullscreen,
              bottom: !_fullscreen,
              child: Stack(
                children: [
                  Column(
                    children: [
                      if (!_fullscreen) ...[
                        _TopBar(title: title),
                        _Controls(
                          pageMode: _pageMode,
                          onFont: _onFont,
                          onMode: _setPageMode,
                          onTranslation: _onTranslation,
                          onTafsir: _onTafsir,
                          onEnlarge: () => _setFullscreen(true),
                        ),
                      ],
                      Expanded(
                        child: _pageMode ? _buildPages() : _buildLines(),
                      ),
                    ],
                  ),
                  if (_fullscreen) ...[
                    PositionedDirectional(
                      top: 12,
                      start: 12,
                      child: _RoundButton(
                        icon: Icons.fullscreen_exit_rounded,
                        onTap: () => _setFullscreen(false),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      left: 70,
                      right: 70,
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          opacity: _showHint ? 1 : 0,
                          duration: const Duration(milliseconds: 400),
                          child: _HintPill(text: appState.tr('zoomHint')),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLines() {
    final surah = widget.surah;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: surah.ayahs.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _SurahHeader(data: widget.data, surah: surah),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AyahCard(surah: surah, ayah: surah.ayahs[index - 1]),
        );
      },
    );
  }

  Widget _buildPages() {
    final pages = widget.data.pages;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PageView.builder(
        controller: _pageController,
        itemCount: pages.length,
        physics: _zoomed
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        onPageChanged: (index) {
          _transform.value = Matrix4.identity();
          setState(() => _page = index + 1);
        },
        itemBuilder: (context, index) {
          return _MushafPage(
            data: widget.data,
            entries: pages[index],
            pageNumber: index + 1,
            fullscreen: _fullscreen,
            transform: index + 1 == _page ? _transform : null,
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: appState.tr('back'),
            color: AppColors.softGold,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiriQuran(
                fontSize: 26,
                color: AppColors.softGold,
                shadows: [
                  Shadow(
                    color: AppColors.gold.withValues(alpha: 0.5),
                    blurRadius: 14,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.pageMode,
    required this.onFont,
    required this.onMode,
    required this.onTranslation,
    required this.onTafsir,
    required this.onEnlarge,
  });

  final bool pageMode;
  final VoidCallback onFont;
  final ValueChanged<bool> onMode;
  final VoidCallback onTranslation;
  final VoidCallback onTafsir;
  final VoidCallback onEnlarge;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([appState, quranPrefs]),
      builder: (context, _) {
        final effectiveSimple = quranPrefs.simpleFont && !pageMode;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              _ControlChip(
                icon: Icons.text_fields_rounded,
                label: effectiveSimple
                    ? appState.tr('fontUthmani')
                    : appState.tr('fontSimple'),
                active: false,
                onTap: onFont,
              ),
              const SizedBox(width: 10),
              _ModeSwitch(pageMode: pageMode, onChanged: onMode),
              const SizedBox(width: 10),
              _ControlChip(
                icon: Icons.translate_rounded,
                label: appState.tr('translationBtn'),
                active: !pageMode && quranPrefs.showTranslation,
                onTap: onTranslation,
              ),
              const SizedBox(width: 10),
              _ControlChip(
                icon: Icons.lightbulb_outline_rounded,
                label: appState.tr('tafsirBtn'),
                active: false,
                onTap: onTafsir,
              ),
              if (pageMode) ...[
                const SizedBox(width: 10),
                _ControlChip(
                  icon: Icons.fullscreen_rounded,
                  label: appState.tr('enlargeBtn'),
                  active: false,
                  onTap: onEnlarge,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ControlChip extends StatelessWidget {
  const _ControlChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = active ? AppColors.deepGreen : AppColors.gold;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: active
              ? const LinearGradient(
                  colors: [AppColors.softGold, AppColors.gold],
                )
              : null,
          color: active ? null : AppColors.deepGreen.withValues(alpha: 0.7),
          border: Border.all(color: AppColors.gold),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: active ? 0.55 : 0.3),
              blurRadius: 14,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: foreground),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Two options in one pill: lines | full page.
class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.pageMode, required this.onChanged});

  final bool pageMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: AppColors.deepGreen.withValues(alpha: 0.7),
        border: Border.all(color: AppColors.gold),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.3),
            blurRadius: 14,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeOption(
            label: appState.tr('modeLines'),
            active: !pageMode,
            onTap: () => onChanged(false),
          ),
          _ModeOption(
            label: appState.tr('modePage'),
            active: pageMode,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: active
              ? const LinearGradient(
                  colors: [AppColors.softGold, AppColors.gold],
                )
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: active ? AppColors.deepGreen : AppColors.gold,
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.deepGreen.withValues(alpha: 0.85),
          border: Border.all(color: AppColors.gold),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.5),
              blurRadius: 14,
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.gold),
      ),
    );
  }
}

class _HintPill extends StatelessWidget {
  const _HintPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black.withValues(alpha: 0.75),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.7)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          height: 1.5,
          color: AppColors.cream,
        ),
      ),
    );
  }
}

/// Header of the surah in lines mode.
class _SurahHeader extends StatelessWidget {
  const _SurahHeader({required this.data, required this.surah});

  final QuranData data;
  final QuranSurah surah;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([appState, quranPrefs]),
      builder: (context, _) {
        final showBasmalah = surah.number != 1 && surah.number != 9;
        final type = appState.tr(surah.isMeccan ? 'meccan' : 'medinan');
        final verses = appState.isArabic
            ? '${surah.count} ${surah.count >= 3 && surah.count <= 10 ? 'آيات' : 'آية'}'
            : '${surah.count} ${appState.tr('versesWord')}';
        final basmalahStyle = quranPrefs.simpleFont
            ? GoogleFonts.notoNaskhArabic(
                fontSize: 26,
                height: 2.0,
                color: AppColors.gold,
              )
            : GoogleFonts.amiriQuran(
                fontSize: 30,
                height: 2.0,
                color: AppColors.gold,
              );
        return GlassCard(
          child: Column(
            children: [
              Text(
                surah.nameAr,
                textAlign: TextAlign.center,
                style: GoogleFonts.amiriQuran(
                  fontSize: 34,
                  height: 1.6,
                  color: AppColors.softGold,
                  shadows: [
                    Shadow(
                      color: AppColors.gold.withValues(alpha: 0.5),
                      blurRadius: 16,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${surah.nameEn} • ${surah.meaning}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.cream.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$type • $verses',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.gold.withValues(alpha: 0.9),
                ),
              ),
              if (showBasmalah) ...[
                const SizedBox(height: 10),
                Divider(
                  height: 1,
                  color: AppColors.gold.withValues(alpha: 0.25),
                ),
                const SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    children: quranSpans(
                      data.basmalah(simple: quranPrefs.simpleFont),
                      basmalahStyle,
                    ),
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: basmalahStyle,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Full mushaf page: the text size is fitted so the page fills the screen.
// ---------------------------------------------------------------------------

String _indic(int n) {
  const digits = '٠١٢٣٤٥٦٧٨٩';
  return n.toString().split('').map((d) => digits[int.parse(d)]).join();
}

TextStyle _pageTextStyle(double fontSize) {
  return GoogleFonts.amiriQuran(
    fontSize: fontSize,
    height: 1.9,
    color: AppColors.cream,
  );
}

/// A piece of a page: a paragraph of verses, or a surah title (with basmalah).
class _PageBlock {
  const _PageBlock.text(this.spans)
      : surah = null,
        basmalah = null;
  const _PageBlock.banner(this.surah, this.basmalah) : spans = null;

  final List<InlineSpan>? spans;
  final QuranSurah? surah;
  final String? basmalah;
}

List<_PageBlock> _buildBlocks(
  List<PageEntry> entries,
  QuranData data,
  double fontSize,
) {
  final base = _pageTextStyle(fontSize);
  final blocks = <_PageBlock>[];
  var spans = <InlineSpan>[];

  void flush() {
    if (spans.isEmpty) return;
    blocks.add(_PageBlock.text(List<InlineSpan>.of(spans)));
    spans = <InlineSpan>[];
  }

  for (final e in entries) {
    if (e.ayah.number == 1) {
      flush();
      final showBasmalah = e.surah.number != 1 && e.surah.number != 9;
      blocks.add(
        _PageBlock.banner(
          e.surah,
          showBasmalah ? data.basmalah(simple: false) : null,
        ),
      );
    }
    spans.addAll(quranSpans(e.ayah.uthmani, base));
    spans.add(const TextSpan(text: ' '));
    spans.add(
      TextSpan(
        text: '\uFD3F${_indic(e.ayah.number)}\uFD3E ',
        style: TextStyle(color: AppColors.gold, fontSize: fontSize * 0.9),
      ),
    );
  }
  flush();
  return blocks;
}

double _bannerHeight(double fontSize, bool withBasmalah) {
  return fontSize * 2.1 + 8 + (withBasmalah ? fontSize * 2.3 : 0);
}

double _measure(List<_PageBlock> blocks, double fontSize, double width) {
  final base = _pageTextStyle(fontSize);
  var total = 0.0;
  for (final b in blocks) {
    final spans = b.spans;
    if (spans != null) {
      final painter = TextPainter(
        text: TextSpan(children: spans, style: base),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.justify,
      )..layout(maxWidth: width);
      total += painter.height;
      painter.dispose();
    } else {
      total += _bannerHeight(fontSize, b.basmalah != null);
    }
  }
  return total;
}

/// The biggest font size (up to 32) for which the page still fits.
double _fitFontSize(
  List<PageEntry> entries,
  QuranData data,
  double width,
  double height,
) {
  const maxSize = 32.0;
  var low = 14.0;
  var high = maxSize;
  if (_measure(_buildBlocks(entries, data, high), high, width) <= height) {
    return high;
  }
  for (var i = 0; i < 9; i++) {
    final mid = (low + high) / 2;
    if (_measure(_buildBlocks(entries, data, mid), mid, width) <= height) {
      low = mid;
    } else {
      high = mid;
    }
  }
  return low;
}

/// One mushaf page. In the enlarged (fullscreen) mode it can be zoomed with
/// two fingers.
class _MushafPage extends StatelessWidget {
  const _MushafPage({
    required this.data,
    required this.entries,
    required this.pageNumber,
    required this.fullscreen,
    required this.transform,
  });

  final QuranData data;
  final List<PageEntry> entries;
  final int pageNumber;
  final bool fullscreen;
  final TransformationController? transform;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final inset = fullscreen ? 8.0 : 14.0;
        final page = Padding(
          padding: EdgeInsets.fromLTRB(inset, 4, inset, 8),
          child: _PageFrame(
            data: data,
            entries: entries,
            pageNumber: pageNumber,
            maxWidth: constraints.maxWidth - inset * 2,
            maxHeight: constraints.maxHeight - 12,
          ),
        );
        if (!fullscreen) return page;
        return GestureDetector(
          onDoubleTap: () {
            transform?.value = Matrix4.identity();
          },
          child: InteractiveViewer(
            transformationController: transform,
            minScale: 1,
            maxScale: 5,
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: page,
            ),
          ),
        );
      },
    );
  }
}

class _PageFrame extends StatelessWidget {
  const _PageFrame({
    required this.data,
    required this.entries,
    required this.pageNumber,
    required this.maxWidth,
    required this.maxHeight,
  });

  final QuranData data;
  final List<PageEntry> entries;
  final int pageNumber;
  final double maxWidth;
  final double maxHeight;

  // Borders, margins and paddings around the text (see the widgets below).
  static const double _horizontalSpace = 41;
  static const double _verticalSpace = 84;

  @override
  Widget build(BuildContext context) {
    final contentWidth = math.max(maxWidth - _horizontalSpace, 100.0);
    final available = math.max(maxHeight - _verticalSpace, 100.0);
    final fontSize = _fitFontSize(entries, data, contentWidth, available);
    final blocks = _buildBlocks(entries, data, fontSize);
    final base = _pageTextStyle(fontSize);

    return Container(
      width: maxWidth,
      height: maxHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.deepGreen.withValues(alpha: 0.86),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.6),
          width: 1.4,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: contentWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final b in blocks)
                        if (b.spans != null)
                          Text.rich(
                            TextSpan(children: b.spans),
                            textAlign: TextAlign.justify,
                            textDirection: TextDirection.rtl,
                            style: base,
                          )
                        else
                          _SurahBanner(
                            surah: b.surah!,
                            basmalah: b.basmalah,
                            fontSize: fontSize,
                          ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            StarBadge(number: pageNumber, size: 36),
          ],
        ),
      ),
    );
  }
}

class _SurahBanner extends StatelessWidget {
  const _SurahBanner({
    required this.surah,
    required this.fontSize,
    this.basmalah,
  });

  final QuranSurah surah;
  final double fontSize;
  final String? basmalah;

  @override
  Widget build(BuildContext context) {
    final basmalahText = basmalah;
    final basmalahStyle = GoogleFonts.amiriQuran(
      fontSize: fontSize * 1.05,
      color: AppColors.gold,
    );
    return Column(
      children: [
        Container(
          height: fontSize * 2.1,
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [
                AppColors.gold.withValues(alpha: 0.18),
                AppColors.gold.withValues(alpha: 0.34),
                AppColors.gold.withValues(alpha: 0.18),
              ],
            ),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.7)),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              surah.nameAr,
              style: GoogleFonts.amiriQuran(
                fontSize: fontSize * 1.15,
                color: AppColors.softGold,
              ),
            ),
          ),
        ),
        if (basmalahText != null)
          SizedBox(
            height: fontSize * 2.3,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text.rich(
                  TextSpan(children: quranSpans(basmalahText, basmalahStyle)),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: basmalahStyle,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
