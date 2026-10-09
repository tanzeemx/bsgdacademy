import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'create_mcq_screen.dart'; // MUST exist

class TeacherExamsScreen extends StatefulWidget {
  const TeacherExamsScreen({super.key});

  @override
  State<TeacherExamsScreen> createState() => _TeacherExamsScreenState();
}

class _TeacherExamsScreenState extends State<TeacherExamsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Theme.of(context).cardColor,
          child: TabBar(
            controller: _tabs,
            labelColor: AppTheme.royalBlue,
            unselectedLabelColor: AppTheme.textMuted,
            indicatorColor: AppTheme.royalBlue,
            tabs: const [
              Tab(text: 'MCQ'),
              Tab(text: 'Written'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _McqExamList(
                onCreate: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateMcqExamForm(),
                    ),
                  );
                },
              ),
              const _WrittenPlaceholder(),
            ],
          ),
        ),
      ],
    );
  }
}

class _McqExamList extends StatelessWidget {
  final VoidCallback onCreate;

  const _McqExamList({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'MCQ Exams',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.royalBlue,
              ),
              onPressed: onCreate,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create MCQ Exam'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('exams')
              .where('type', isEqualTo: 'mcq')
              .snapshots(),
          builder: (context, snap) {
            if (snap.hasError) return Text('Error: ${snap.error}');
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = List<QueryDocumentSnapshot>.from(
              snap.data?.docs ?? [],
            );
            docs.sort((a, b) {
              final ta = (a.data() as Map)['createdAt'];
              final tb = (b.data() as Map)['createdAt'];
              if (ta is Timestamp && tb is Timestamp) return tb.compareTo(ta);
              return 0;
            });

            if (docs.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No MCQ exams yet. Tap “Create MCQ Exam”.'),
                ),
              );
            }

            return Column(
              children: docs.map((doc) {
                final d = doc.data() as Map<String, dynamic>;
                final published = d['published'] == true;
                final title = d['title']?.toString() ?? 'Untitled';

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: published
                          ? AppTheme.accentEmerald.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      child: Icon(
                        Icons.quiz,
                        color: published
                            ? AppTheme.accentEmerald
                            : Colors.orange,
                      ),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      [
                        if (d['studentClass'] != null)
                          'Class ${d['studentClass']}',
                        d['subject'] ?? '',
                        '${d['questionCount'] ?? 0} Q',
                        published ? 'Published' : 'Draft',
                      ].where((e) => e.toString().isNotEmpty).join(' • '),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) async {
                        if (v == 'questions') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateMcqScreen(
                                examId: doc.id,
                                examTitle: title,
                              ),
                            ),
                          );
                        } else if (v == 'publish') {
                          await doc.reference.update({'published': true});
                        } else if (v == 'unpublish') {
                          await doc.reference.update({'published': false});
                        } else if (v == 'delete') {
                          await doc.reference.delete();
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'questions',
                          child: Text('Edit questions'),
                        ),
                        PopupMenuItem(
                          value: published ? 'unpublish' : 'publish',
                          child: Text(published ? 'Unpublish' : 'Publish'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CreateMcqScreen(examId: doc.id, examTitle: title),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _WrittenPlaceholder extends StatelessWidget {
  const _WrittenPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_note, size: 48, color: AppTheme.royalBlue),
          SizedBox(height: 12),
          Text(
            'Written exams — coming next',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

/// Exam metadata form (public so TeacherExamsScreen can open it)
class CreateMcqExamForm extends StatefulWidget {
  const CreateMcqExamForm({super.key});

  @override
  State<CreateMcqExamForm> createState() => _CreateMcqExamFormState();
}

class _CreateMcqExamFormState extends State<CreateMcqExamForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _timeCtrl = TextEditingController(text: '30');
  final _markCtrl = TextEditingController(text: '20');
  final _attemptsCtrl = TextEditingController(text: '1');

  String _classLevel = '12';
  DateTime _start = DateTime.now();
  DateTime _expire = DateTime.now().add(const Duration(days: 7));
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _subjectCtrl.dispose();
    _timeCtrl.dispose();
    _markCtrl.dispose();
    _attemptsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _expire,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (d == null) return;
    setState(() {
      if (isStart) {
        _start = d;
      } else {
        _expire = d;
      }
    });
  }

  Future<void> _createAndGoQuestions() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final ref = await FirebaseFirestore.instance.collection('exams').add({
        'title': _nameCtrl.text.trim(),
        'type': 'mcq',
        'studentClass': _classLevel,
        'subject': _subjectCtrl.text.trim(),
        'durationMinutes': int.tryParse(_timeCtrl.text.trim()) ?? 30,
        'fullMarks': int.tryParse(_markCtrl.text.trim()) ?? 20,
        'attempts': int.tryParse(_attemptsCtrl.text.trim()) ?? 1,
        'startDate': Timestamp.fromDate(_start),
        'expireDate': Timestamp.fromDate(_expire),
        'published': false,
        'questionCount': 0,
        'teacherId': uid,
        'teacherName': AuthService().currentUserName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CreateMcqScreen(examId: ref.id, examTitle: _nameCtrl.text.trim()),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
    return Scaffold(
      appBar: AppBar(title: const Text('Create MCQ Exam')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Exam Name *',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _classLevel,
              decoration: const InputDecoration(
                labelText: 'Class *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '11', child: Text('Class 11')),
                DropdownMenuItem(value: '12', child: Text('Class 12')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _classLevel = v);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _subjectCtrl,
              decoration: const InputDecoration(
                labelText: 'Subject *',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _timeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Full Time (min)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _markCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Full Mark',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(isStart: true),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text('Start: ${fmt.format(_start)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(isStart: false),
                    icon: const Icon(Icons.event_busy, size: 16),
                    label: Text('Expire: ${fmt.format(_expire)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _attemptsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Attempts',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.academicGold,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _saving ? null : _createAndGoQuestions,
              child: Text(
                _saving ? 'Saving…' : 'Create the Question Now',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
