import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import '../data/questions.dart';
import '../widgets/auth_widgets.dart';
import 'challenge_result_screen.dart';

class ChallengePlayScreen extends StatefulWidget {
  const ChallengePlayScreen({super.key, required this.questions});

  final List<ChallengeQuestion> questions;

  @override
  State<ChallengePlayScreen> createState() => _ChallengePlayScreenState();
}

class _ChallengePlayScreenState extends State<ChallengePlayScreen> {
  static const _secondsPerQuestion = 30;

  int _currentIndex = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;
  int _secondsLeft = _secondsPerQuestion;
  Timer? _timer;

  ChallengeQuestion get _current => widget.questions[_currentIndex];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = _secondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        _selectOption(-1); // انتهى الوقت
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _selectOption(int index) {
    if (_answered) return;
    _timer?.cancel();
    setState(() {
      _selected = index;
      _answered = true;
      if (index == _current.correctIndex) _score++;
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      if (_currentIndex + 1 >= widget.questions.length) {
        _finish();
      } else {
        setState(() {
          _currentIndex++;
          _selected = null;
          _answered = false;
        });
        _startTimer();
      }
    });
  }

  void _finish() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChallengeResultScreen(
          correct: _score,
          total: widget.questions.length,
        ),
      ),
    );
  }

  Color _optionColor(int index) {
    if (!_answered) return Colors.black.withValues(alpha: 0.25);
    if (index == _current.correctIndex) return const Color(0xFF2E7D32);
    if (index == _selected) return const Color(0xFF8B1A1A);
    return Colors.black.withValues(alpha: 0.25);
  }

  IconData? _optionIcon(int index) {
    if (!_answered) return null;
    if (index == _current.correctIndex) return Icons.check_circle_rounded;
    if (index == _selected) return Icons.cancel_rounded;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isAr = appState.isArabic;
    final question = isAr ? _current.questionAr : _current.questionEn;
    final options = isAr ? _current.optionsAr : _current.optionsEn;
    final progress = (_currentIndex + 1) / widget.questions.length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.deepGreen, Color(0xFF0A1F17)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ===== الشريط العلوي =====
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => _confirmExit(),
                      color: AppColors.softGold,
                      icon: const Icon(Icons.close_rounded),
                    ),
                    const Spacer(),
                    Text(
                      '${_currentIndex + 1} / ${widget.questions.length}',
                      style: const TextStyle(
                        color: AppColors.softGold,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (_secondsLeft <= 10
                                ? const Color(0xFF8B1A1A)
                                : AppColors.gold)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _secondsLeft <= 10
                              ? const Color(0xFFFF8A80)
                              : AppColors.gold.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: _secondsLeft <= 10
                                ? const Color(0xFFFF8A80)
                                : AppColors.gold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$_secondsLeft',
                            style: TextStyle(
                              color: _secondsLeft <= 10
                                  ? const Color(0xFFFF8A80)
                                  : AppColors.gold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ===== شريط التقدم =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.black.withValues(alpha: 0.3),
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.gold),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ===== السؤال =====
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color:
                                  AppColors.gold.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          question,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.cream,
                            fontSize: 20,
                            height: 1.7,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      for (int i = 0; i < options.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _OptionTile(
                            label: options[i],
                            color: _optionColor(i),
                            icon: _optionIcon(i),
                            onTap: _answered ? null : () => _selectOption(i),
                            index: i,
                          ),
                        ),
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

  Future<void> _confirmExit() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepGreen,
        title: Text(
          appState.tr('exitChallenge'),
          style: const TextStyle(color: AppColors.softGold),
        ),
        content: Text(
          appState.tr('exitChallengeBody'),
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
            child: Text(appState.tr('exit'),
                style: const TextStyle(color: Color(0xFFFF8A80))),
          ),
        ],
      ),
    );
    if (yes == true && mounted) Navigator.of(context).pop();
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.color,
    required this.onTap,
    required this.index,
    this.icon,
  });

  final String label;
  final Color color;
  final VoidCallback? onTap;
  final int index;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.15),
                border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.5)),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.cream,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            if (icon != null)
              Icon(icon, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}
