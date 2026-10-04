
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({super.key});

  @override
  State<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  String? _openCourseId;
  String? _openCourseTitle;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (_openCourseId != null) {
      return _CoursePlaylistView(
        courseId: _openCourseId!,
        courseTitle: _openCourseTitle ?? 'Course',
        onBack: () => setState(() {
          _openCourseId = null;
          _openCourseTitle = null;
        }),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Row(
            children: [
              const Text(
                'My Courses',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.royalBlue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _showCreateCourseDialog(uid),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create Course'),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('courses')
                .where('teacherId', isEqualTo: uid)
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return Center(
                  child: Text(
                    'No courses yet.\nPress "Create Course" to add one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                );
              }
              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: docs.length,
                itemBuilder: (ctx, i) {
                  final d = docs[i].data() as Map<String, dynamic>;
                  final id = docs[i].id;
                  final title = d['title'] ?? 'Untitled';
                  final desc = d['description'] ?? '';
                  final videoCount = d['videoCount'] ?? 0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(14),
                      leading: CircleAvatar(
                        backgroundColor:
                            AppTheme.royalBlue.withOpacity(0.12),
                        child: const Icon(
                          Icons.play_circle_fill,
                          color: AppTheme.royalBlue,
                        ),
                      ),
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        '$desc\n$videoCount video(s)',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => setState(() {
                        _openCourseId = id;
                        _openCourseTitle = title;
                      }),
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

  Future<void> _showCreateCourseDialog(String uid) async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Course'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Course title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
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
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    final title = titleCtrl.text.trim();
    if (title.isEmpty) return;

    await FirebaseFirestore.instance.collection('courses').add({
      'title': title,
      'description': descCtrl.text.trim(),
      'teacherId': uid,
      'teacherName': AuthService().currentUserName,
      'videoCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course created. Open it to add video URLs.'),
        ),
      );
    }
  }
}

// ========== PLAYLIST (URL-based) ==========

// ========== PLAYLIST + IN-APP YOUTUBE PLAYER ==========
class _CoursePlaylistView extends StatefulWidget {
  final String courseId;
  final String courseTitle;
  final VoidCallback onBack;

  const _CoursePlaylistView({
    required this.courseId,
    required this.courseTitle,
    required this.onBack,
  });

  @override
  State<_CoursePlaylistView> createState() => _CoursePlaylistViewState();
}

class _CoursePlaylistViewState extends State<_CoursePlaylistView> {
  YoutubePlayerController? _ytController;
  String? _currentVideoId;
  String? _currentTitle;

  /// Extract YouTube video id from common URL formats
  String? _extractYoutubeId(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return null;

    // https://youtu.be/VIDEO_ID
    if (uri.host.contains('youtu.be')) {
      if (uri.pathSegments.isNotEmpty) return uri.pathSegments.first;
    }

    // https://www.youtube.com/watch?v=VIDEO_ID
    if (uri.queryParameters['v'] != null) {
      return uri.queryParameters['v'];
    }

    // https://www.youtube.com/embed/VIDEO_ID
    // https://www.youtube.com/shorts/VIDEO_ID
    if (uri.pathSegments.isNotEmpty) {
      final i = uri.pathSegments.indexWhere(
        (s) => s == 'embed' || s == 'shorts' || s == 'v',
      );
      if (i != -1 && i + 1 < uri.pathSegments.length) {
        return uri.pathSegments[i + 1];
      }
    }
    return null;
  }

  void _playVideo(String title, String url) {
    final id = _extractYoutubeId(url);
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not a valid YouTube URL. Use youtube.com or youtu.be link.'),
        ),
      );
      return;
    }

    _ytController?.close();
    _ytController = YoutubePlayerController.fromVideoId(
      videoId: id,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        mute: false,
      ),
    );

    setState(() {
      _currentVideoId = id;
      _currentTitle = title;
    });
  }

  Future<void> _addVideoByUrl() async {
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add YouTube Video'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Video title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(
                labelText: 'YouTube URL',
                hintText: 'https://youtube.com/watch?v=... or youtu.be/...',
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
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final title = titleCtrl.text.trim();
    final url = urlCtrl.text.trim();
    if (title.isEmpty || url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Title and URL required.')),
        );
      }
      return;
    }

    if (_extractYoutubeId(url) == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please paste a valid YouTube link.')),
        );
      }
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('videos')
        .add({
      'title': title,
      'url': url,
      'teacherId': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'order': DateTime.now().millisecondsSinceEpoch,
    });

    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .update({'videoCount': FieldValue.increment(1)});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video added to playlist.')),
      );
    }
  }

  @override
  void dispose() {
    _ytController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
              Expanded(
                child: Text(
                  widget.courseTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.royalBlue,
                  foregroundColor: Colors.white,
                ),
                onPressed: _addVideoByUrl,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add YouTube Video'),
              ),
            ],
          ),
        ),

        // In-app player
        if (_ytController != null && _currentVideoId != null)
          Container(
            width: double.infinity,
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_currentTitle != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: Text(
                      _currentTitle!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: YoutubePlayer(
                    controller: _ytController!,
                    aspectRatio: 16 / 9,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            height: 180,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const Text(
              'Select a video from the playlist to play here',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),

        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Playlist',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
        ),

        // Playlist list
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('courses')
                .doc(widget.courseId)
                .collection('videos')
                .orderBy('order')
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No videos yet.\nAdd a YouTube link.',
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: docs.length,
                itemBuilder: (ctx, i) {
                  final d = docs[i].data() as Map<String, dynamic>;
                  final title = d['title'] ?? 'Video ${i + 1}';
                  final url = d['url'] ?? '';
                  final id = _extractYoutubeId(url);
                  final isPlaying = id != null && id == _currentVideoId;

                  return Card(
                    color: isPlaying
                        ? AppTheme.royalBlue.withOpacity(0.12)
                        : null,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.royalBlue,
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () async {
                          await docs[i].reference.delete();
                          await FirebaseFirestore.instance
                              .collection('courses')
                              .doc(widget.courseId)
                              .update({
                            'videoCount': FieldValue.increment(-1),
                          });
                        },
                      ),
                      onTap: () => _playVideo(title, url),
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