import 'dart:convert';

/// A validated question ready to be written to Firestore.
class ImportedQuestion {
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const ImportedQuestion({
    required this.text,
    required this.options,
    required this.correctIndex,
    this.explanation = '',
  });
}

class QuestionImportIssue {
  /// 1-based position of the question in the source file.
  final int number;
  final String message;
  const QuestionImportIssue(this.number, this.message);

  @override
  String toString() => 'Question $number: $message';
}

class QuestionImportResult {
  final List<ImportedQuestion> valid;
  final List<QuestionImportIssue> issues;
  const QuestionImportResult(this.valid, this.issues);

  /// Import is safe to commit only if nothing was rejected.
  bool get isClean => issues.isEmpty && valid.isNotEmpty;
}

/// Strict validation for question imports. Nothing is silently repaired:
/// a bad correct answer, missing option or duplicate is reported, never
/// replaced with a default.
///
/// JSON format:
/// ```json
/// [ { "text": "...", "options": ["a","b","c","d"],
///     "correctIndex": 1, "explanation": "optional" } ]
/// ```
/// (a top-level `{"questions": [...]}` object is also accepted)
///
/// TXT format (blocks separated by a blank line):
/// ```
/// Q: Question text (may continue on following lines)
/// A) First option
/// B) Second option
/// C) Third option
/// D) Fourth option
/// ANSWER: B
/// EXPLANATION: optional text
/// ```
class QuestionImportValidator {
  static const int minOptions = 2;
  static const int maxOptions = 6;

  static String normalize(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

  static QuestionImportResult parseJson(
    String raw, {
    Set<String> existingTexts = const {},
  }) {
    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return const QuestionImportResult([], [
        QuestionImportIssue(0, 'File is not valid JSON.'),
      ]);
    }

    if (decoded is Map && decoded['questions'] is List) {
      decoded = decoded['questions'];
    }
    if (decoded is! List) {
      return const QuestionImportResult([], [
        QuestionImportIssue(0, 'Expected a JSON list of questions.'),
      ]);
    }

    final drafts = <_Draft>[];
    final issues = <QuestionImportIssue>[];
    for (var i = 0; i < decoded.length; i++) {
      final item = decoded[i];
      if (item is! Map) {
        issues.add(QuestionImportIssue(i + 1, 'Entry is not an object.'));
        continue;
      }
      drafts.add(_Draft(
        i + 1,
        item['text'],
        item['options'],
        item['correctIndex'],
        item['explanation'],
      ));
    }
    return _validateAll(drafts, issues, existingTexts);
  }

  static QuestionImportResult parseTxt(
    String raw, {
    Set<String> existingTexts = const {},
  }) {
    final blocks = raw
        .replaceAll('\r\n', '\n')
        .split(RegExp(r'\n\s*\n'))
        .map((b) => b.trim())
        .where((b) => b.isNotEmpty)
        .toList();

    final qRe = RegExp(r'^Q\s*:\s*(.*)$', caseSensitive: false);
    final optRe = RegExp(r'^([A-Fa-f])[\)\.]\s*(.*)$');
    final ansRe = RegExp(r'^ANSWER\s*:\s*([A-Fa-f])\s*$', caseSensitive: false);
    final expRe = RegExp(r'^EXPLANATION\s*:\s*(.*)$', caseSensitive: false);

    final drafts = <_Draft>[];
    final issues = <QuestionImportIssue>[];

    for (var i = 0; i < blocks.length; i++) {
      final number = i + 1;
      String? text;
      final options = <String>[];
      Object? answer;
      String? explanation;
      var mode = '';
      var bad = false;

      for (final line in blocks[i].split('\n').map((l) => l.trim())) {
        if (line.isEmpty) continue;
        final q = qRe.firstMatch(line);
        final o = optRe.firstMatch(line);
        final a = ansRe.firstMatch(line);
        final e = expRe.firstMatch(line);
        if (q != null && text == null) {
          text = q.group(1)!.trim();
          mode = 'q';
        } else if (a != null) {
          answer = a.group(1)!.toUpperCase().codeUnitAt(0) - 65;
          mode = 'a';
        } else if (e != null) {
          explanation = e.group(1)!.trim();
          mode = 'e';
        } else if (o != null && mode != 'e') {
          final letterIndex = o.group(1)!.toUpperCase().codeUnitAt(0) - 65;
          if (letterIndex != options.length) {
            issues.add(QuestionImportIssue(
                number, 'Options must be lettered A, B, C... in order.'));
            bad = true;
            break;
          }
          options.add(o.group(2)!.trim());
          mode = 'o';
        } else if (mode == 'q') {
          text = '$text $line';
        } else if (mode == 'e') {
          explanation = '$explanation $line';
        } else if (mode == 'o' && options.isNotEmpty) {
          options[options.length - 1] = '${options.last} $line';
        } else {
          issues.add(QuestionImportIssue(number, 'Unrecognised line: "$line"'));
          bad = true;
          break;
        }
      }
      if (bad) continue;
      drafts.add(_Draft(number, text, options, answer, explanation));
    }
    return _validateAll(drafts, issues, existingTexts);
  }

