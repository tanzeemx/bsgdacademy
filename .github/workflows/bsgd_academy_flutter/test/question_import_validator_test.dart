import 'package:bsgd_online_academy/services/question_import_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JSON import', () {
    test('accepts a valid question', () {
      final r = QuestionImportValidator.parseJson(
        '[{"text":"2+2?","options":["3","4","5","6"],"correctIndex":1}]',
      );
      expect(r.isClean, isTrue);
      expect(r.valid.single.correctIndex, 1);
    });

    test('rejects out-of-range answer instead of defaulting to 0', () {
      final r = QuestionImportValidator.parseJson(
        '[{"text":"Q","options":["a","b","c","d"],"correctIndex":9}]',
      );
      expect(r.valid, isEmpty);
      expect(r.issues.single.message, contains('outside'));
    });

    test('rejects missing answer', () {
      final r = QuestionImportValidator.parseJson(
        '[{"text":"Q","options":["a","b","c","d"]}]',
      );
      expect(r.valid, isEmpty);
      expect(r.issues, hasLength(1));
    });

    test('rejects too few options and duplicate options', () {
      final r = QuestionImportValidator.parseJson(
        '[{"text":"A","options":["x"],"correctIndex":0},'
        '{"text":"B","options":["x","X"],"correctIndex":0}]',
      );
      expect(r.valid, isEmpty);
      expect(r.issues, hasLength(2));
    });

    test('flags duplicates within file and against existing', () {
      final r = QuestionImportValidator.parseJson(
        '[{"text":"Same?","options":["a","b"],"correctIndex":0},'
        '{"text":" same? ","options":["a","b"],"correctIndex":0},'
        '{"text":"Old","options":["a","b"],"correctIndex":0}]',
        existingTexts: {'old'},
      );
      expect(r.valid, hasLength(1));
      expect(r.issues, hasLength(2));
    });

    test('invalid JSON is reported, not thrown', () {
      final r = QuestionImportValidator.parseJson('not json');
      expect(r.isClean, isFalse);
      expect(r.issues, isNotEmpty);
    });
  });

  group('TXT import', () {
    const sample = '''
Q: Capital of France?
A) Berlin
B) Paris
C) Rome
D) Madrid
ANSWER: B
EXPLANATION: Paris is the capital.

Q: Largest planet
A) Mars
B) Jupiter
ANSWER: B
''';

    test('parses blocks', () {
      final r = QuestionImportValidator.parseTxt(sample);
      expect(r.isClean, isTrue);
      expect(r.valid, hasLength(2));
      expect(r.valid.first.correctIndex, 1);
      expect(r.valid.first.explanation, 'Paris is the capital.');
    });

    test('answer letter beyond options is rejected', () {
      final r = QuestionImportValidator.parseTxt(
        'Q: x\nA) a\nB) b\nANSWER: D',
      );
      expect(r.valid, isEmpty);
      expect(r.issues, hasLength(1));
    });

    test('out-of-order option letters are rejected', () {
      final r = QuestionImportValidator.parseTxt(
        'Q: x\nA) a\nC) c\nANSWER: A',
      );
      expect(r.valid, isEmpty);
    });

    test('arbitrary text is not treated as a question', () {
      final r = QuestionImportValidator.parseTxt('hello world');
      expect(r.valid, isEmpty);
      expect(r.issues, isNotEmpty);
    });
  });
}
