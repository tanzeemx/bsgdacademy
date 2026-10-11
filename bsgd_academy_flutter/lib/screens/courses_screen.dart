import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

class CoursesScreen extends StatelessWidget {
  final bool embedded;

  const CoursesScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final body = StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('video_courses')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data?.docs ?? [];

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Teacher Video Courses',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap a course, then open a video.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            if (docs.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No video courses yet.\nTeachers add them from the teacher panel.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, c) {
                  final cross = c.maxWidth > 900
                      ? 3
                      : c.maxWidth > 600
                      ? 2
                      : 1;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cross,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.15,
                    ),
                    itemBuilder: (context, i) {
                      final d = docs[i].data() as Map<String, dynamic>;
                      final title = d['title']?.toString() ?? 'Course';
                      final desc = d['description']?.toString() ?? '';
                      final videos = List<Map<String, dynamic>>.from(
                        (d['videos'] as List?)
                                ?.map(
                                  (e) => Map<String, dynamic>.from(e as Map),
                                )
                                .toList() ??
                            [],
                      );

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _CourseVideosPage(
                                  title: title,
                                  videos: videos,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.play_circle_outline,
                                  size: 36,
                                  color: AppTheme.royalBlue,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                                if (desc.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    desc,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                Text(
                                  '${videos.length} video(s)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
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
        );
      },
    );

    if (embedded) return body;

    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: body,
    );
  }
}

class _CourseVideosPage extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> videos;

  const _CourseVideosPage({required this.title, required this.videos});

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: videos.isEmpty
          ? const Center(child: Text('No videos in this course.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: videos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final v = videos[i];
                final vTitle = v['title']?.toString() ?? 'Video ${i + 1}';
                final url = v['url']?.toString() ?? '';
                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.play_circle_fill,
                      color: AppTheme.royalBlue,
                      size: 36,
                    ),
                    title: Text(
                      vTitle,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: url.isEmpty
                        ? null
                        : Text(
                            url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11),
                          ),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: url.isEmpty ? null : () => _open(url),
                  ),
                );
              },
            ),
    );
  }
}
