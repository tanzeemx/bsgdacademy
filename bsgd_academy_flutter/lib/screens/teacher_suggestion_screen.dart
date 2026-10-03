import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class TeacherSuggestionScreen extends StatefulWidget {
  const TeacherSuggestionScreen({super.key});

  @override
  State<TeacherSuggestionScreen> createState() =>
      _TeacherSuggestionScreenState();
}

class _TeacherSuggestionScreenState extends State<TeacherSuggestionScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _uploading = false;
  String? _fileName;
  Uint8List? _fileBytes;
  String? _fileType;

  Future<void> _pickFile() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg', 'webp'],
      );

      if (file == null) return;

      final bytes = await file.readAsBytes();

      setState(() {
        _fileName = file.name;
        _fileBytes = bytes;
        final ext = file.extension?.toLowerCase() ?? '';
        _fileType = ext == 'pdf' ? 'pdf' : 'image';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('File pick error: $e')));
      }
    }
  }

  Future<void> _publish() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty && body.isEmpty && _fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something or attach a file.')),
      );
      return;
    }

    setState(() => _uploading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final teacherName = AuthService().currentUserName;
      String? fileUrl;

      if (_fileBytes != null && _fileName != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('suggestions')
            .child('${DateTime.now().millisecondsSinceEpoch}_$_fileName');
        await ref.putData(_fileBytes!);
        fileUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('suggestions').add({
        'title': title,
        'body': body,
        'fileUrl': fileUrl,
        'fileType': _fileType,
        'fileName': _fileName,
        'teacherId': uid,
        'teacherName': teacherName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _titleCtrl.clear();
      _bodyCtrl.clear();
      setState(() {
        _fileName = null;
        _fileBytes = null;
        _fileType = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Suggestion published.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Upload Important Suggestion',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _bodyCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Suggestion text',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _uploading ? null : _pickFile,
                        icon: const Icon(Icons.attach_file, size: 18),
                        label: Text(_fileName ?? 'Attach Image / PDF'),
                      ),
                      if (_fileName != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(() {
                            _fileName = null;
                            _fileBytes = null;
                            _fileType = null;
                          }),
                        ),
                      ],
                      const Spacer(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.academicGold,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: _uploading ? null : _publish,
                        icon: _uploading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.publish, size: 18),
                        label: const Text('Publish Suggestion'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Published Suggestions',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('suggestions')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Center(child: Text('No suggestions yet.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: docs.length,
                itemBuilder: (ctx, i) {
                  final d = docs[i].data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const Icon(
                        Icons.lightbulb,
                        color: AppTheme.academicGold,
                      ),
                      title: Text(
                        d['title'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${d['body'] ?? ''}\n'
                        '${d['fileName'] != null ? '📎 ${d['fileName']}' : ''}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('suggestions')
                              .doc(docs[i].id)
                              .delete();
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