  static QuestionImportResult _validateAll(
    List<_Draft> drafts,
    List<QuestionImportIssue> issues,
    Set<String> existingTexts,
  ) {
    final valid = <ImportedQuestion>[];
    final seen = <String, int>{};
    final existing = existingTexts.map(normalize).toSet();

    for (final d in drafts) {
      final error = _check(d);
      if (error != null) {
        issues.add(QuestionImportIssue(d.number, error));
        continue;
      }
      final text = (d.text as String).trim();
      final key = normalize(text);
      if (existing.contains(key)) {
        issues.add(QuestionImportIssue(
            d.number, 'Duplicate of a question already in this exam.'));
        continue;
      }
      final firstSeen = seen[key];
      if (firstSeen != null) {
        issues.add(QuestionImportIssue(
            d.number, 'Duplicate of question $firstSeen in this file.'));
        continue;
      }
      seen[key] = d.number;
      valid.add(ImportedQuestion(
        text: text,
        options: (d.options as List).map((o) => (o as String).trim()).toList(),
        correctIndex: _asInt(d.correct)!,
        explanation: (d.explanation is String)
            ? (d.explanation as String).trim()
            : '',
      ));
    }
    issues.sort((a, b) => a.number.compareTo(b.number));
    return QuestionImportResult(valid, issues);
  }

  static int? _asInt(Object? v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  /// Returns an error message, or null when the draft is valid.
  static String? _check(_Draft d) {
    if (d.text is! String || (d.text as String).trim().isEmpty) {
      return 'Missing question text.';
    }
    final options = d.options;
    if (options is! List) return 'Missing options list.';
    if (options.length < minOptions || options.length > maxOptions) {
      return 'Needs $minOptions to $maxOptions options '
          '(found ${options.length}).';
    }
    final cleaned = <String>[];
    for (final o in options) {
      if (o is! String || o.trim().isEmpty) {
        return 'Every option must be non-empty text.';
      }
      cleaned.add(normalize(o));
    }
    if (cleaned.toSet().length != cleaned.length) {
      return 'Options must be distinct.';
    }
    final idx = _asInt(d.correct);
    if (idx == null) return 'Missing or non-numeric correct answer.';
    if (idx < 0 || idx >= options.length) {
      return 'Correct answer $idx is outside the ${options.length} options.';
    }
    if (d.explanation != null && d.explanation is! String) {
      return 'Explanation must be text.';
    }
    return null;
  }
}

class _Draft {
  final int number;
  final Object? text;
  final Object? options;
  final Object? correct;
  final Object? explanation;
  _Draft(this.number, this.text, this.options, this.correct, this.explanation);
}
