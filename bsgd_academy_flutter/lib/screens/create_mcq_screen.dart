import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../services/ai_mcq_service.dart';

class CreateMcqScreen extends StatefulWidget {
  final String examId;
  final String examTitle;

  const CreateMcqScreen({
    super.key,
    required this.examId,
    required this.examTitle,
  });

  @override
  State<CreateMcqScreen> createState() => _CreateMcqScreenState();
}

class _CreateMcqScreenState extends State<CreateMcqScreen> {
  final _qCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _opts = List.generate(4, (_) => TextEditingController());
  int _correct = 0;
  bool _saving = false;
  bool _showManualForm = true;

  @override
  void dispose() {
    _qCtrl.dispose();
    _expCtrl.dispose();
    for (final c in _opts) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _addQuestion({bool clearAfter = true}) async {
    final q = _qCtrl.text.trim();
    final options = _opts.map((c) => c.text.trim()).toList();
    if (q.isEmpty || options.any((o) => o.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill question and all 4 options')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final col = FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examId)
          .collection('questions');
      final existing = await col.get();
      final order = existing.size + 1;

      await col.add({
        'text': q,
        'options': options,
        'correctIndex': _correct,
        'explanation': _expCtrl.text.trim().isEmpty
            ? 'Correct answer: ${options[_correct]}'
            : _expCtrl.text.trim(),
        'order': order,
        'source': 'manual',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examId)
          .update({'questionCount': FieldValue.increment(1)});

      if (clearAfter) {
        _qCtrl.clear();
        _expCtrl.clear();
        for (final c in _opts) {
          c.clear();
        }
        setState(() => _correct = 0);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<int?> _askMcqCount() async {
    final ctrl = TextEditingController(text: '10');
    final n = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('How many MCQs?'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Number of questions',
            border: OutlineInputBorder(),
            helperText: 'e.g. 5, 10, 20',
          ),
          onSubmitted: (_) {
            final v = int.tryParse(ctrl.text.trim()) ?? 0;
            Navigator.pop(ctx, v > 0 ? v : null);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text.trim()) ?? 0;
              Navigator.pop(ctx, v > 0 ? v : null);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    return n;
  }

  Future<void> _saveGenerated(
    List<GeneratedMcq> questions,
    String source,
  ) async {
    if (questions.isEmpty) return;
    final col = FirebaseFirestore.instance
        .collection('exams')
        .doc(widget.examId)
        .collection('questions');
    final existing = await col.get();
    var order = existing.size;
    final batch = FirebaseFirestore.instance.batch();
    for (final q in questions) {
      order++;
      batch.set(col.doc(), {
        'text': q.text,
        'options': q.options,
        'correctIndex': q.correctIndex,
        'explanation': q.explanation.isEmpty
            ? 'Correct: ${q.options[q.correctIndex]}'
            : q.explanation,
        'order': order,
        'source': source,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    batch.update(
      FirebaseFirestore.instance.collection('exams').doc(widget.examId),
      {'questionCount': FieldValue.increment(questions.length)},
    );
    await batch.commit();
  }

  /// AI MCQ: ask count → generate N new questions from notes
  Future<void> _uploadAiMcq() async {
    if (!AiMcqService.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Need GEMINI_API_KEY.\n'
            'flutter run ... --dart-define=GEMINI_API_KEY=your_key',
          ),
          duration: Duration(seconds: 6),
        ),
      );
      return;
    }

    final count = await _askMcqCount();
    if (count == null || count < 1) return;

    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg', 'webp', 'txt'],
      );
      if (file == null) return;

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('AI generating $count MCQs…'),
                ],
              ),
            ),
          ),
        ),
      );

      final bytes = await file.readAsBytes();
      final name = file.name.toLowerCase();
      List<GeneratedMcq> questions;

