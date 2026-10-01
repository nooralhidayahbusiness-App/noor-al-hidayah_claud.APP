import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../core/secrets.dart';
import 'gemini_service.dart';

/// خدمة تسجيل التلاوة + إرسالها لـ Gemini للتحليل.
class RecitationService {
  RecitationService._();
  static final RecitationService instance = RecitationService._();

  final AudioRecorder _recorder = AudioRecorder();
  String? _currentPath;
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  /// طلب إذن الميكروفون.
  Future<bool> hasPermission() async {
    try {
      return await _recorder.hasPermission();
    } catch (_) {
      return false;
    }
  }

  /// بدء التسجيل.
  Future<bool> start() async {
    try {
      if (!await _recorder.hasPermission()) return false;

      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/recitation_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
      _currentPath = path;
      _isRecording = true;
      return true;
    } catch (e) {
      debugPrint('Record start error: $e');
      return false;
    }
  }

  /// إيقاف التسجيل وإرجاع المسار.
  Future<String?> stop() async {
    try {
      final path = await _recorder.stop();
      _isRecording = false;
      _currentPath = path ?? _currentPath;
      return _currentPath;
    } catch (e) {
      debugPrint('Record stop error: $e');
      _isRecording = false;
      return null;
    }
  }

  /// إلغاء التسجيل.
  Future<void> cancel() async {
    try {
      await _recorder.stop();
      _isRecording = false;
      if (_currentPath != null) {
        final f = File(_currentPath!);
        if (await f.exists()) await f.delete();
      }
      _currentPath = null;
    } catch (_) {}
  }

  /// إرسال التسجيل لـ Gemini مع نص الآية المتوقّع.
  /// يُرجع: رد Gemini النصي (تحليل + نسبة دقة تقديرية).
  Future<String> analyze({
    required String recordedPath,
    required String expectedVerse,
    required String surahName,
    required int ayahNumber,
    required bool isArabic,
  }) async {
    final file = File(recordedPath);
    if (!await file.exists()) {
      throw const GeminiException('recitationFileMissing');
    }

    final bytes = await file.readAsBytes();
    if (bytes.length > 15 * 1024 * 1024) {
      throw const GeminiException('recitationTooLong');
    }

    final base64Audio = base64Encode(bytes);

    final promptAr = '''
أنت معلم قرآن خبير. طالب يقرأ الآية التالية:
"$expectedVerse"
($surahName - الآية $ayahNumber)

استمع لتسجيله وأجب بالعربية الفصحى المبسطة بهذا التنسيق بالضبط:

**التقييم العام:** ⭐⭐⭐⭐☆ (من 5)
**نسبة الدقة:** XX%

**✅ نقاط القوة:**
- [نقاط إيجابية في التلاوة]

**⚠️ أخطاء تحتاج تحسيناً:**
- [الأخطاء إن وُجدت، مثل: مخارج الحروف، المدود، التشكيل]
- إذا لا توجد أخطاء قل: "ما شاء الله، تلاوة ممتازة!"

**📌 نصيحة عملية:**
- [نصيحة واحدة موجزة للتحسين]

**🎯 التركيز التالي:**
- [كلمة أو حرف يحتاج تدريباً]

اجعل الرد مختصراً (5-8 أسطر كحد أقصى).
''';

    final promptEn = '''
You are an expert Quran teacher. A student recited:
"$expectedVerse"
($surahName - Verse $ayahNumber)

Listen to his recording and reply in simple English in exactly this format:

**Overall rating:** ⭐⭐⭐⭐☆ (out of 5)
**Accuracy:** XX%

**✅ Strengths:**
- [Positive points]

**⚠️ Areas for improvement:**
- [Errors if any: letters, madd, harakat]
- If no errors: "MashaAllah, excellent recitation!"

**📌 Practical tip:**
- [One short tip]

**🎯 Next focus:**
- [A letter or word to practice]

Keep reply concise (5-8 lines max).
''';

    final body = json.encode({
      'contents': [
        {
          'parts': [
            {'text': isArabic ? promptAr : promptEn},
            {
              'inline_data': {
                'mime_type': 'audio/mp4',
                'data': base64Audio,
              }
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.3,
        'maxOutputTokens': 1024,
      },
    });

    try {
      final url = Uri.parse('$geminiEndpoint?key=$geminiApiKey');
      final res = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 60));

      if (res.statusCode != 200) {
        debugPrint('Recitation HTTP ${res.statusCode}: ${res.body}');
        throw GeminiException(_mapError(res.statusCode));
      }

      final data = json.decode(utf8.decode(res.bodyBytes))
          as Map<String, dynamic>;
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw const GeminiException('geminiBlocked');
      }
      final content =
          (candidates.first as Map)['content'] as Map?;
      final parts = content?['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw const GeminiException('geminiBlocked');
      }
      return (parts.first as Map)['text'] as String? ?? '';
    } on TimeoutException {
      throw const GeminiException('geminiTimeout');
    } catch (e) {
      if (e is GeminiException) rethrow;
      debugPrint('Recitation error: $e');
      throw const GeminiException('geminiGeneric');
    }
  }

  String _mapError(int status) {
    if (status == 400) return 'geminiBadRequest';
    if (status == 401 || status == 403) return 'geminiAuth';
    if (status == 429) return 'geminiQuota';
    if (status >= 500) return 'geminiServer';
    return 'geminiGeneric';
  }

  Future<void> dispose() async {
    try {
      await _recorder.dispose();
    } catch (_) {}
  }
}

final recitationService = RecitationService.instance;
