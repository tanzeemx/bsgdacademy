import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final _bodyFocus = FocusNode();
  bool _publishing = false;
  String? _editingId;
  TextAlign _bodyAlign = TextAlign.left;

  String? _attachmentName;
  String? _attachmentBase64;
  String? _attachmentType;
  bool _loadingFile = false;

  static const int _maxBytes = 700 * 1024;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _bodyFocus.dispose();
    super.dispose();
  }

  void _applyWrap(String left, String right) {
    _bodyFocus.requestFocus();
    final text = _bodyCtrl.text;
    var sel = _bodyCtrl.selection;
    if (!sel.isValid) {
      sel = TextSelection.collapsed(offset: text.length);
    }
    final start = sel.start;
    final end = sel.end;
    final selected = text.substring(start, end);
    final middle = selected.isEmpty ? 'text' : selected;
    final inserted = '$left$middle$right';
    final newText = text.replaceRange(start, end, inserted);
    final midStart = start + left.length;
    final midEnd = midStart + middle.length;
    _bodyCtrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection(baseOffset: midStart, extentOffset: midEnd),
    );
  }

  String _selectedText() {
    final sel = _bodyCtrl.selection;
    if (!sel.isValid || sel.start == sel.end) return '';
    return _bodyCtrl.text.substring(sel.start, sel.end);
  }

  Future<void> _insertUrl() async {
    _bodyFocus.requestFocus();
    final labelCtrl = TextEditingController(
      text: _selectedText().isEmpty ? 'link text' : _selectedText(),
    );
    final urlCtrl = TextEditingController(text: 'https://');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Insert link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelCtrl,
              decoration: const InputDecoration(
                labelText: 'Label',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(
                labelText: 'URL',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Insert'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final label = labelCtrl.text.trim().isEmpty
        ? 'link'
        : labelCtrl.text.trim();
    final url = urlCtrl.text.trim().isEmpty ? 'https://' : urlCtrl.text.trim();
    _applyWrap('[', ']($url)');
    final t = _bodyCtrl.text;
    final sel = _bodyCtrl.selection;
    if (sel.isValid && sel.start != sel.end) {
      final nt = t.replaceRange(sel.start, sel.end, label);
      _bodyCtrl.value = TextEditingValue(
        text: nt,
        selection: TextSelection.collapsed(offset: sel.start + label.length),
      );
    }
  }

  Future<void> _pickFileBase64() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp', 'pdf'],
      );
      if (file == null) return;

      setState(() => _loadingFile = true);
      final name = file.name;
      final bytes = await file.readAsBytes() as Uint8List;
      if (bytes.isEmpty) return;

      if (bytes.length > _maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'File too large (${(bytes.length / 1024).toStringAsFixed(0)} KB). Max ~700 KB.',
              ),
            ),
          );
        }
        return;
      }

      final ext = name.split('.').last.toLowerCase();
      final looksPdf =
          bytes.length >= 4 &&
          bytes[0] == 0x25 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x44 &&
          bytes[3] == 0x46;
      final type = (ext == 'pdf' || looksPdf) ? 'pdf' : 'image';

      setState(() {
        _attachmentName = name;
        _attachmentBase64 = base64Encode(bytes);
        _attachmentType = type;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Attached $type: $name (${(bytes.length / 1024).toStringAsFixed(0)} KB)',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loadingFile = false);
    }
  }

  void _clearAttachment() {
    setState(() {
      _attachmentName = null;
      _attachmentBase64 = null;
      _attachmentType = null;
    });
  }

  Future<void> _publish() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty && body.isEmpty && _attachmentBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title, content, or file.')),
      );
      return;
    }

    setState(() => _publishing = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final data = <String, dynamic>{
        'title': title.isEmpty ? 'Untitled' : title,
        'body': body,
        'teacherId': uid,
        'teacherName': AuthService().currentUserName,
        'textAlign': _bodyAlign.name,
        'archived': false,
        'attachmentName': _attachmentName,
        'attachmentType': _attachmentType,
        'attachmentBase64': _attachmentBase64,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_editingId != null) {
        await FirebaseFirestore.instance
            .collection('suggestions')
            .doc(_editingId)
            .update(data);
      } else {
        data['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('suggestions').add(data);
      }

      _titleCtrl.clear();
      _bodyCtrl.clear();
      _clearAttachment();
      setState(() {
        _editingId = null;
        _bodyAlign = TextAlign.left;
      });

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Suggestion saved.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  void _loadForEdit(String id, Map<String, dynamic> d) {
    _titleCtrl.text = d['title']?.toString() ?? '';
    _bodyCtrl.text = d['body']?.toString() ?? '';
    setState(() {
      _editingId = id;
      _attachmentName = d['attachmentName']?.toString();
      _attachmentBase64 = d['attachmentBase64']?.toString();
      _attachmentType = d['attachmentType']?.toString();
      final a = d['textAlign']?.toString();
      _bodyAlign = a == 'justify' ? TextAlign.justify : TextAlign.left;
    });
  }

  Uint8List? _decodeImage(Map<String, dynamic> d) {
    if (d['attachmentType'] == 'pdf') return null;
    final b64 = d['attachmentBase64']?.toString();
    if (b64 == null || b64.isEmpty) return null;
    try {
      final bytes = base64Decode(b64);
      if (bytes.length >= 4 &&
          bytes[0] == 0x25 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x44 &&
          bytes[3] == 0x46) {
        return null;
      }
      return bytes;
    } catch (_) {
      return null;
    }
  }

  void _viewItem(Map<String, dynamic> d) {
    final isPdf = d['attachmentType'] == 'pdf';
    final img = _decodeImage(d);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(d['title']?.toString() ?? 'Untitled'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(
                d['body']?.toString() ?? '',
                style: const TextStyle(height: 1.5, fontSize: 15),
              ),
              if (img != null) ...[
                const SizedBox(height: 16),
                Image.memory(img, fit: BoxFit.contain),
              ],
              if (isPdf) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(d['attachmentName']?.toString() ?? 'PDF'),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _archiveItem(DocumentReference ref) async {
    await ref.update({'archived': true});
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Archived.')));
    }
  }

  Future<void> _deleteItem(DocumentReference ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete suggestion?'),
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
    if (ok == true) await ref.delete();
  }

  Widget _attachmentPreviewChip() {
    if (_attachmentBase64 == null) return const SizedBox.shrink();
    final isPdf = _attachmentType == 'pdf';
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          if (!isPdf)
            Builder(
              builder: (_) {
                try {
                  final bytes = base64Decode(_attachmentBase64!);
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.memory(
                      bytes,
                      height: 72,
                      width: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 40),
                    ),
                  );
                } catch (_) {
                  return const Icon(Icons.broken_image);
                }
              },
            )
          else
            const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _attachmentName ?? (isPdf ? 'PDF' : 'Image'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _clearAttachment,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth > 900;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_editingId != null)
                      Row(
                        children: [
                          Chip(
                            label: const Text('Editing'),
                            backgroundColor: AppTheme.academicGold.withOpacity(
                              0.25,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _titleCtrl.clear();
                              _bodyCtrl.clear();
                              _clearAttachment();
                              setState(() => _editingId = null);
                            },
                            child: const Text('Cancel edit'),
                          ),
                        ],
                      ),
                    TextField(
                      controller: _titleCtrl,
                      style: const TextStyle(fontSize: 28, height: 1.3),
                      decoration: const InputDecoration(
                        hintText: 'Add title',
                        hintStyle: TextStyle(
                          fontSize: 28,
                          color: Colors.black38,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _tb('B', () => _applyWrap('**', '**'), bold: true),
                            _tb('I', () => _applyWrap('_', '_'), italic: true),
                            _tb('J', () {
                              setState(() {
                                _bodyAlign = _bodyAlign == TextAlign.justify
                                    ? TextAlign.left
                                    : TextAlign.justify;
                              });
                            }),
                            _sep(),
                            _tbIcon(Icons.link, _insertUrl),
                            _tbIcon(Icons.attach_file, _pickFileBase64),
                          ],
                        ),
                      ),
                    ),
                    if (_loadingFile) const LinearProgressIndicator(),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(minHeight: 200),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextField(
                        controller: _bodyCtrl,
                        focusNode: _bodyFocus,
                        maxLines: null,
                        minLines: 8,
                        textAlign: _bodyAlign,
                        style: const TextStyle(fontSize: 15, height: 1.55),
                        decoration: const InputDecoration(
                          hintText: 'Write your suggestion…',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _loadingFile ? null : _pickFileBase64,
                      icon: const Icon(Icons.attach_file, size: 18),
                      label: Text(
                        _loadingFile
                            ? 'Loading…'
                            : 'Attach image / PDF (max ~700 KB)',
                      ),
                    ),
                    _attachmentPreviewChip(),
                    if (!wide) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.royalBlue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _publishing ? null : _publish,
                          child: Text(
                            _publishing
                                ? 'Saving…'
                                : (_editingId != null ? 'Update' : 'Publish'),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    const Text(
                      'Published Suggestions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _publishedList(),

                    // Student feedback from public page
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 12),
                    const Text(
                      'Student feedback',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Messages sent from the public Suggestions page.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    const _StudentFeedbackList(),
                  ],
                ),
              ),
            ),
            if (wide)
              Container(
                width: 260,
                margin: const EdgeInsets.only(top: 16, right: 16),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _editingId != null ? 'Update' : 'Publish',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Files as Base64 (max ~700 KB).',
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.royalBlue,
                          ),
                          onPressed: _publishing ? null : _publish,
                          child: Text(
                            _editingId != null ? 'Update' : 'Publish',
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () {
                            _titleCtrl.clear();
                            _bodyCtrl.clear();
                            _clearAttachment();
                            setState(() => _editingId = null);
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _publishedList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('suggestions')
          .orderBy('createdAt', descending: true)
          .limit(40)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = (snap.data?.docs ?? []).where((doc) {
          final d = doc.data() as Map<String, dynamic>;
          return d['archived'] != true;
        }).toList();
        if (docs.isEmpty) {
          return const Text(
            'No suggestions yet.',
            style: TextStyle(color: Colors.black45),
          );
        }
        return Column(
          children: docs.map((doc) {
            final d = doc.data() as Map<String, dynamic>;
            final isPdf = d['attachmentType'] == 'pdf';
            final img = _decodeImage(d);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: isPdf
                        ? const Icon(Icons.picture_as_pdf, color: Colors.red)
                        : (img != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.memory(
                                    img,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.lightbulb_outline,
                                      color: AppTheme.academicGold,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.lightbulb_outline,
                                  color: AppTheme.academicGold,
                                )),
                    title: Text(
                      d['title'] ?? 'Untitled',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      d['body'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: isPdf
                        ? const Text(
                            'PDF',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.red,
                            ),
                          )
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      bottom: 8,
                    ),
                    child: Wrap(
                      children: [
                        TextButton(
                          onPressed: () => _viewItem(d),
                          child: const Text('View'),
                        ),
                        TextButton(
                          onPressed: () => _loadForEdit(doc.id, d),
                          child: const Text('Edit'),
                        ),
                        TextButton(
                          onPressed: () => _archiveItem(doc.reference),
                          child: const Text('Archive'),
                        ),
                        TextButton(
                          onPressed: () => _deleteItem(doc.reference),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _tb(
    String label,
    VoidCallback onTap, {
    bool bold = false,
    bool italic = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );
  }

  Widget _tbIcon(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 18),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(),
    );
  }

  Widget _sep() => Container(
    width: 1,
    height: 18,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    color: Colors.grey.shade300,
  );
}

/// Student feedback from public Suggestions page
class _StudentFeedbackList extends StatelessWidget {
  const _StudentFeedbackList();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('suggestion_feedback')
          .orderBy('createdAt', descending: true)
          .limit(40)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No student feedback yet.',
                style: TextStyle(color: Colors.black45),
              ),
            ),
          );
        }
        return Column(
          children: docs.map((doc) {
            final d = doc.data() as Map<String, dynamic>;
            final unread = d['read'] != true;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: unread ? AppTheme.royalBlue.withOpacity(0.06) : null,
              child: ListTile(
                leading: Icon(
                  Icons.feedback_outlined,
                  color: unread ? AppTheme.royalBlue : Colors.grey,
                ),
                title: Text(
                  d['userName'] ?? 'Student',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(d['message'] ?? ''),
                trailing: unread
                    ? TextButton(
                        child: const Text('Mark read'),
                        onPressed: () => doc.reference.update({'read': true}),
                      )
                    : const Icon(Icons.check, color: Colors.green, size: 18),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
