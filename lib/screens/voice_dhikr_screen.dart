import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../core/app_state.dart';
import '../core/responsive.dart';
import '../core/theme.dart';
import '../services/sheikh_audio_service.dart';
import '../services/voice_counter_engine.dart';
import '../widgets/themed_background.dart';

/// ذكر يمكن اختياره
class DhikrChoice {
  const DhikrChoice(this.id, this.ar, this.en);
  final String id;
  final String ar;
  final String en;
}

const List<DhikrChoice> kDhikrChoices = [
  DhikrChoice('istighfar', 'أستغفر الله', 'Astaghfirullah'),
  DhikrChoice('alhamdulillah', 'الحمد لله', 'Alhamdulillah'),
  DhikrChoice('subhanallah', 'سبحان الله', 'SubhanAllah'),
  DhikrChoice('allahuakbar', 'الله أكبر', 'Allahu Akbar'),
  DhikrChoice('tahlil', 'لا إله إلا الله', 'La ilaha illallah'),
  DhikrChoice('hawqala', 'لا حول ولا قوة إلا بالله', 'La hawla wa la quwwata illa billah'),
  DhikrChoice('bihamdihi', 'سبحان الله وبحمده', 'SubhanAllahi wa bihamdih'),
  DhikrChoice('azim', 'سبحان الله العظيم', 'SubhanAllahil Azim'),
  DhikrChoice('both', 'سبحان الله وبحمده سبحان الله العظيم',
      'SubhanAllahi wa bihamdihi SubhanAllahil Azim'),
  DhikrChoice('istighfar_full', 'أستغفر الله العظيم وأتوب إليه',
      'Astaghfirullah al-Azim wa atubu ilayh'),
  DhikrChoice('salawat', 'اللهم صلِّ وسلِّم على نبينا محمد',
      'Allahumma salli wa sallim ala nabiyyina Muhammad'),
  DhikrChoice('tawhid', 'لا إله إلا الله وحده لا شريك له',
      'La ilaha illallah wahdahu la sharika lah'),
];

enum _Stage { setup, session }

class VoiceDhikrScreen extends StatefulWidget {
  const VoiceDhikrScreen({super.key});

  @override
  State<VoiceDhikrScreen> createState() => _VoiceDhikrScreenState();
}

