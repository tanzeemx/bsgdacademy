import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class GeneratedMcq {
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  GeneratedMcq({
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory GeneratedMcq.fromJson(Map<String, dynamic> j) {
    final opts =
        (j['options'] as List?)?.map((e) => e.toString()).toList() ?? [];
    var ci = int.tryParse('${j['correctIndex']}') ?? 0;
    if (ci < 0 || ci > 3) ci = 0;
    while (opts.length < 4) {
      opts.add('Option ${opts.length + 1}');
    }
    return GeneratedMcq(
      text: j['text']?.toString() ?? '',
      options: opts.take(4).toList(),
      correctIndex: ci,
      explanation: j['explanation']?.toString() ?? '',
    );
  }
}

class AiMcqService {
  static const apiKey = String.fromEnvironment('GEMINI_API_KEY');

  static bool get isConfigured => apiKey.isNotEmpty;

  /// Free-tier friendly models (tried in order on 404)
  static const freeModels = <String>[
    'gemini-3.8-flash',
    'gemini-3.7-flash',
    'gemini-3.6-flash',
    'gemini-3.5-flash',
    'gemini-3.5-flash-lite',
    'gemini-3.1-flash-lite',
    'gemini-3-flash-preview',
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
    'gemini-flash-latest',
    'gemini-flash-lite-latest',
  ];

  /// Existing MCQ paper (Bengali/English): extract only, fill answers
  static const _extractMcqPrompt = '''
You are reading an exam paper (may be in Bengali or English) that ALREADY has MCQ questions.
Do NOT invent new questions. Extract every question on the page/document.

Each question usually has 4 options labeled ক/খ/গ/ঘ or a/b/c/d or (ক)(খ)(গ)(ঘ).
Map them to options[0], options[1], options[2], options[3] in that order.
Set correctIndex (0, 1, 2, or 3) using an answer key if present; otherwise use subject knowledge.
Write a short explanation (Bengali or English is fine).

Return ONLY valid JSON array (no markdown fences):
[
  {
    "text": "full question text",
    "options": ["option1", "option2", "option3", "option4"],
    "correctIndex": 0,
    "explanation": "short reason"
  }
]

Rules:
- Exactly 4 options per question
- correctIndex must be 0, 1, 2, or 3
- Extract ALL questions visible
- Keep original language of the question and options
''';

  /// Study notes: create new MCQs
  static const _generateFromStudyPrompt = '''
You are an exam writer for Bangladeshi board exams (HSC/SSC), including Accounting and other subjects.
From the study material, CREATE new multiple-choice questions.

Return ONLY valid JSON array (no markdown fences):
[
  {
    "text": "question text",
    "options": ["A text", "B text", "C text", "D text"],
    "correctIndex": 0,
    "explanation": "short reason"
  }
]

Rules:
- Exactly 4 options
- correctIndex is 0, 1, 2, or 3
- Match the language of the material (Bengali or English)
- Clear Class 11/12 level questions
''';

  static Future<List<GeneratedMcq>> fromText(
    String content, {
    bool extractOnly = false,
    int? questionCount,
  }) async {
    _ensureKey();
    final prompt = _buildPrompt(extractOnly, questionCount);
    final body = {
      'contents': [
        {
          'parts': [
            {'text': '$prompt\n\nMATERIAL:\n$content'},
          ],
        },
      ],
      'generationConfig': {
        'temperature': extractOnly ? 0.2 : 0.4,
        'responseMimeType': 'application/json',
      },
    };
    return _requestWithFallback(body);
  }

  static Future<List<GeneratedMcq>> fromImage({
    required Uint8List bytes,
    required String mimeType,
    bool extractOnly = false,
    int? questionCount,
  }) async {
    _ensureKey();
    final prompt = _buildPrompt(extractOnly, questionCount);
    final b64 = base64Encode(bytes);
    final body = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {'mime_type': mimeType, 'data': b64},
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': extractOnly ? 0.2 : 0.4,
        'responseMimeType': 'application/json',
      },
    };
    return _requestWithFallback(body);
  }

  static Future<List<GeneratedMcq>> fromPdf(
    Uint8List bytes, {
    bool extractOnly = false,
    int? questionCount,
  }) async {
    _ensureKey();
    final prompt = _buildPrompt(extractOnly, questionCount);
    final b64 = base64Encode(bytes);
    final body = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {'mime_type': 'application/pdf', 'data': b64},
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': extractOnly ? 0.2 : 0.4,
        'responseMimeType': 'application/json',
      },
    };
    return _requestWithFallback(body);
  }

  static String _buildPrompt(bool extractOnly, int? questionCount) {
    if (extractOnly) return _extractMcqPrompt;
    final countHint = questionCount != null
        ? '\nGenerate exactly $questionCount questions.\n'
        : '\nGenerate 5 to 10 questions if the material allows.\n';
    return '$_generateFromStudyPrompt$countHint';
  }

  static void _ensureKey() {
    if (!isConfigured) {
      throw Exception(
        'GEMINI_API_KEY missing. Run with:\n'
        'flutter run ... --dart-define=GEMINI_API_KEY=your_key',
      );
    }
  }

  static Future<List<GeneratedMcq>> _requestWithFallback(
    Map<String, dynamic> body,
  ) async {
    final errors = <String>[];
    for (final model in freeModels) {
      try {
        return await _request(model, body);
      } catch (e) {
        final msg = e.toString();
        errors.add('$model → $msg');
        final lower = msg.toLowerCase();
        if (lower.contains('403') ||
            lower.contains('401') ||
            lower.contains('api_key') ||
            lower.contains('quota') ||
            lower.contains('resource_exhausted')) {
          rethrow;
        }
      }
    }
    throw Exception('All free models failed:\n${errors.take(5).join('\n')}');
  }

  static Future<List<GeneratedMcq>> _request(
    String model,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      '$model:generateContent?key=$apiKey',
    );

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception('Gemini ${res.statusCode} ($model): ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final text =
        data['candidates']?[0]?['content']?['parts']?[0]?['text']?.toString() ??
        '';

    if (text.isEmpty) {
      throw Exception('Empty response from $model');
    }

    final cleaned = text
        .replaceAll(RegExp(r'```json\s*', multiLine: true), '')
        .replaceAll(RegExp(r'```\s*', multiLine: true), '')
        .trim();

    dynamic decoded;
    try {
      decoded = jsonDecode(cleaned);
    } catch (_) {
      throw Exception('AI ($model) returned invalid JSON');
    }

    if (decoded is! List) {
      throw Exception('AI ($model) did not return a JSON list');
    }

    return decoded
        .whereType<Map>()
        .map((e) => GeneratedMcq.fromJson(Map<String, dynamic>.from(e)))
        .where((q) => q.text.isNotEmpty)
        .toList();
  }
}
