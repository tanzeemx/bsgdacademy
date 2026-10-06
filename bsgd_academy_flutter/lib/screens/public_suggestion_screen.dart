import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_nav_bar.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../utils/file_download.dart';

class PublicSuggestionScreen extends StatelessWidget {
  const PublicSuggestionScreen({super.key});

  Uint8List? _imageBytes(Map<String, dynamic> d) {
    return decodeImageBase64(
      d['attachmentBase64']?.toString(),
      d['attachmentType']?.toString(),
    );
  }

  void _openDetail(BuildContext context, Map<String, dynamic> d) {
    final img = _imageBytes(d);
    final isPdf = d['attachmentType'] == 'pdf';
    final b64 = d['attachmentBase64']?.toString();
    final name =
        d['attachmentName']?.toString() ?? (isPdf ? 'file.pdf' : 'image.jpg');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(d['title']?.toString() ?? 'Suggestion'),
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
              if (isPdf && b64 != null && b64.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(name)),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (b64 != null && b64.isNotEmpty) ...[
            TextButton.icon(
              icon: const Icon(Icons.visibility),
              label: const Text('View'),
              onPressed: () => viewBase64File(
                context: context,
                base64Data: b64,
                type: d['attachmentType']?.toString() ?? 'image',
                fileName: name,
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Download'),
              onPressed: () => downloadBase64File(
                context: context,
                base64Data: b64,
                fileName: name,
                type: d['attachmentType']?.toString() ?? 'image',
              ),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppNavBar(
        onToggleTheme: appState.toggleTheme,
        isDark: appState.isDarkMode,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Teacher Suggestions',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tips and suggestions from faculty. Open one to View or Download files.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('suggestions')
                    .orderBy('createdAt', descending: true)
                    .limit(50)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final docs = (snap.data?.docs ?? []).where((doc) {
                    final d = doc.data() as Map<String, dynamic>;
                    return d['archived'] != true;
                  }).toList();

                  if (docs.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No suggestions published yet.'),
                      ),
                    );
                  }

                  return Column(
                    children: docs.map((doc) {
                      final d = doc.data() as Map<String, dynamic>;
                      final isPdf = d['attachmentType'] == 'pdf';
                      final img = _imageBytes(d);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: isPdf
                              ? const CircleAvatar(
                                  backgroundColor: Color(0xFFFFEBEE),
                                  child: Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.red,
                                  ),
                                )
                              : (img != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          img,
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const CircleAvatar(
                                        backgroundColor: Color(0xFFFFF8E1),
                                        child: Icon(
                                          Icons.lightbulb_outline,
                                          color: AppTheme.academicGold,
                                        ),
                                      )),
                          title: Text(
                            d['title'] ?? 'Untitled',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              d['body'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openDetail(context, d),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Send feedback to teachers',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Questions or comments about these suggestions — teachers see them on the Suggestion page in the dashboard.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              const _FeedbackBox(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackBox extends StatefulWidget {
  const _FeedbackBox();

  @override
  State<_FeedbackBox> createState() => _FeedbackBoxState();
}

class _FeedbackBoxState extends State<_FeedbackBox> {
  final _ctrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final t = _ctrl.text.trim();
    if (t.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Write something first.')));
      return;
    }
    setState(() => _sending = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final name = AuthService().currentUserName.isNotEmpty
          ? AuthService().currentUserName
          : (user?.email ?? 'Student');

      await FirebaseFirestore.instance.collection('suggestion_feedback').add({
        'message': t,
        'userName': name,
        'userId': user?.uid ?? '',
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _ctrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback sent. Teachers will see it.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _ctrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Your feedback or question…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.royalBlue,
                ),
                onPressed: _sending ? null : _send,
                icon: _sending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, size: 18),
                label: Text(_sending ? 'Sending…' : 'Send feedback'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