class _VoiceDhikrScreenState extends State<VoiceDhikrScreen>
    with TickerProviderStateMixin {
  static const List<int> _targets = [33, 99, 100, 1000];

  _Stage _stage = _Stage.setup;

  // الاختيارات
  String _choiceId = 'istighfar';
  String _customText = '';
  int _target = 33;
  int _sensitivity = 1;

  // الجلسة
  int _count = 0;
  bool _done = false;
  bool _paused = false;
  VoicePhase _phase = VoicePhase.idle;
  String? _error;
  final ValueNotifier<double> _level = ValueNotifier<double>(0);
  VoiceCounterEngine? _engine;

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  late final AnimationController _ripple = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  late final AnimationController _celebrate = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  void dispose() {
    _engine?.dispose();
    try {
      WakelockPlus.disable();
    } catch (_) {}
    _pulse.dispose();
    _ripple.dispose();
    _celebrate.dispose();
    _level.dispose();
    super.dispose();
  }

  // ===================== التفضيلات =====================
  Future<void> _loadPrefs() async {
    try {
      final p = await SharedPreferences.getInstance();
      final id = p.getString('vd_choice');
      final target = p.getInt('vd_target');
      final custom = p.getString('vd_custom');
      final sens = p.getInt('vd_sens');
      if (!mounted) return;
      setState(() {
        if (id != null &&
            (id == 'custom' || kDhikrChoices.any((c) => c.id == id))) {
          _choiceId = id;
        }
        if (target != null && target > 0) _target = target;
        if (custom != null) _customText = custom;
        if (sens != null) _sensitivity = sens.clamp(0, 2);
      });
    } catch (_) {}
  }

  Future<void> _savePrefs() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString('vd_choice', _choiceId);
      await p.setInt('vd_target', _target);
      await p.setString('vd_custom', _customText);
      await p.setInt('vd_sens', _sensitivity);
    } catch (_) {}
  }

  // ===================== نصوص =====================
  String get _dhikrText {
    if (_choiceId == 'custom') {
      return _customText.trim().isEmpty
          ? (appState.isArabic ? 'ذكر مخصص' : 'Custom dhikr')
          : _customText.trim();
    }
    final c = kDhikrChoices.firstWhere(
      (c) => c.id == _choiceId,
      orElse: () => kDhikrChoices.first,
    );
    return c.ar;
  }

  bool get _isCustomTarget => !_targets.contains(_target);

  // ===================== الجلسة =====================
  Future<void> _startSession() async {
    try {
      await sheikhAudio.stop();
    } catch (_) {}
    await _savePrefs();

    setState(() {
      _stage = _Stage.session;
      _count = 0;
      _done = false;
      _paused = false;
      _error = null;
      _phase = VoicePhase.calibrating;
    });
    _level.value = 0;
    _celebrate.reset();

    try {
      await WakelockPlus.enable();
    } catch (_) {}

    await _engine?.dispose();
    _engine = VoiceCounterEngine(
      onCount: _onVoiceCount,
      onLevel: (v) => _level.value = v,
      onPhase: _onPhase,
      sensitivity: _sensitivity,
    );
    await _engine!.start();
  }

  void _onPhase(VoicePhase phase, String? message) {
    if (!mounted) return;
    setState(() {
      _phase = phase;
      _error = phase == VoicePhase.error ? (message ?? 'error') : null;
    });
  }

  void _onVoiceCount() {
    if (!mounted || _done || _paused) return;
    _increment();
  }

  void _increment() {
    if (_done) return;
    setState(() => _count++);
    HapticFeedback.lightImpact();
    _ripple.forward(from: 0);
    if (_count >= _target) {
      _finish();
    }
  }

  void _decrement() {
    if (_done || _count == 0) return;
    setState(() => _count--);
    HapticFeedback.selectionClick();
  }

  Future<void> _finish() async {
    setState(() => _done = true);
    await _engine?.stop();
    try {
      await WakelockPlus.disable();
    } catch (_) {}
    _celebrate.forward(from: 0);
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 180));
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 180));
    HapticFeedback.mediumImpact();
  }

  Future<void> _togglePause() async {
    if (_done) return;
    if (_paused) {
      setState(() {
        _paused = false;
        _phase = VoicePhase.calibrating;
      });
      await _engine?.start();
    } else {
      setState(() => _paused = true);
      await _engine?.stop();
    }
  }

  Future<void> _restart() async {
    await _engine?.stop();
    setState(() {
      _count = 0;
      _done = false;
      _paused = false;
      _phase = VoicePhase.calibrating;
    });
    _celebrate.reset();
    try {
      await WakelockPlus.enable();
    } catch (_) {}
    await _engine?.start();
  }

  Future<void> _backToSetup() async {
    await _engine?.stop();
    try {
      await WakelockPlus.disable();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _stage = _Stage.setup;
      _done = false;
      _paused = false;
      _count = 0;
    });
  }

  Future<void> _changeSensitivity(int v) async {
    setState(() => _sensitivity = v);
    _engine?.sensitivity = v;
    await _savePrefs();
  }

  // ===================== حوارات =====================
  Future<void> _askCustomText() async {
    final ar = appState.isArabic;
    final controller = TextEditingController(text: _customText);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepGreen,
        title: Text(
          ar ? 'اكتب الذكر' : 'Write the dhikr',
          style: const TextStyle(color: AppColors.softGold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 80,
          style: const TextStyle(color: AppColors.cream),
          decoration: InputDecoration(
            hintText: ar ? 'مثال: اللهم اغفر لي' : 'e.g. Allahumma ighfir li',
            hintStyle: TextStyle(
              color: AppColors.cream.withValues(alpha: 0.4),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.gold.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.gold),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              ar ? 'إلغاء' : 'Cancel',
              style: const TextStyle(color: AppColors.softGold),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(
              ar ? 'حفظ' : 'Save',
              style: const TextStyle(color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty || !mounted) return;
    setState(() {
      _customText = result;
      _choiceId = 'custom';
    });
  }

  Future<void> _askCustomTarget() async {
    final ar = appState.isArabic;
    final controller = TextEditingController(
      text: _isCustomTarget ? '$_target' : '',
    );
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepGreen,
        title: Text(
          ar ? 'اكتب العدد' : 'Enter the number',
          style: const TextStyle(color: AppColors.softGold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 6,
          style: const TextStyle(color: AppColors.cream, fontSize: 22),
          decoration: InputDecoration(
            hintText: ar ? 'مثال: 500' : 'e.g. 500',
            hintStyle: TextStyle(
              color: AppColors.cream.withValues(alpha: 0.4),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.gold.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.gold),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              ar ? 'إلغاء' : 'Cancel',
              style: const TextStyle(color: AppColors.softGold),
            ),
          ),
          TextButton(
            onPressed: () {
              final v = int.tryParse(controller.text.trim());
              Navigator.pop(ctx, (v != null && v > 0 && v <= 100000) ? v : null);
            },
            child: Text(
              ar ? 'حفظ' : 'Save',
              style: const TextStyle(color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
    if (result == null || !mounted) return;
    setState(() => _target = result);
  }

  // ===================== البناء =====================
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _stage == _Stage.setup,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _backToSetup();
      },
      child: Scaffold(
        body: ThemedBackground(
          child: SafeArea(
            child: _stage == _Stage.setup ? _buildSetup() : _buildSession(),
          ),
        ),
      ),
    );
  }

  Widget _header(String title, VoidCallback onBack) {
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
            onPressed: onBack,
            color: AppColors.softGold,
            iconSize: R.s(context, 22),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: R.f(context, 16),
              fontWeight: FontWeight.w800,
              color: AppColors.softGold,
            ),
          ),
          SizedBox(width: R.s(context, 40)),
        ],
      ),
    );
  }

  // ---------------------- شاشة الاختيار ----------------------
  Widget _buildSetup() {
    final ar = appState.isArabic;

    return Column(
      children: [
        _header(ar ? 'بصوتك' : 'By Your Voice', () => Navigator.of(context).maybePop()),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              R.s(context, 16),
              R.s(context, 10),
              R.s(context, 16),
              R.s(context, 24),
            ),
            children: [
              Text(
                ar
                    ? 'اختر الذكر، وحدّد العدد، ثم اضغط «ابدأ» وردّد بصوتك — والعدّاد يحسب عنك.'
                    : 'Choose a dhikr and a count, press Start, and say it aloud — the counter does the rest.',
                style: TextStyle(
                  fontSize: R.f(context, 13),
                  height: 1.7,
                  color: AppColors.cream.withValues(alpha: 0.88),
                ),
              ),
              SizedBox(height: R.s(context, 16)),

              _sectionTitle(ar ? '1) اختر الذكر' : '1) Choose the dhikr'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in kDhikrChoices)
                    _chip(
                      label: ar ? c.ar : c.en,
                      selected: _choiceId == c.id,
                      onTap: () => setState(() => _choiceId = c.id),
                    ),
                  _chip(
                    label: _choiceId == 'custom' && _customText.isNotEmpty
                        ? _customText
                        : (ar ? '✎ ذكر مخصص' : '✎ Custom'),
                    selected: _choiceId == 'custom',
                    onTap: _askCustomText,
                  ),
                ],
              ),
              SizedBox(height: R.s(context, 20)),

              _sectionTitle(ar ? '2) اختر العدد' : '2) Choose the count'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in _targets)
                    _chip(
                      label: '$t',
                      selected: _target == t,
                      onTap: () => setState(() => _target = t),
                    ),
                  _chip(
                    label: _isCustomTarget
                        ? '$_target'
                        : (ar ? '✎ عدد مخصص' : '✎ Custom'),
                    selected: _isCustomTarget,
                    onTap: _askCustomTarget,
                  ),
                ],
              ),
              SizedBox(height: R.s(context, 20)),

              _sectionTitle(ar ? '3) حساسية الميكروفون' : '3) Microphone sensitivity'),
              Row(
                children: [
                  for (int i = 0; i < 3; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _chip(
                          label: ar
                              ? const ['منخفضة', 'متوسطة', 'عالية'][i]
                              : const ['Low', 'Medium', 'High'][i],
                          selected: _sensitivity == i,
                          onTap: () => setState(() => _sensitivity = i),
                          expand: true,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: R.s(context, 6)),
              Text(
                ar
                    ? 'ارفع الحساسية في الأماكن الهادئة أو إن لم يلتقط صوتك، وخفّضها إن كان المكان مزعجاً.'
                    : 'Raise it in quiet places or if your voice is missed; lower it in noisy places.',
                style: TextStyle(
                  fontSize: R.f(context, 11.5),
                  height: 1.6,
                  color: AppColors.cream.withValues(alpha: 0.65),
                ),
              ),
              SizedBox(height: R.s(context, 26)),

              // زر ابدأ
              GestureDetector(
                onTap: _startSession,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: AppColors.gold,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.55),
                        blurRadius: 22,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.mic_rounded,
                        color: AppColors.deepGreen,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        ar ? 'ابدأ' : 'Start',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.deepGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: R.s(context, 12)),
              Text(
                ar
                    ? 'ملاحظة: العدّاد يلتقط **كل مرة تنطق فيها** (كل مقطع صوت)، ويعمل بدون إنترنت. يمكنك دائماً النقر على الدائرة للعدّ باللمس.'
                    : 'Note: the counter detects each time you speak (each voice segment) and works offline. You can always tap the circle to count by touch.',
                style: TextStyle(
                  fontSize: R.f(context, 11.5),
                  height: 1.7,
                  color: AppColors.cream.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.s(context, 8)),
      child: Text(
        text,
        style: TextStyle(
          fontSize: R.f(context, 14),
          fontWeight: FontWeight.w800,
          color: AppColors.gold,
        ),
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    bool expand = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        alignment: expand ? Alignment.center : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: selected
              ? AppColors.gold
              : Colors.black.withValues(alpha: 0.25),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: selected ? 1 : 0.45),
            width: selected ? 1.8 : 1.2,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: R.f(context, 14),
            fontWeight: FontWeight.w800,
            color: selected ? AppColors.deepGreen : AppColors.cream,
          ),
        ),
      ),
    );
  }

  // ---------------------- شاشة العدّ ----------------------
  Widget _buildSession() {
    final ar = appState.isArabic;
    final size = math.min(MediaQuery.of(context).size.width - 48, 330.0);

    String status;
    if (_done) {
      status = ar ? 'تقبّل الله منك 🤍' : 'May Allah accept it 🤍';
    } else if (_phase == VoicePhase.error) {
      status = ar ? 'تعذّر تشغيل الميكروفون' : 'Microphone unavailable';
    } else if (_paused) {
      status = ar ? 'متوقف مؤقتاً' : 'Paused';
    } else if (_phase == VoicePhase.calibrating) {
      status = ar
          ? 'جارٍ تهيئة الميكروفون… التزم الصمت لحظة'
          : 'Calibrating… stay silent for a moment';
    } else {
      status = ar ? 'أسمعك… ردّد الذكر بصوت واضح' : 'Listening… say it clearly';
    }

    return Column(
      children: [
        _header(ar ? 'بصوتك' : 'By Your Voice', _backToSetup),
        SizedBox(height: R.s(context, 8)),

        // نص الذكر
        Padding(
          padding: EdgeInsets.symmetric(horizontal: R.s(context, 24)),
          child: Text(
            _dhikrText,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.amiri(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1.5,
              color: AppColors.gold,
              shadows: [
                Shadow(
                  color: AppColors.gold.withValues(alpha: 0.6),
                  blurRadius: 18,
                ),
              ],
            ),
          ),
        ),
        const Spacer(),

        // الدائرة الكبيرة
        GestureDetector(
          onTap: _phase == VoicePhase.error || !_done ? _increment : null,
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                RepaintBoundary(
                  child: CustomPaint(
                    size: Size(size, size),
                    painter: _CounterPainter(
                      progress: _target == 0 ? 0 : _count / _target,
                      level: _level,
                      pulse: _pulse,
                      ripple: _ripple,
                      celebrate: _celebrate,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) => ScaleTransition(
                        scale: Tween<double>(begin: 0.7, end: 1).animate(anim),
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: Text(
                        '$_count',
                        key: ValueKey(_count),
                        style: TextStyle(
                          fontSize: size * 0.26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cream,
                          height: 1.0,
                          shadows: [
                            Shadow(
                              color: AppColors.gold.withValues(alpha: 0.5),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '/ $_target',
                      style: TextStyle(
                        fontSize: size * 0.085,
                        fontWeight: FontWeight.w700,
                        color: AppColors.softGold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ValueListenableBuilder<double>(
                      valueListenable: _level,
                      builder: (context, v, _) {
                        final active = !_paused && !_done &&
                            _phase == VoicePhase.listening;
                        return Transform.scale(
                          scale: 1 + v * 0.45,
                          child: Icon(
                            _done
                                ? Icons.check_circle_rounded
                                : (_paused
                                    ? Icons.mic_off_rounded
                                    : Icons.mic_rounded),
                            size: size * 0.11,
                            color: _done
                                ? AppColors.gold
                                : (active
                                    ? AppColors.gold
                                    : AppColors.cream.withValues(alpha: 0.45)),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Spacer(),

        // الحالة
        Padding(
          padding: EdgeInsets.symmetric(horizontal: R.s(context, 24)),
          child: Text(
            status,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: R.f(context, 14),
              fontWeight: FontWeight.w700,
              color: AppColors.cream.withValues(alpha: 0.9),
            ),
          ),
        ),

        // خطأ الميكروفون
        if (_phase == VoicePhase.error)
          Padding(
            padding: EdgeInsets.fromLTRB(
              R.s(context, 24),
              R.s(context, 8),
              R.s(context, 24),
              0,
            ),
            child: Column(
              children: [
                Text(
                  _error == 'permission'
                      ? (ar
                          ? 'اسمح للتطبيق باستخدام الميكروفون من إعدادات الهاتف، أو عُدّ باللمس بالنقر على الدائرة.'
                          : 'Allow microphone access in your phone settings, or count by tapping the circle.')
                      : (ar
                          ? 'يمكنك العدّ باللمس بالنقر على الدائرة.'
                          : 'You can count by tapping the circle.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: R.f(context, 12.5),
                    height: 1.6,
                    color: const Color(0xFFFFB4A9),
                  ),
                ),
                if (_error == 'permission')
                  TextButton(
                    onPressed: openAppSettings,
                    child: Text(
                      ar ? 'فتح إعدادات التطبيق' : 'Open app settings',
                      style: const TextStyle(color: AppColors.gold),
                    ),
                  ),
              ],
            ),
          ),

        SizedBox(height: R.s(context, 14)),

        // أزرار التحكم
        Padding(
          padding: EdgeInsets.symmetric(horizontal: R.s(context, 20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _control(
                icon: Icons.remove_rounded,
                label: ar ? 'تراجع' : 'Undo',
                onTap: _decrement,
              ),
              _control(
                icon: _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                label: _paused ? (ar ? 'استئناف' : 'Resume') : (ar ? 'إيقاف مؤقت' : 'Pause'),
                onTap: _togglePause,
                big: true,
              ),
              _control(
                icon: Icons.restart_alt_rounded,
                label: ar ? 'من جديد' : 'Restart',
                onTap: _restart,
              ),
            ],
          ),
        ),
        SizedBox(height: R.s(context, 10)),

        // الحساسية
        Padding(
          padding: EdgeInsets.symmetric(horizontal: R.s(context, 24)),
          child: Row(
            children: [
              Icon(
                Icons.graphic_eq_rounded,
                size: 18,
                color: AppColors.gold.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 8),
              Text(
                ar ? 'الحساسية' : 'Sensitivity',
                style: TextStyle(
                  fontSize: R.f(context, 12),
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream.withValues(alpha: 0.85),
                ),
              ),
              const Spacer(),
              for (int i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: GestureDetector(
                    onTap: () => _changeSensitivity(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: _sensitivity == i
                            ? AppColors.gold
                            : Colors.black.withValues(alpha: 0.25),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        ar
                            ? const ['منخفضة', 'متوسطة', 'عالية'][i]
                            : const ['Low', 'Med', 'High'][i],
                        style: TextStyle(
                          fontSize: R.f(context, 11.5),
                          fontWeight: FontWeight.w800,
                          color: _sensitivity == i
                              ? AppColors.deepGreen
                              : AppColors.cream,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: R.s(context, 18)),
      ],
    );
  }

  Widget _control({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool big = false,
  }) {
    final d = big ? 66.0 : 52.0;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: d,
            height: d,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: big
                  ? AppColors.gold
                  : Colors.black.withValues(alpha: 0.35),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: big ? 1 : 0.7),
                width: 1.6,
              ),
              boxShadow: big
                  ? [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.45),
                        blurRadius: 16,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: big ? 36 : 28,
              color: big ? AppColors.deepGreen : AppColors.gold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: R.f(context, 12),
              fontWeight: FontWeight.w700,
              color: AppColors.cream.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

/// ترسم: حلقة التقدّم + توهّج حسب مستوى الصوت + موجة عند كل عدّ + احتفال عند الإتمام.
class _CounterPainter extends CustomPainter {
  _CounterPainter({
    required this.progress,
    required this.level,
    required this.pulse,
    required this.ripple,
    required this.celebrate,
  }) : super(repaint: Listenable.merge([level, pulse, ripple, celebrate]));

  final double progress;
  final ValueNotifier<double> level;
  final Animation<double> pulse;
  final Animation<double> ripple;
  final Animation<double> celebrate;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 24;
    final lv = level.value;
    final p = pulse.value;
    final rp = ripple.value;
    final cel = celebrate.value;

    // توهّج خلفي يتفاعل مع الصوت
    final glowR = r + 12 + lv * 26 + p * 6;
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.gold.withValues(alpha: 0.10 + 0.38 * lv + 0.05 * p),
          AppColors.gold.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: c, radius: glowR + 30));
    canvas.drawCircle(c, glowR + 30, glow);

    // قاعدة الدائرة
    canvas.drawCircle(
      c,
      r,
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );

    // مسار الحلقة
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..color = AppColors.gold.withValues(alpha: 0.16);
    canvas.drawCircle(c, r, track);

    // قوس التقدّم (مع توهّج)
    final rect = Rect.fromCircle(center: c, radius: r);
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    if (sweep > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round
          ..color = AppColors.gold.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
      );
      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round
          ..color = AppColors.gold,
      );
    }

    // حدّ خارجي رفيع
    canvas.drawCircle(
      c,
      r + 11,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = AppColors.gold.withValues(alpha: 0.35 + 0.2 * p),
    );

    // موجة عند كل عدّ
    if (rp > 0 && rp < 1) {
      canvas.drawCircle(
        c,
        r + 14 + rp * 46,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = AppColors.gold.withValues(alpha: (1 - rp) * 0.65),
      );
    }

    // احتفال عند الإتمام: حلقات متتابعة + نجوم
    if (cel > 0 && cel < 1) {
      for (int i = 0; i < 3; i++) {
        final t = ((cel - i * 0.15) / 0.7).clamp(0.0, 1.0);
        if (t <= 0 || t >= 1) continue;
        canvas.drawCircle(
          c,
          r * (0.8 + t * 0.9),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..color = AppColors.gold.withValues(alpha: (1 - t) * 0.7),
        );
      }
      final starPaint = Paint()..color = AppColors.gold;
      for (int i = 0; i < 16; i++) {
        final a = i * (2 * math.pi / 16);
        final dist = r * (0.9 + cel * 0.55);
        final o = Offset(c.dx + dist * math.cos(a), c.dy + dist * math.sin(a));
        starPaint.color = AppColors.gold.withValues(alpha: (1 - cel) * 0.9);
        canvas.drawCircle(o, 3.5 * (1 - cel) + 1, starPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CounterPainter old) =>
      old.progress != progress;
}
