import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/secrets.dart';

/// خدمة الاتصال بـ Google Gemini API.
/// تستخدم endpoint المحادثة (generateContent).
class GeminiService {
  GeminiService._();
  static final GeminiService instance = GeminiService._();

  /// إرسال رسالة والحصول على الرد الكامل.
  Future<String> ask({
    required String message,
    List<ChatMessage> history = const [],
    String systemPrompt = '',
    double temperature = 0.7,
  }) async {
    final contents = _buildContents(
      message: message,
      history: history,
      systemPrompt: systemPrompt,
    );

    final body = json.encode({
      'contents': contents,
      'generationConfig': {
        'temperature': temperature,
        'maxOutputTokens': 2048,
        'topP': 0.95,
      },
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_ONLY_HIGH',
        },
        {
          'category': 'HARM_CATEGORY_HATE_SPEECH',
          'threshold': 'BLOCK_ONLY_HIGH',
        },
        {
          'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
          'threshold': 'BLOCK_ONLY_HIGH',
        },
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_ONLY_HIGH',
        },
      ],
    });

    try {
      final url = Uri.parse('$geminiEndpoint?key=$geminiApiKey');
      final res = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 40));

      if (res.statusCode != 200) {
        debugPrint('Gemini HTTP ${res.statusCode}: ${res.body}');
        throw GeminiException(_mapHttpError(res.statusCode, res.body));
      }

      final data = json.decode(utf8.decode(res.bodyBytes))
          as Map<String, dynamic>;
      return _extractText(data);
    } on TimeoutException {
      throw const GeminiException('geminiTimeout');
    } catch (e) {
      if (e is GeminiException) rethrow;
      debugPrint('Gemini error: $e');
      throw const GeminiException('geminiGeneric');
    }
  }

  /// إرسال رسالة مع بث الرد (Streaming — أفضل للتفاعل اللحظي).
  Stream<String> askStream({
    required String message,
    List<ChatMessage> history = const [],
    String systemPrompt = '',
    double temperature = 0.7,
  }) async* {
    final contents = _buildContents(
      message: message,
      history: history,
      systemPrompt: systemPrompt,
    );

    final body = json.encode({
      'contents': contents,
      'generationConfig': {
        'temperature': temperature,
        'maxOutputTokens': 2048,
      },
    });

    final url = Uri.parse(
        '${geminiEndpoint.replaceAll(':generateContent', ':streamGenerateContent')}?key=$geminiApiKey&alt=sse');

    final client = http.Client();
    try {
      final req = http.Request('POST', url)
        ..headers['Content-Type'] = 'application/json'
        ..body = body;

      final streamed = await client.send(req).timeout(
            const Duration(seconds: 30),
          );

      if (streamed.statusCode != 200) {
        final errBody = await streamed.stream.bytesToString();
        throw GeminiException(
            _mapHttpError(streamed.statusCode, errBody));
      }

      final buffer = StringBuffer();
      await for (final chunk in streamed.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (!chunk.startsWith('data: ')) continue;
        final data = chunk.substring(6).trim();
        if (data.isEmpty || data == '[DONE]') continue;
        try {
          final jsonData = json.decode(data) as Map<String, dynamic>;
          final text = _extractText(jsonData, silent: true);
          if (text.isNotEmpty) {
            buffer.write(text);
            yield text;
          }
        } catch (_) {}
      }
    } finally {
      client.close();
    }
  }

  List<Map<String, dynamic>> _buildContents({
    required String message,
    required List<ChatMessage> history,
    required String systemPrompt,
  }) {
    final contents = <Map<String, dynamic>>[];

    if (systemPrompt.isNotEmpty) {
      contents.add({
        'role': 'user',
        'parts': [
          {'text': systemPrompt}
        ],
      });
      contents.add({
        'role': 'model',
        'parts': [
          {'text': 'فهمت. سأتبع هذه التعليمات.'}
        ],
      });
    }

    for (final h in history) {
      contents.add({
        'role': h.isUser ? 'user' : 'model',
        'parts': [
          {'text': h.text}
        ],
      });
    }

    contents.add({
      'role': 'user',
      'parts': [
        {'text': message}
      ],
    });

    return contents;
  }

  String _extractText(Map<String, dynamic> data, {bool silent = false}) {
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      if (silent) return '';
      throw const GeminiException('geminiBlocked');
    }
    final first = candidates.first as Map<String, dynamic>;
    final content = first['content'] as Map?;
    final parts = content?['parts'] as List?;
    if (parts == null || parts.isEmpty) {
      if (silent) return '';
      throw const GeminiException('geminiBlocked');
    }
    final text = (parts.first as Map)['text'] as String? ?? '';
    return text;
  }

  String _mapHttpError(int status, String body) {
    if (status == 400) return 'geminiBadRequest';
    if (status == 401 || status == 403) return 'geminiAuth';
    if (status == 429) return 'geminiQuota';
    if (status >= 500) return 'geminiServer';
    return 'geminiGeneric';
  }
}

/// رسالة في سجل المحادثة.
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });

  Map<String, dynamic> toMap() => {
        'text': text,
        'isUser': isUser,
        'time': time.millisecondsSinceEpoch,
      };

  static ChatMessage fromMap(Map<String, dynamic> m) => ChatMessage(
        text: (m['text'] as String?) ?? '',
        isUser: (m['isUser'] as bool?) ?? true,
        time: DateTime.fromMillisecondsSinceEpoch(
            (m['time'] as num?)?.toInt() ?? 0),
      );
}

/// استثناء مخصص للخدمة.
class GeminiException implements Exception {
  final String key;
  const GeminiException(this.key);
  @override
  String toString() => 'GeminiException: $key';
}

final geminiService = GeminiService.instance;
