import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'student_take_exam_screen.dart';

class ExamsScreen extends StatelessWidget {
  final bool embedded;

  const ExamsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final body = StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('exams')
          .where('type', isEqualTo: 'mcq')
          .where('published', isEqualTo: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs =
            List<QueryDocumentSnapshot>.from(snap.data?.docs ?? []);
        docs.sort((a, b) {
          final ta = (a.data() as Map)['createdAt'];
          final tb = (b.data() as Map)['createdAt'];
          if (ta is Timestamp && tb is Timestamp) return tb.compareTo(ta);
          return 0;
        });

        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No published MCQ exams yet.\nTeachers publish from Teacher → Exams.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final d = doc.data() as Map<String, dynamic>;
            final title = d['title']?.toString() ?? 'Exam';
            final qCount = d['questionCount'] ?? 0;
            final marks = d['fullMarks'] ?? '—';
            final time = d['durationMinutes'] ?? 30;
            final klass = d['studentClass']?.toString() ?? '';
            final subject = d['subject']?.toString() ?? '';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: AppTheme.royalBlue.withOpacity(0.12),
                  child: const Icon(Icons.quiz, color: AppTheme.royalBlue),
                ),
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    [
                      if (klass.isNotEmpty) 'Class $klass',
                      if (subject.isNotEmpty) subject,
                      '$qCount Q',
                      '$marks marks',
                      '$time min',
                    ].join(' • '),
                  ),
                ),
                trailing: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.royalBlue,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentTakeExamScreen(
                          examId: doc.id,
                          examTitle: title,
                          durationMinutes: int.tryParse('$time') ?? 30,
                        ),
                      ),
                    );
                  },
                  child: const Text('Start'),
                ),
              ),
            );
          },
        );
      },
    );

    if (embedded) return body;

    return Scaffold(
      appBar: AppBar(title: const Text('Exams')),
      body: body,
    );
  }
}