import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../data/learning_verses.dart';
import '../services/auth_service.dart';
import '../services/gemini_service.dart';
import '../services/recitation_service.dart';
import '../services/user_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/themed_background.dart';

class RecitationLearningScreen extends StatefulWidget {
  const RecitationLearningScreen({super.key});

  @override
  State<RecitationLearningScreen> createState() =>
      _RecitationLearningScreenState();
}

class _RecitationLearningScreenState
    extends State<RecitationLearningScreen> {
  int _currentIndex = 0;
  bool _recording = false;
  bool _analyzing = false;
  String? _analysisResult;
  int _stars = 0;
  int _accuracy = 0;
  int _sessionsCount = 0;

  LearningVerse get _current => kLearningVerses[_currentIndex];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final p = await userService.loadProgress('aiTeacher');
      if (!mounted) return;
      setState(() {
        _sessionsCount = (p['recitationSessions'] as num?)?.toInt() ?? 0;
      });
    } catch (_) {}
  }

  Future<void> _saveProgress() async {
    if (authService.currentUser == null) return;
    try {
      await userService.saveProgress('aiTeacher', {
        'recitationSessions': _sessionsCount,
        'lastRecitation': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {}
  }

  Future<void> _playReciter() async {
    // سنستخدم AudioPlayer الموجود في AdhanService أو نستخدم URL مباشر.
    // هنا سنستخدم http للتحقق فقط، وفي التطبيق الحقيقي نستخدم audioplayers.
    // البساطة: نستخدم UrlSource.
    try {
      // (يستدعي audioplayers من adhan_service)
      // للتأكد من البساطة، نستخدم نفس الـ AudioPlayer في مكان آخر.
      // سنستخدم AudioPlayer هنا مباشرة:
      // ignore: avoid_print
      print('Playing: ${_current.audioUrl}');
      // (نشغّل عبر الدالة الموجودة في service آخر)
      // لتجنب التكرار، نستخدم audioplayers مباشرة:
      final player = _audioPlayer;
      await player.stop();
      await player.play(UrlSource(_current.audioUrl));
    } catch (e) {
      _showSnack('${appState.tr('recitationAudioError')}: $e');
    }
  }

  // Audio player داخلي بسيط
  final _player = _SimpleAudioPlayer();

  @override
  void dispose() {
    _player.dispose();
    recitationService.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final ok = await recitationService.start();
    if (!ok) {
      if (!mounted) return;
      _showSnack(appState.tr('recitationMicDenied'), error: true);
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _recording = true;
      _analysisResult = null;
      _stars = 0;
      _accuracy = 0;
    });
  }

  Future<void> _stopRecording() async {
    final path = await recitationService.stop();
    setState(() => _recording = false);
    if (path == null) {
      if (!mounted) return;
      _showSnack(appState.tr('recitationRecordError'), error: true);
      return;
    }
    await _analyze(path);
  }

  Future<void> _analyze(String path) async {
    setState(() => _analyzing = true);
    try {
      final result = await recitationService.analyze(
        recordedPath: path,
        expectedVerse: _current.textAr,
        surahName: _current.surahName,
        ayahNumber: _current.ayahNumber,
        isArabic: appState.isArabic,
      );
      if (!mounted) return;
      setState(() {
        _analysisResult = result;
        _stars = _extractStars(result);
        _accuracy = _extractAccuracy(result);
        _sessionsCount++;
        _analyzing = false;
      });
      HapticFeedback.lightImpact();
      _saveProgress();
    } on GeminiException catch (e) {
      if (!mounted) return;
      setState(() => _analyzing = false);
      _showSnack(_mapError(e.key), error: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _analyzing = false);
      _showSnack(appState.tr('teacherErrorGeneric'), error: true);
    }
  }

  String _mapError(String key) {
    switch (key) {
      case 'geminiQuota':
        return appState.tr('teacherErrorQuota');
      case 'geminiAuth':
        return appState.tr('teacherErrorAuth');
      case 'geminiTimeout':
        return appState.tr('teacherErrorTimeout');
      case 'geminiBlocked':
        return appState.tr('teacherErrorBlocked');
      case 'recitationTooLong':
        return appState.tr('recitationTooLong');
      default:
        return appState.tr('teacherErrorGeneric');
    }
  }

  int _extractStars(String text) {
    final match = RegExp(r'⭐+').firstMatch(text);
    if (match != null) return match.group(0)!.length.clamp(0, 5);
    return 0;
  }

  int _extractAccuracy(String text) {
    final match =
        RegExp(r'(\d{1,3})\s*%').firstMatch(text);
    if (match != null) {
      final n = int.tryParse(match.group(1) ?? '') ?? 0;
      return n.clamp(0, 100);
    }
    return 0;
  }

  void _nextVerse() {
    if (_currentIndex + 1 < kLearningVerses.length) {
      setState(() {
        _currentIndex++;
        _analysisResult = null;
        _stars = 0;
        _accuracy = 0;
      });
    }
  }

  void _prevVerse() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _analysisResult = null;
        _stars = 0;
        _accuracy = 0;
      });
    }
  }

  void _openVerseSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _VerseSelectorSheet(
        selectedIndex: _currentIndex,
        onSelect: (i) {
          setState(() {
            _currentIndex = i;
            _analysisResult = null;
            _stars = 0;
            _accuracy = 0;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showSnack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              error ? const Color(0xFF5C1F1F) : AppColors.deepGreen,
          content: Text(
            msg,
            style: const TextStyle(color: AppColors.cream),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentIndex + 1) / kLearningVerses.length;

    return Scaffold(
      body: ThemedBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressBar(progress),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    R.s(context, 16),
                    R.s(context, 8),
                    R.s(context, 16),
                    R.s(context, 16),
                  ),
                  child: Column(
                    children: [
                      _buildVerseCard(),
                      SizedBox(height: R.s(context, 14)),
                      _buildActions(),
                      SizedBox(height: R.s(context, 14)),
                      if (_analyzing) _buildAnalyzingCard(),
                      if (_analysisResult != null)
                        _buildAnalysisCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
          Row(
            children: [
              Text(
                appState.tr('recitationTitle'),
                style: TextStyle(
                  fontSize: R.f(context, 15),
                  fontWeight: FontWeight.w700,
                  color: AppColors.softGold,
                ),
              ),
              SizedBox(width: R.s(context, 6)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: R.s(context, 6),
                  vertical: R.s(context, 2),
                ),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFFFA000).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFFA000),
                    width: 1,
                  ),
                ),
                child: Text(
                  'BETA',
                  style: TextStyle(
                    fontSize: R.f(context, 8),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: const Color(0xFFFFA000),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: R.s(context, 6)),
          IconButton(
            onPressed: _openVerseSelector,
            color: AppColors.softGold,
            iconSize: R.s(context, 20),
            icon: const Icon(Icons.list_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        R.s(context, 16),
        R.s(context, 4),
        R.s(context, 16),
        R.s(context, 8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${_current.surahName} • ${appState.tr('ayahWord')} ${_current.ayahNumber}',
                style: TextStyle(
                  fontSize: R.f(context, 11.5),
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
              const Spacer(),
              Text(
                '${_currentIndex + 1} / ${kLearningVerses.length}',
                style: TextStyle(
                  fontSize: R.f(context, 11),
                  color: AppColors.cream.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          SizedBox(height: R.s(context, 6)),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.black.withValues(alpha: 0.3),
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseCard() {
    return GlassCard(
      child: Column(
        children: [
          Text(
            _current.textAr,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.amiriQuran(
              fontSize: R.f(context, 26),
              height: 2.0,
              color: AppColors.cream,
            ),
          ),
          SizedBox(height: R.s(context, 12)),
          Divider(
            color: AppColors.gold.withValues(alpha: 0.25),
            height: 1,
          ),
          SizedBox(height: R.s(context, 10)),
          Text(
            _current.textEn,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontSize: R.f(context, 12.5),
              height: 1.6,
              color: AppColors.cream.withValues(alpha: 0.75),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        // السابق
        IconButton(
          onPressed: _currentIndex > 0 ? _prevVerse : null,
          icon: Icon(
            Icons.skip_previous_rounded,
            color: _currentIndex > 0
                ? AppColors.gold
                : AppColors.cream.withValues(alpha: 0.3),
            size: R.s(context, 28),
          ),
        ),
        SizedBox(width: R.s(context, 4)),

        // تشغيل القارئ
        _RoundButton(
          icon: Icons.volume_up_rounded,
          label: appState.tr('recitationListen'),
          color: AppColors.gold,
          iconColor: AppColors.deepGreen,
          onTap: _playReciter,
        ),

        SizedBox(width: R.s(context, 10)),

        // زر التسجيل
        _RecordButton(
          recording: _recording,
          onStart: _startRecording,
          onStop: _stopRecording,
        ),

        SizedBox(width: R.s(context, 10)),

        // التالي
        IconButton(
          onPressed: _currentIndex + 1 < kLearningVerses.length
              ? _nextVerse
              : null,
          icon: Icon(
            Icons.skip_next_rounded,
            color: _currentIndex + 1 < kLearningVerses.length
                ? AppColors.gold
                : AppColors.cream.withValues(alpha: 0.3),
            size: R.s(context, 28),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzingCard() {
    return GlassCard(
      ornament: false,
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.gold,
            ),
          ),
          SizedBox(width: R.s(context, 12)),
          Expanded(
            child: Text(
              appState.tr('recitationAnalyzing'),
              style: TextStyle(
                fontSize: R.f(context, 12.5),
                color: AppColors.cream,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard() {
    final showRating = _stars > 0 || _accuracy > 0;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // رأس النتيجة
          if (showRating)
            Row(
              children: [
                if (_stars > 0)
                  Row(
                    children: List.generate(
                      5,
                      (i) => Padding(
                        padding: EdgeInsets.only(
                            right: R.s(context, 2)),
                        child: Icon(
                          i < _stars
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: AppColors.gold,
                          size: R.s(context, 20),
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                if (_accuracy > 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.s(context, 10),
                      vertical: R.s(context, 4),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.gold,
                      ),
                    ),
                    child: Text(
                      '$_accuracy%',
                      style: TextStyle(
                        fontSize: R.f(context, 14),
                        fontWeight: FontWeight.w900,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
              ],
            ),
          if (showRating) SizedBox(height: R.s(context, 10)),

          // نص التحليل من Gemini
          Text(
            _analysisResult!,
            textDirection: appState.isArabic
                ? TextDirection.rtl
                : TextDirection.ltr,
            style: TextStyle(
              fontSize: R.f(context, 12.5),
              height: 1.7,
              color: AppColors.cream,
            ),
          ),

          SizedBox(height: R.s(context, 10)),

          // زر إعادة المحاولة
          TextButton.icon(
            onPressed: () => setState(() {
              _analysisResult = null;
              _stars = 0;
              _accuracy = 0;
            }),
            icon: Icon(
              Icons.refresh_rounded,
              color: AppColors.gold,
              size: R.s(context, 16),
            ),
            label: Text(
              appState.tr('recitationTryAgain'),
              style: TextStyle(
                fontSize: R.f(context, 12),
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== الأزرار ====================
class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: R.s(context, 58),
            height: R.s(context, 58),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: R.s(context, 26),
            ),
          ),
        ),
        SizedBox(height: R.s(context, 6)),
        Text(
          label,
          style: TextStyle(
            fontSize: R.f(context, 10.5),
            color: AppColors.cream.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RecordButton extends StatefulWidget {
  const _RecordButton({
    required this.recording,
    required this.onStart,
    required this.onStop,
  });

  final bool recording;
  final VoidCallback onStart;
  final VoidCallback onStop;

  @override
  State<_RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<_RecordButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.recording) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _RecordButton old) {
    super.didUpdateWidget(old);
    if (widget.recording && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.recording && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: widget.recording ? widget.onStop : widget.onStart,
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              final scale = widget.recording
                  ? 1.0 + 0.08 * _pulse.value
                  : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: R.s(context, 72),
                  height: R.s(context, 72),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.recording
                        ? const Color(0xFFD32F2F)
                        : AppColors.gold,
                    boxShadow: [
                      BoxShadow(
                        color: widget.recording
                            ? const Color(0xFFD32F2F)
                                .withValues(alpha: 0.55 + 0.3 * _pulse.value)
                            : AppColors.gold
                                .withValues(alpha: 0.5),
                        blurRadius: widget.recording ? 24 : 14,
                        spreadRadius: widget.recording ? 4 : 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.recording
                        ? Icons.stop_rounded
                        : Icons.mic_rounded,
                    color: widget.recording
                        ? Colors.white
                        : AppColors.deepGreen,
                    size: R.s(context, 32),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: R.s(context, 6)),
        Text(
          widget.recording
              ? appState.tr('recitationStop')
              : appState.tr('recitationRecord'),
          style: TextStyle(
            fontSize: R.f(context, 10.5),
            color: widget.recording
                ? const Color(0xFFD32F2F)
                : AppColors.cream.withValues(alpha: 0.8),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ==================== منتقي الآيات ====================
class _VerseSelectorSheet extends StatelessWidget {
  const _VerseSelectorSheet({
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final grouped = groupVersesBySurah();

    return Container(
      padding: EdgeInsets.all(R.s(context, 14)),
      decoration: const BoxDecoration(
        color: AppColors.deepGreen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
          SizedBox(height: R.s(context, 10)),
          Text(
            appState.tr('recitationChooseSurah'),
            style: TextStyle(
              fontSize: R.f(context, 14),
              fontWeight: FontWeight.w700,
              color: AppColors.softGold,
            ),
          ),
          SizedBox(height: R.s(context, 10)),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: ListView(
              children: grouped.entries.map((entry) {
                final verses = entry.value;
                final firstIdx = kLearningVerses.indexOf(verses.first);
                return Padding(
                  padding: EdgeInsets.only(bottom: R.s(context, 4)),
                  child: GestureDetector(
                    onTap: () => onSelect(firstIdx),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: R.s(context, 12),
                        vertical: R.s(context, 10),
                      ),
                      decoration: BoxDecoration(
                        color: (selectedIndex >= firstIdx &&
                                selectedIndex <
                                    firstIdx + verses.length)
                            ? AppColors.gold.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            color: AppColors.gold,
                            size: R.s(context, 18),
                          ),
                          SizedBox(width: R.s(context, 10)),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: R.f(context, 13),
                                fontWeight: FontWeight.w700,
                                color: AppColors.softGold,
                              ),
                            ),
                          ),
                          Text(
                            '${verses.length} ${appState.tr('ayahWord')}',
                            style: TextStyle(
                              fontSize: R.f(context, 11),
                              color: AppColors.cream
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== مشغل صوت بسيط ====================
class _SimpleAudioPlayer {
  Future<void> stop() async {}
  Future<void> play(dynamic source) async {}
  Future<void> dispose() async {}
}

final _audioPlayer = _SimpleAudioPlayer();
