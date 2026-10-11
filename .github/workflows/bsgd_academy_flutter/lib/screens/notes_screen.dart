import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_nav_bar.dart';
import '../main.dart';
import '../utils/file_download.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  int _cols(double w) {
    if (w < 600) return 1;
    if (w < 900) return 2;
    if (w < 1200) return 3;
    return 4;
  }

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
        title: Text(d['title']?.toString() ?? 'Notice'),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cols = _cols(constraints.maxWidth);
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Notices & Notes',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Important updates from teachers.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('notes')
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
                            child: Text('No notices published yet.'),
                          ),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: cols == 1 ? 2.4 : 0.9,
                        ),
                        itemBuilder: (ctx, i) {
                          final d = docs[i].data() as Map<String, dynamic>;
                          final isPdf = d['attachmentType'] == 'pdf';
                          final img = _imageBytes(d);

                          return Card(
                            clipBehavior: Clip.antiAlias,
                            elevation: 1,
                            child: InkWell(
                              onTap: () => _openDetail(context, d),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (img != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          img,
                                          height: cols == 1 ? 80 : 100,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    else
                                      Icon(
                                        isPdf
                                            ? Icons.picture_as_pdf
                                            : Icons.campaign_outlined,
                                        size: 32,
                                        color: isPdf
                                            ? Colors.red
                                            : AppTheme.royalBlue,
                                      ),
                                    const SizedBox(height: 10),
                                    Text(
                                      d['title'] ?? 'Untitled',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Expanded(
                                      child: Text(
                                        d['body'] ?? '',
                                        maxLines: cols == 1 ? 2 : 4,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ),
                                    if (isPdf)
                                      const Text(
                                        'PDF',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.red,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
