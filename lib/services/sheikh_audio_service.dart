import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';


enum SheikhStatus { idle, playing, paused }

/// خيار صوتي (مثال: العفاسي) = قائمة ملفات تُشغَّل بالترتيب.
class AudioOption {
  const AudioOption({
    required this.id,
    required this.label,
    required this.labelEn,
    required this.assets,
  });

  final String id;
  final String label;
  final String labelEn;

  /// مسارات الملفات داخل التطبيق (مثل assets/audio/adhkar/afasymorning.mp3)
  final List<String> assets;
}

/// يشغّل تسجيلات المشايخ (أذكار الصباح والمساء، وأدعية السديس) من داخل التطبيق.
/// - جلسة واحدة نشطة في كل وقت (مفتاح لكل قسم).
/// - الملفات المتعددة تُشغَّل تلقائياً بالترتيب (جزء بعد جزء).
class SheikhAudioService extends ChangeNotifier {
  SheikhAudioService._();
  static final SheikhAudioService instance = SheikhAudioService._();

  AudioPlayer? _player;
  StreamSubscription<PlayerState>? _stateSub;

  String? _activeKey;
  SheikhStatus _status = SheikhStatus.idle;
  List<String> _assets = const [];
  int _index = 0;
  int _token = 0;

  String? _errorKey;
  String? _error;

  String? get activeKey => _activeKey;
  SheikhStatus get status => _status;
  int get index => _index;
  int get total => _assets.length;
  String? get errorKey => _errorKey;
  String? get error => _error;

  AudioPlayer get _ensurePlayer {
    var p = _player;
    if (p == null) {
      p = AudioPlayer();
      _player = p;
      _stateSub = p.playerStateStream.listen(_onPlayerState);
    }
    return p;
  }

  /// المشغّل (يُنشأ عند أول استخدام) — يستعمله شريط التقدّم
  AudioPlayer get player => _ensurePlayer;

  // ===================== اختيار المقرئ (يُحفظ) =====================
  Future<String?> loadSelection(String sessionKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('sheikh_sel_$sessionKey');
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSelection(String sessionKey, String optionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sheikh_sel_$sessionKey', optionId);
    } catch (_) {}
  }

  // ===================== التشغيل =====================

  /// زر التشغيل: يبدأ / يوقف مؤقتاً / يستأنف حسب الحالة.
  Future<void> toggle(String key, List<String> assets) async {
    if (_activeKey == key) {
      if (_status == SheikhStatus.playing) {
        await pause();
        return;
      }
      if (_status == SheikhStatus.paused) {
        await resume();
        return;
      }
    }
    await start(key, assets);
  }

  Future<void> start(String key, List<String> assets) async {
    if (assets.isEmpty) return;

    final token = ++_token;
    _activeKey = key;
    _assets = assets;
    _index = 0;
    _error = null;
    _errorKey = null;
    _status = SheikhStatus.playing;
    notifyListeners();

    await _playIndex(0, token);
  }

  Future<bool> _assetExists(String path) async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      return manifest.listAssets().contains(path);
    } catch (_) {
      return true; // لا نمنع التشغيل إن تعذّر الفحص
    }
  }

  Future<void> _playIndex(int i, int token) async {
    if (token != _token) return;
    _index = i;
    notifyListeners();

    final path = _assets[i];
    if (!await _assetExists(path)) {
      _fail(
        'الملف الصوتي غير موجود بعد في التطبيق.',
        token,
      );
      return;
    }

    try {
      final p = _ensurePlayer;
      await p.setAsset(path);
      if (token != _token) return;
      unawaited(p.play());
    } catch (e) {
      _fail('تعذّر تشغيل الملف الصوتي.', token);
    }
  }

  void _fail(String message, int token) {
    if (token != _token) return;
    _errorKey = _activeKey;
    _error = message;
    _status = SheikhStatus.idle;
    _activeKey = null;
    notifyListeners();
  }

  void _onPlayerState(PlayerState s) {
    if (s.processingState == ProcessingState.completed &&
        _status == SheikhStatus.playing) {
      final next = _index + 1;
      if (next < _assets.length) {
        unawaited(_playIndex(next, _token));
      } else {
        // انتهت كل الأجزاء
        _status = SheikhStatus.idle;
        _activeKey = null;
        _index = 0;
        notifyListeners();
      }
    }
  }

  Future<void> pause() async {
    if (_status != SheikhStatus.playing) return;
    _status = SheikhStatus.paused;
    notifyListeners();
    try {
      await _player?.pause();
    } catch (_) {}
  }

  Future<void> resume() async {
    if (_status != SheikhStatus.paused) return;
    _status = SheikhStatus.playing;
    notifyListeners();
    try {
      unawaited(_player?.play());
    } catch (_) {}
  }

  Future<void> stop() async {
    _token++;
    _status = SheikhStatus.idle;
    _activeKey = null;
    _index = 0;
    notifyListeners();
    try {
      await _player?.stop();
    } catch (_) {}
  }

  /// الجزء التالي / السابق (للملفات المتعددة)
  Future<void> next() async {
    if (_activeKey == null) return;
    if (_index + 1 >= _assets.length) return;
    final token = ++_token;
    _status = SheikhStatus.playing;
    await _playIndex(_index + 1, token);
  }

  Future<void> previous() async {
    if (_activeKey == null) return;
    if (_index <= 0) {
      try {
        await _player?.seek(Duration.zero);
      } catch (_) {}
      return;
    }
    final token = ++_token;
    _status = SheikhStatus.playing;
    await _playIndex(_index - 1, token);
  }

  Future<void> seek(Duration position) async {
    try {
      await _player?.seek(position);
    } catch (_) {}
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _player?.dispose();
    super.dispose();
  }
}

final SheikhAudioService sheikhAudio = SheikhAudioService.instance;

/// أدعية الشيخ عبد الرحمن السديس: 11 جزءاً (كل جزء نحو 10 دقائق) تُشغَّل بالترتيب.
const List<AudioOption> kSudaisDuasOptions = [
  AudioOption(
    id: 'sudais',
    label: 'الشيخ عبد الرحمن السديس',
    labelEn: 'Sheikh Abdul Rahman Al-Sudais',
    assets: [
      'assets/audio/duas/01sudaisiduas.mp3',
      'assets/audio/duas/02sudaisiduas.mp3',
      'assets/audio/duas/03sudaisiduas.mp3',
      'assets/audio/duas/04sudaisiduas.mp3',
      'assets/audio/duas/05sudaisiduas.mp3',
      'assets/audio/duas/06sudaisiduas.mp3',
      'assets/audio/duas/07sudaisiduas.mp3',
      'assets/audio/duas/08sudaisiduas.mp3',
      'assets/audio/duas/09sudaisiduas.mp3',
      'assets/audio/duas/10sudaisiduas.mp3',
      'assets/audio/duas/11sudaisiduas.mp3',
    ],
  ),
];
