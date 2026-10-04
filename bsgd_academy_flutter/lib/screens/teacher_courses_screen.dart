import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'demo_teacher_id';

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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'My Courses & Video Manager',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.royalBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () => _showCreateCourseDialog(uid),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'Create Course',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
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
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Text(
                            'No courses created yet.\nPress "Create Course" to add your first batch.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (ctx, i) {
                      final d = docs[i].data() as Map<String, dynamic>;
                      final id = docs[i].id;
                      final title = d['title'] ?? 'Untitled Course';
                      final desc = d['description'] ?? '';
                      final videoCount = d['videoCount'] ?? 0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.royalBlue.withOpacity(
                              0.12,
                            ),
                            child: const Icon(
                              Icons.play_circle_fill,
                              color: AppTheme.royalBlue,
                            ),
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '$desc\n$videoCount video(s) uploaded',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12.5),
                            ),
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateCourseDialog(String uid) async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Create New Course',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
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
            const SizedBox(height: 14),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.royalBlue,
              foregroundColor: Colors.white,
            ),
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
          content: Text(
            'Course created successfully. Open it to add YouTube videos.',
          ),
        ),
      );
    }
  }
}

// ========== PLAYLIST + IN-APP YOUTUBE PLAYER VIEW ==========
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
  String? _currentDesc;

  String? _extractYoutubeId(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return null;

    if (uri.host.contains('youtu.be')) {
      if (uri.pathSegments.isNotEmpty) return uri.pathSegments.first;
    }

    if (uri.queryParameters['v'] != null) {
      return uri.queryParameters['v'];
    }

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

  void _playVideo(String title, String url, String desc) {
    final id = _extractYoutubeId(url);
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Not a valid YouTube URL. Use youtube.com or youtu.be link.',
          ),
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
      _currentDesc = desc;
    });
  }

  Future<void> _addVideoByUrl() async {
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '45m');
    final thumbCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Add YouTube Video',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Video title *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlCtrl,
                decoration: const InputDecoration(
                  labelText: 'YouTube URL *',
                  hintText: 'https://youtube.com/watch?v=...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Video Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Duration (e.g. 45m)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: thumbCtrl,
                decoration: const InputDecoration(
                  labelText: 'Custom Thumbnail URL (Optional)',
                  hintText: 'Leave blank to auto-fetch from YouTube',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.royalBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add Video'),
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
          const SnackBar(content: Text('Title and YouTube URL are required.')),
        );
      }
      return;
    }

    final ytId = _extractYoutubeId(url);
    if (ytId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please paste a valid YouTube link.')),
        );
      }
      return;
    }

    // Auto-derive thumbnail from YouTube if custom thumbnail is empty
    final customThumb = thumbCtrl.text.trim();
    final finalThumbnail = customThumb.isNotEmpty
        ? customThumb
        : 'https://img.youtube.com/vi/$ytId/hqdefault.jpg';

    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'demo_teacher_id';

    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('videos')
        .add({
          'title': title,
          'url': url,
          'description': descCtrl.text.trim(),
          'duration': durationCtrl.text.trim(),
          'thumbnail': finalThumbnail,
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
        const SnackBar(
          content: Text(
            'Video successfully added with description & thumbnail!',
          ),
        ),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Back Button
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: widget.onBack,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.courseTitle,
                      style: const TextStyle(
                        fontSize: 18,
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
              const SizedBox(height: 20),

              // In-App Player Card
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_currentTitle != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        color: AppTheme.primaryNavy,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentTitle!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            if (_currentDesc != null &&
                                _currentDesc!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                _currentDesc!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    if (_ytController != null && _currentVideoId != null)
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: YoutubePlayer(controller: _ytController!),
                      )
                    else
                      Container(
                        width: double.infinity,
                        height: 220,
                        color: Colors.grey.shade900,
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_outline,
                              size: 48,
                              color: Colors.white54,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Select a video from the playlist below to play',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Course Playlist',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 12),

              // Playlist Stream with thumbnails & descriptions
              StreamBuilder<QuerySnapshot>(
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
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Center(
                          child: Text(
                            'No videos in this course playlist yet.\nClick "Add YouTube Video" above.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (ctx, i) {
                      final d = docs[i].data() as Map<String, dynamic>;
                      final title = d['title'] ?? 'Video ${i + 1}';
                      final url = d['url'] ?? '';
                      final desc = d['description'] ?? '';
                      final duration = d['duration'] ?? '45m';
                      final thumb = d['thumbnail'] ?? '';
                      final id = _extractYoutubeId(url);
                      final isPlaying = id != null && id == _currentVideoId;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: isPlaying
                            ? AppTheme.royalBlue.withOpacity(0.12)
                            : null,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: thumb.isNotEmpty
                                ? Image.network(
                                    thumb,
                                    width: 75,
                                    height: 45,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 75,
                                      height: 45,
                                      color: AppTheme.royalBlue,
                                      child: const Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 75,
                                    height: 45,
                                    color: AppTheme.royalBlue,
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                          subtitle: Text(
                            '$duration${desc.isNotEmpty ? ' • $desc' : ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11.5),
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
                          onTap: () => _playVideo(title, url, desc),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
