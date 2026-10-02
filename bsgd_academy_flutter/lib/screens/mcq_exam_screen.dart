import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'results_screen.dart';

class McqExamScreen extends StatefulWidget {
  const McqExamScreen({super.key});

  @override
  State<McqExamScreen> createState() => _McqExamScreenState();
}

class _McqExamScreenState extends State<McqExamScreen> {
  int _secondsLeft = 900;
  Timer? _timer;
  final Map<int, int> _selectedAnswers = {};

  final questions = [
    {
      'q': 'What is the derivative of f(x) = sin(3x)?',
      'options': ['3cos(3x)', '-3cos(3x)', 'cos(3x)', '-cos(3x)'],
      'correct': 0,
      'explanation': 'Chain rule: d/dx[sin(u)] = cos(u)*du/dx. Since u=3x, du/dx=3. Answer: 3cos(3x).'
    },
    {
      'q': 'Evaluate: lim (x->0) [sin(x) / x]',
      'options': ['0', 'Infinity', '1', 'Does not exist'],
      'correct': 2,
      'explanation': 'Standard fundamental trigonometric limit: lim(x->0)[sin(x)/x] = 1.'
    },
    {
      'q': 'What is the integral of e^(2x) dx?',
      'options': ['e^(2x) + C', '(1/2)e^(2x) + C', '2e^(2x) + C', 'e^x + C'],
      'correct': 1,
      'explanation': '∫e^(ax) dx = (1/a)e^(ax) + C. For a=2: (1/2)e^(2x) + C.'
    },
    {
      'q': 'If y = ln(x^2), what is dy/dx?',
      'options': ['1/x^2', '2/x', '2x', 'x/2'],
      'correct': 1,
      'explanation': 'ln(x^2) = 2*ln(x). Derivative of 2*ln(x) is 2/x.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _timer?.cancel();
        _submitExam(auto: true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _submitExam({bool auto = false}) {
    _timer?.cancel();
    int correctCount = 0;
    int wrongCount = 0;

    for (int i = 0; i < questions.length; i++) {
      if (_selectedAnswers.containsKey(i)) {
        if (_selectedAnswers[i] == questions[i]['correct']) {
          correctCount++;
        } else {
          wrongCount++;
        }
      }
    }

    double rawScore = (correctCount * 5.0) - (wrongCount * 0.25);
    if (rawScore < 0) rawScore = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Exam Result Evaluated!', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Final Score: ${rawScore.toStringAsFixed(2)} / 20.00', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.royalBlue)),
            const SizedBox(height: 8),
            Text('Correct Answers: $correctCount', style: const TextStyle(color: AppTheme.accentEmerald, fontWeight: FontWeight.w700)),
            Text('Incorrect Answers: $wrongCount (-0.25 penalty)', style: const TextStyle(color: AppTheme.accentRose, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            const Text('Your result has been registered to the merit board and teacher gradebook.', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.royalBlue, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ResultsScreen()));
            },
            child: const Text('View Merit Board'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mins = _secondsLeft ~/ 60;
    final secs = _secondsLeft % 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live MCQ Assessment'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.accentRose.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer, color: AppTheme.accentRose, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: AppTheme.accentRose, fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: questions.length,
                  itemBuilder: (ctx, i) {
                    final q = questions[i];
                    final opts = q['options'] as List<String>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Q${i + 1}: ${q['q']}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                            const SizedBox(height: 12),
                            ...List.generate(opts.length, (optIdx) {
                              return RadioListTile<int>(
                                dense: true,
                                title: Text(opts[optIdx]),
                                value: optIdx,
                                groupValue: _selectedAnswers[i],
                                onChanged: (val) => setState(() => _selectedAnswers[i] = val!),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.academicGold,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _submitExam(auto: false),
                  child: const Text('Submit Exam & Calculate Score', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}