      if (name.endsWith('.txt')) {
        questions = await AiMcqService.fromText(
          utf8.decode(bytes),
          extractOnly: false,
          questionCount: count,
        );
      } else if (name.endsWith('.pdf')) {
        questions = await AiMcqService.fromPdf(
          bytes,
          extractOnly: false,
          questionCount: count,
        );
      } else {
        final mime = name.endsWith('.png')
            ? 'image/png'
            : name.endsWith('.webp')
            ? 'image/webp'
            : 'image/jpeg';
        questions = await AiMcqService.fromImage(
          bytes: bytes,
          mimeType: mime,
          extractOnly: false,
          questionCount: count,
        );
      }

      if (questions.length > count) {
        questions = questions.take(count).toList();
      }

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      if (questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI returned no questions')),
        );
        return;
      }

      setState(() => _saving = true);
      await _saveGenerated(questions, 'ai_generate');
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI generated ${questions.length} MCQs')),
      );
    } catch (e) {
      if (!mounted) return;
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (_) {}
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI failed: $e'),
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  /// Upload MCQ: extract existing paper + answers
  Future<void> _uploadExistingMcqPaper() async {
    if (!AiMcqService.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Need GEMINI_API_KEY.\n'
            'flutter run ... --dart-define=GEMINI_API_KEY=your_key',
          ),
          duration: Duration(seconds: 6),
        ),
      );
      return;
    }

    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg', 'webp'],
      );
      if (file == null) return;

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Reading MCQ paper… extracting Q + answers…'),
                ],
              ),
            ),
          ),
        ),
      );

      final bytes = await file.readAsBytes();
      final name = file.name.toLowerCase();
      final List<GeneratedMcq> questions;

      if (name.endsWith('.pdf')) {
        questions = await AiMcqService.fromPdf(bytes, extractOnly: true);
      } else {
        final mime = name.endsWith('.png')
            ? 'image/png'
            : name.endsWith('.webp')
            ? 'image/webp'
            : 'image/jpeg';
        questions = await AiMcqService.fromImage(
          bytes: bytes,
          mimeType: mime,
          extractOnly: true,
        );
      }

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      if (questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No questions found in the paper')),
        );
        return;
      }

      setState(() => _saving = true);
      await _saveGenerated(questions, 'upload_mcq_paper');
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported ${questions.length} MCQs from paper')),
      );
    } catch (e) {
      if (!mounted) return;
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (_) {}
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload MCQ failed: $e'),
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  Future<void> _editQuestionModal(
    String docId,
    Map<String, dynamic> data,
  ) async {
    final editQCtrl = TextEditingController(
      text: data['text']?.toString() ?? '',
    );
    final editExpCtrl = TextEditingController(
      text: data['explanation']?.toString() ?? '',
    );
    final existingOpts = List<String>.from(data['options'] ?? ['', '', '', '']);
    while (existingOpts.length < 4) {
      existingOpts.add('');
    }
    final editOpts = List.generate(
      4,
      (i) => TextEditingController(text: existingOpts[i]),
    );
    var editCorrect = data['correctIndex'] as int? ?? 0;
    if (editCorrect < 0 || editCorrect > 3) editCorrect = 0;

    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'Edit MCQ Question',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: editQCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Question *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(4, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Radio<int>(
                            value: i,
                            groupValue: editCorrect,
                            onChanged: (v) =>
                                setDialogState(() => editCorrect = v ?? 0),
                          ),
                          Expanded(
                            child: TextField(
                              controller: editOpts[i],
                              decoration: InputDecoration(
                                labelText:
                                    'Option ${String.fromCharCode(65 + i)} *',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  TextField(
                    controller: editExpCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Explanation',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.royalBlue,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );

    if (updated != true) {
      editQCtrl.dispose();
      editExpCtrl.dispose();
      for (final c in editOpts) {
        c.dispose();
      }
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examId)
          .collection('questions')
          .doc(docId)
          .update({
            'text': editQCtrl.text.trim(),
            'options': editOpts.map((c) => c.text.trim()).toList(),
            'correctIndex': editCorrect,
            'explanation': editExpCtrl.text.trim(),
          });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    }

    editQCtrl.dispose();
    editExpCtrl.dispose();
    for (final c in editOpts) {
      c.dispose();
    }
  }

  Future<void> _deleteQuestion(DocumentReference ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete question?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await ref.delete();
    await FirebaseFirestore.instance
        .collection('exams')
        .doc(widget.examId)
        .update({'questionCount': FieldValue.increment(-1)});
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Question deleted')));
    }
  }

  Future<void> _publish() async {
    await FirebaseFirestore.instance
        .collection('exams')
        .doc(widget.examId)
        .update({'published': true});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exam published for students')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.examTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: _publish,
            child: const Text(
              'Publish',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Manage Exam Questions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _saving ? null : _uploadAiMcq,
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('AI MCQ'),
              ),
              OutlinedButton.icon(
                onPressed: _saving ? null : _uploadExistingMcqPaper,
                icon: const Icon(Icons.quiz_outlined, size: 18),
                label: const Text('Upload MCQ'),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.royalBlue,
                ),
                onPressed: () => setState(() => _showManualForm = true),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Create Manual MCQ'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AiMcqService.isConfigured
                ? 'AI MCQ: enter count, upload notes → new questions.\n'
                      'Upload MCQ: upload exam paper image/PDF → extract Q + answers.'
                : 'Start with --dart-define=GEMINI_API_KEY=... to enable AI.',
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          if (_showManualForm) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            TextField(
              controller: _qCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Question *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ...List.generate(4, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Radio<int>(
                      value: i,
                      groupValue: _correct,
                      onChanged: (v) => setState(() => _correct = v ?? 0),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _opts[i],
                        decoration: InputDecoration(
                          labelText: 'Option ${String.fromCharCode(65 + i)} *',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            TextField(
              controller: _expCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Explanation (shown if student is wrong)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saving
                        ? null
                        : () => _addQuestion(clearAfter: true),
                    icon: const Icon(Icons.add),
                    label: const Text('Add More'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.academicGold,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _saving
                        ? null
                        : () => _addQuestion(clearAfter: true),
                    child: Text(_saving ? 'Saving…' : 'Save question'),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          const Text(
            'Questions in this exam',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('exams')
                .doc(widget.examId)
                .collection('questions')
                .orderBy('order')
                .snapshots(),
            builder: (context, snap) {
              if (snap.hasError) return Text('Error: ${snap.error}');
              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No questions added yet.'),
                  ),
                );
              }
              return Column(
                children: List.generate(docs.length, (i) {
                  final doc = docs[i];
                  final d = doc.data() as Map<String, dynamic>;
                  final opts = List<String>.from(d['options'] ?? []);
                  final ci = d['correctIndex'] as int? ?? 0;
                  final explanation = d['explanation']?.toString() ?? '';
                  final text = d['text']?.toString() ?? '';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: AppTheme.royalBlue.withOpacity(0.12),
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.royalBlue,
                          ),
                        ),
                      ),
                      title: Text(
                        text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'Correct: ${String.fromCharCode(65 + ci)}. '
                        '${ci < opts.length ? opts[ci] : ''}',
                        style: const TextStyle(
                          color: AppTheme.accentEmerald,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.blue,
                            ),
                            onPressed: () => _editQuestionModal(doc.id, d),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _deleteQuestion(doc.reference),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              SelectableText(
                                text,
                                style: const TextStyle(height: 1.4),
                              ),
                              const SizedBox(height: 10),
                              ...List.generate(opts.length, (optIdx) {
                                final isCorrect = optIdx == ci;
                                return Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 5),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isCorrect
                                        ? Colors.green.withOpacity(0.12)
                                        : Colors.grey.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isCorrect
                                          ? Colors.green
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    '${String.fromCharCode(65 + optIdx)}. ${opts[optIdx]}'
                                    '${isCorrect ? '  ✓' : ''}',
                                    style: TextStyle(
                                      fontWeight: isCorrect
                                          ? FontWeight.w800
                                          : FontWeight.w500,
                                      color: isCorrect
                                          ? Colors.green.shade800
                                          : null,
                                    ),
                                  ),
                                );
                              }),
                              if (explanation.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Explanation: $explanation',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
