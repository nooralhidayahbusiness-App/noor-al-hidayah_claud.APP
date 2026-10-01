import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_state.dart';
import '../core/reciter_prefs.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../models/quran.dart';
import '../services/auth_service.dart';
import '../services/gemini_service.dart';
import '../services/quran_service.dart';
import '../services/recitation_service.dart';
import '../services/user_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/reciter_picker_sheet.dart';
import '../widgets/star_badge.dart';
import '../widgets/themed_background.dart';

class RecitationLearningScreen extends StatefulWidget {
  const RecitationLearningScreen({super.key});

  @override
  State<RecitationLearningScreen> createState() =>
      _RecitationLearningScreenState();
}

class _RecitationLearningScreenState
    extends State<RecitationLearningScreen> {
  QuranData? _data;
  int _surahNumber = 1;
  int _ayahIndex = 0;

  bool _recording = false;
  bool _analyzing = false;
  bool _playing = false;
  String? _analysisResult;
  int _stars = 0;
  int _accuracy = 0;
  int _sessionsCount = 0;

  final AudioPlayer _player = AudioPlayer();

  QuranSurah get _surah => _data!.surah(_surahNumber);
  QuranAyah get _ayah => _surah.ayahs[_ayahIndex];

  @override
  void initState() {
    super.initState();
    _init();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    recitationService.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final data = await QuranService.load();
      if (!mounted) return;
      setState(() => _data = data);
      await _loadProgress();
    } catch (e) {
      if (!mounted) return;
      _showSnack('${appState.tr('quranLoadError')}: $e', error: true);
    }
  }

  Future<void> _loadProgress() async {
    try {
      final p = await userService.loadProgress('aiTeacher');
      final lastSurah = (p['lastRecitationSurah'] as num?)?.toInt() ?? 1;
      final lastAyah = (p['lastRecitationAyah'] as num?)?.toInt() ?? 1;
      final sessions =
          (p['recitationSessions'] as num?)?.toInt() ?? 0;

      if (!mounted || _data == null) return;
      final surahNum = lastSurah.clamp(1, 114);
      final surah = _data!.surah(surahNum);
      final ayahIdx = (lastAyah - 1).clamp(0, surah.ayahs.length - 1);

      setState(() {
        _surahNumber = surahNum;
        _ayahIndex = ayahIdx;
        _sessionsCount = sessions;
      });
    } catch (_) {}
  }

  Future<void> _saveProgress() async {
    if (authService.currentUser == null) return;
    try {
      await userService.saveProgress('aiTeacher', {
        'lastRecitationSurah': _surahNumber,
        'lastRecitationAyah': _ayah.number,
        'recitationSessions': _sessionsCount,
        'lastRecitationTime': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {}
  }

  void _goToAyah(int newIndex) {
    if (newIndex < 0 || newIndex >= _surah.ayahs.length) return;
    setState(() {
      _ayahIndex = newIndex;
      _analysisResult = null;
      _stars = 0;
      _accuracy = 0;
    });
    _saveProgress();
  }

  void _nextAyah() {
    if (_ayahIndex + 1 < _surah.ayahs.length) {
      _goToAyah(_ayahIndex + 1);
    } else if (_surahNumber < 114) {
      setState(() {
        _surahNumber++;
        _ayahIndex = 0;
        _analysisResult = null;
        _stars = 0;
        _accuracy = 0;
      });
      _saveProgress();
    }
  }

  void _prevAyah() {
    if (_ayahIndex > 0) {
      _goToAyah(_ayahIndex - 1);
    } else if (_surahNumber > 1) {
      setState(() {
        _surahNumber--;
        _ayahIndex = _data!.surah(_surahNumber).ayahs.length - 1;
        _analysisResult = null;
        _stars = 0;
        _accuracy = 0;
      });
      _saveProgress();
    }
  }

  Future<void> _togglePlayReciter() async {
    if (_playing) {
      await _player.stop();
      if (mounted) setState(() => _playing = false);
      return;
    }
    try {
      await _player.stop();
      final url =
          reciterPrefs.reciter.ayahUrl(_surah.number, _ayah.number);
      await _player.play(UrlSource(url));
      if (mounted) setState(() => _playing = true);
    } catch (e) {
      if (!mounted) return;
      _showSnack(appState.tr('recitationAudioError'), error: true);
    }
  }

  Future<void> _startRecording() async {
    if (_playing) {
      await _player.stop();
      if (mounted) setState(() => _playing = false);
    }
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
        expectedVerse: _ayah.uthmani,
        surahName: _surah.nameAr,
        ayahNumber: _ayah.number,
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
    final match = RegExp(r'(\d{1,3})\s*%').firstMatch(text);
    if (match != null) {
      final n = int.tryParse(match.group(1) ?? '') ?? 0;
      return n.clamp(0, 100);
    }
    return 0;
  }

  Future<void> _openSurahSelector() async {
    if (_data == null) return;
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SurahSelectorSheet(
        data: _data!,
        selectedNumber: _surahNumber,
      ),
    );
    if (selected == null) return;
    setState(() {
      _surahNumber = selected;
      _ayahIndex = 0;
      _analysisResult = null;
      _stars = 0;
      _accuracy = 0;
    });
    _saveProgress();
  }

  Future<void> _openReciterSelector() async {
    final selected = await showReciterPicker(
      context,
      selectedId: reciterPrefs.reciterId,
    );
    if (selected == null || !mounted) return;
    await reciterPrefs.setReciter(selected);
    if (mounted) setState(() {});
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
    if (_data == null) {
      return Scaffold(
        body: ThemedBackground(
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
        ),
      );
    }

    final progress = (_ayahIndex + 1) / _surah.ayahs.length;

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
                      if (_analysisResult != null) _buildAnalysisCard(),
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
                  color: const Color(0xFFFFA000).withValues(alpha: 0.2),
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
            onPressed: _openSurahSelector,
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
              GestureDetector(
                onTap: _openSurahSelector,
                child: Row(
                  children: [
                    Text(
                      '${_surah.nameAr} • ${appState.tr('ayahWord')} ${_ayah.number}',
                      style: TextStyle(
                        fontSize: R.f(context, 12),
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                    SizedBox(width: R.s(context, 4)),
                    Icon(
                      Icons.unfold_more_rounded,
                      color: AppColors.gold.withValues(alpha: 0.8),
                      size: R.s(context, 14),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _openReciterSelector,
                child: Row(
                  children: [
                    Icon(
                      Icons.record_voice_over_rounded,
                      color: AppColors.softGold.withValues(alpha: 0.8),
                      size: R.s(context, 14),
                    ),
                    SizedBox(width: R.s(context, 4)),
                    Text(
                      reciterPrefs.reciter.nameAr,
                      style: TextStyle(
                        fontSize: R.f(context, 11),
                        color: AppColors.cream.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: R.s(context, 2)),
                    Icon(
                      Icons.unfold_more_rounded,
                      color: AppColors.softGold.withValues(alpha: 0.7),
                      size: R.s(context, 14),
                    ),
                  ],
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
            _ayah.uthmani,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.amiriQuran(
              fontSize: R.f(context, 26),
              height: 2.0,
              color: AppColors.cream,
            ),
          ),
          if (_ayah.translation.isNotEmpty) ...[
            SizedBox(height: R.s(context, 12)),
            Divider(
              color: AppColors.gold.withValues(alpha: 0.25),
              height: 1,
            ),
            SizedBox(height: R.s(context, 10)),
            Text(
              _ayah.translation,
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
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: _prevAyah,
          icon: Icon(
            Icons.skip_previous_rounded,
            color: AppColors.gold,
            size: R.s(context, 28),
          ),
        ),
        _RoundButton(
          icon: _playing
              ? Icons.stop_rounded
              : Icons.volume_up_rounded,
          label: appState.tr('recitationListen'),
          color: AppColors.gold,
          iconColor: AppColors.deepGreen,
          onTap: _togglePlayReciter,
        ),
        _RecordButton(
          recording: _recording,
          onStart: _startRecording,
          onStop: _stopRecording,
        ),
        IconButton(
          onPressed: _nextAyah,
          icon: Icon(
            Icons.skip_next_rounded,
            color: AppColors.gold,
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
          if (showRating)
            Row(
              children: [
                if (_stars > 0)
                  Row(
                    children: List.generate(
                      5,
                      (i) => Padding(
                        padding:
                            EdgeInsets.only(right: R.s(context, 2)),
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
                      border: Border.all(color: AppColors.gold),
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
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
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
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: _nextAyah,
                  icon: Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.gold,
                    size: R.s(context, 16),
                  ),
                  label: Text(
                    appState.tr('recitationNextAyah'),
                    style: TextStyle(
                      fontSize: R.f(context, 12),
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
              final scale =
                  widget.recording ? 1.0 + 0.08 * _pulse.value : 1.0;
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
                            ? const Color(0xFFD32F2F).withValues(
                                alpha: 0.55 + 0.3 * _pulse.value)
                            : AppColors.gold.withValues(alpha: 0.5),
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

class _SurahSelectorSheet extends StatefulWidget {
  const _SurahSelectorSheet({
    required this.data,
    required this.selectedNumber,
  });

  final QuranData data;
  final int selectedNumber;

  @override
  State<_SurahSelectorSheet> createState() =>
      _SurahSelectorSheetState();
}

class _SurahSelectorSheetState extends State<_SurahSelectorSheet> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(QuranSurah s) {
    if (_query.isEmpty) return true;
    final q = _query.trim().toLowerCase();
    return s.number.toString() == q ||
        s.nameAr.contains(q) ||
        s.nameEn.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.data.surahs.where(_matches).toList();
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.deepGreen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        R.s(context, 14),
        R.s(context, 12),
        R.s(context, 14),
        R.s(context, 8),
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
          SizedBox(height: R.s(context, 12)),
          Text(
            appState.tr('recitationChooseSurah'),
            style: TextStyle(
              fontSize: R.f(context, 14),
              fontWeight: FontWeight.w700,
              color: AppColors.softGold,
            ),
          ),
          SizedBox(height: R.s(context, 10)),
          TextField(
            controller: _search,
            onChanged: (v) => setState(() => _query = v),
            style: TextStyle(
              color: AppColors.cream,
              fontSize: R.f(context, 13),
            ),
            decoration: InputDecoration(
              hintText: appState.tr('searchSurah'),
              hintStyle: TextStyle(
                color: AppColors.cream.withValues(alpha: 0.5),
                fontSize: R.f(context, 12),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.gold,
                size: R.s(context, 20),
              ),
              filled: true,
              fillColor: Colors.black.withValues(alpha: 0.25),
              contentPadding:
                  EdgeInsets.symmetric(vertical: R.s(context, 10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.gold.withValues(alpha: 0.4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.gold),
              ),
            ),
          ),
          SizedBox(height: R.s(context, 10)),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: list.isEmpty
                ? Center(
                    child: Text(
                      appState.tr('noResults'),
                      style: TextStyle(
                        color: AppColors.cream.withValues(alpha: 0.7),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final surah = list[i];
                      final selected =
                          surah.number == widget.selectedNumber;
                      return Padding(
                        padding:
                            EdgeInsets.only(bottom: R.s(context, 6)),
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.pop(context, surah.number),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: R.s(context, 10),
                              vertical: R.s(context, 8),
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.gold
                                      .withValues(alpha: 0.2)
                                  : Colors.black
                                      .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? AppColors.gold
                                    : AppColors.gold
                                        .withValues(alpha: 0.3),
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                StarBadge(
                                  number: surah.number,
                                  size: R.s(context, 34),
                                ),
                                SizedBox(width: R.s(context, 10)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        surah.nameAr,
                                        style: TextStyle(
                                          fontSize: R.f(context, 13.5),
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.softGold,
                                        ),
                                      ),
                                      Text(
                                        '${surah.nameEn} • ${surah.count} ${appState.tr('ayahWord')}',
                                        style: TextStyle(
                                          fontSize: R.f(context, 10.5),
                                          color: AppColors.cream
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (selected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.gold,
                                    size: R.s(context, 20),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
