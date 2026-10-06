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

  int _cols(double w) {
    if (w < 600) return 1;
    if (w < 900) return 2;
    if (w < 1200) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    final batches = [
      {
        'title': 'HSC Higher Math 1st & 2nd Paper',
        'meta': 'Class 12 • Science',
        'price': '৳ 3,000 / Mo',
      },
      {
        'title': 'Physics Mechanics & Electromagnetism',
        'meta': 'Class 12 • Science',
        'price': '৳ 3,000 / Mo',
      },
      {
        'title': 'SSC Special Model Test Series',
        'meta': 'Class 10 • All Groups',
        'price': '৳ 2,500 / Full',
      },
      {
        'title': 'University Engineering Admission Care',
        'meta': 'Admission • Science',
        'price': '৳ 8,500 / Full',
      },
    ];

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
                    'Academic Batches & Courses',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Enroll in batches or watch teacher video courses.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // Batch cards grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: batches.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: cols == 1 ? 2.6 : 1.15,
                    ),
                    itemBuilder: (ctx, i) {
                      final b = batches[i];
                      return Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.menu_book,
                                color: AppTheme.royalBlue,
                                size: 28,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                b['title']!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                b['meta']!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      b['price']!,
                                      style: const TextStyle(
                                        color: AppTheme.royalBlue,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.academicGold,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
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
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 28),
                  const Text(
                    'Teacher Video Courses',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tap a course card, then open a video.',
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

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: cols == 1 ? 2.2 : 1.05,
                        ),
                        itemBuilder: (ctx, i) {
                          final d = docs[i].data() as Map<String, dynamic>;
                          final courseId = docs[i].id;
                          final title = d['title'] ?? 'Course';
                          final count = d['videoCount'] ?? 0;

                          return Card(
                            elevation: 1,
                            child: InkWell(
                              onTap: () => _openCourseVideos(
                                context,
                                courseId,
                                title.toString(),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.play_circle_outline,
                                      color: AppTheme.royalBlue,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      title.toString(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Expanded(
                                      child: Text(
                                        d['description']?.toString() ?? '',
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '$count video(s)',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.royalBlue,
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

  void _openCourseVideos(BuildContext context, String courseId, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          maxChildSize: 0.9,
          minChildSize: 0.35,
          builder: (_, scrollCtrl) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('courses')
                        .doc(courseId)
                        .collection('videos')
                        .orderBy('order')
                        .snapshots(),
                    builder: (context, snap) {
                      final videos = snap.data?.docs ?? [];
                      if (videos.isEmpty) {
                        return const Center(
                          child: Text('No videos in this course yet.'),
                        );
                      }
                      return ListView.builder(
                        controller: scrollCtrl,
                        itemCount: videos.length,
                        itemBuilder: (_, i) {
                          final vd = videos[i].data() as Map<String, dynamic>;
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
                              vTitle.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(vd['duration']?.toString() ?? ''),
                            trailing: const Icon(
                              Icons.play_circle_fill,
                              color: AppTheme.royalBlue,
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              if (url.toString().isEmpty) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VideoWatchScreen(
                                    courseId: courseId,
                                    videoId: videos[i].id,
                                    title: vTitle.toString(),
                                    youtubeUrl: url.toString(),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
