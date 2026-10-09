import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StudentPracticeExamScreen extends StatefulWidget {
  final String examId;
  final String examTitle;

  const StudentPracticeExamScreen({
    super.key,
    required this.examId,
    required this.examTitle,
  });

  @override
  State<StudentPracticeExamScreen> createState() =>
      _StudentPracticeExamScreenState();
}

class _StudentPracticeExamScreenState extends State<StudentPracticeExamScreen> {
  int _index = 0;
  int? _selected;
  bool _revealed = false;
  int _score = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.examTitle)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('exams')
            .doc(widget.examId)
            .collection('questions')
            .orderBy('order')
            .snapshots(),
        builder: (context, snap) {
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No questions in this exam.'));
          }
          if (_index >= docs.length) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Done! Score: $_score / ${docs.length}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _index = 0;
                        _selected = null;
                        _revealed = false;
                        _score = 0;
                      });
                    },
                    child: const Text('Practice again'),
                  ),
                ],
              ),
            );
          }

          final d = docs[_index].data() as Map<String, dynamic>;
          final options = List<String>.from(d['options'] ?? []);
          final correct = d['correctIndex'] as int? ?? 0;
          final explanation = d['explanation']?.toString() ?? '';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Question ${_index + 1} of ${docs.length}',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Text(
                d['text'] ?? '',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(options.length, (i) {
                Color? border;
                Color? fill;
                if (_revealed) {
                  if (i == correct) {
                    border = Colors.green;
                    fill = Colors.green.withOpacity(0.12);
                  } else if (i == _selected && i != correct) {
                    border = Colors.red;
                    fill = Colors.red.withOpacity(0.1);
                  }
                } else if (_selected == i) {
                  border = AppTheme.royalBlue;
                  fill = AppTheme.royalBlue.withOpacity(0.08);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: fill,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: _revealed
                          ? null
                          : () => setState(() => _selected = i),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: border ?? Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          '${String.fromCharCode(65 + i)}.  ${options[i]}',
                          style: const TextStyle(fontSize: 14.5),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // Expand when wrong
              if (_revealed && _selected != correct) ...[
                const SizedBox(height: 12),
                Card(
                  color: Colors.green.withOpacity(0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Correct: ${String.fromCharCode(65 + correct)}. ${options[correct]}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.green,
                          ),
                        ),
                        if (explanation.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(explanation, style: const TextStyle(height: 1.4)),
                        ],
                      ],
                    ),
                  ),
                ),
              ],

              if (_revealed && _selected == correct) ...[
                const SizedBox(height: 12),
                const Text(
                  'Correct!',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],

              const SizedBox(height: 20),
              if (!_revealed)
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.royalBlue,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: _selected == null
                      ? null
                      : () {
                          final ok = _selected == correct;
                          setState(() {
                            _revealed = true;
                            if (ok) _score++;
                          });
                        },
                  child: const Text('Check answer'),
                )
              else
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.academicGold,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () {
                    setState(() {
                      _index++;
                      _selected = null;
                      _revealed = false;
                    });
                  },
                  child: Text(
                    _index + 1 >= docs.length ? 'Finish' : 'Next question',
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}