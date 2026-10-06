import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_nav_bar.dart';
import '../main.dart';
import 'admission_screen.dart';
import 'video_watch_screen.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

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
                'Academic Batches & Courses',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enroll in batches, or watch teacher video courses.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 24),

              _batchCard(
                context,
                title: 'HSC Higher Math 1st & 2nd Paper',
                meta: 'Class 12 • Group: Science',
                price: '৳ 3,000 / Mo',
              ),
              _batchCard(
                context,
                title: 'Physics Mechanics & Electromagnetism',
                meta: 'Class 12 • Group: Science',
                price: '৳ 3,000 / Mo',
              ),
              _batchCard(
                context,
                title: 'SSC Special Model Test Series',
                meta: 'Class 10 • Group: All Groups',
                price: '৳ 2,500 / Full',
              ),
              _batchCard(
                context,
                title: 'University Engineering Admission Care',
                meta: 'Admission • Group: Science',
                price: '৳ 8,500 / Full',
              ),

              const SizedBox(height: 28),
              const Text(
                'Teacher Video Courses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tap a course, then tap a video to watch.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 12),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('courses')
                    .orderBy('createdAt', descending: true)
                    .limit(40)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snap.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('No video courses yet.'),
                      ),
                    );
                  }
                  return Column(
                    children: docs.map((doc) {
                      final d = doc.data() as Map<String, dynamic>;
                      final courseId = doc.id;
                      final title = d['title'] ?? 'Course';
                      final count = d['videoCount'] ?? 0;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ExpansionTile(
                          leading: const Icon(
                            Icons.play_circle_outline,
                            color: AppTheme.royalBlue,
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            '${d['description'] ?? ''}\n$count video(s)',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          children: [
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('courses')
                                  .doc(courseId)
                                  .collection('videos')
                                  .orderBy('order')
                                  .snapshots(),
                              builder: (context, vSnap) {
                                final videos = vSnap.data?.docs ?? [];
                                if (videos.isEmpty) {
                                  return const ListTile(
                                    title: Text('No videos in this course yet.'),
                                  );
                                }
                                return Column(
                                  children: videos.map((v) {
                                    final vd =
                                        v.data() as Map<String, dynamic>;
                                    final vTitle = vd['title'] ?? 'Video';
                                    final url = vd['url'] ?? '';
                                    final thumb = vd['thumbnail'] ?? '';
                                    return ListTile(
                                      leading: thumb.toString().isNotEmpty
                                          ? Image.network(
                                              thumb,
                                              width: 64,
                                              height: 40,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(Icons.play_arrow),
                                            )
                                          : const Icon(Icons.play_arrow),
                                      title: Text(
                                        vTitle,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      subtitle: Text(
                                        vd['duration']?.toString() ?? '',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      trailing: const Icon(
                                        Icons.play_circle_fill,
                                        color: AppTheme.royalBlue,
                                      ),
                                      onTap: () {
                                        if (url.toString().isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('No video URL.'),
                                            ),
                                          );
                                          return;
                                        }
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => VideoWatchScreen(
                                              courseId: courseId,
                                              videoId: v.id,
                                              title: vTitle,
                                              youtubeUrl: url,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _batchCard(
    BuildContext context, {
    required String title,
    required String meta,
    required String price,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.royalBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.menu_book, color: AppTheme.royalBlue),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    meta,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    color: AppTheme.royalBlue,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.academicGold,
                    foregroundColor: Colors.black,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdmissionScreen(),
                    ),
                  ),
                  child: const Text(
                    'Enroll',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}