import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class TeacherDashboardSummary extends StatelessWidget {
  const TeacherDashboardSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final name = AuthService().currentUserName.isNotEmpty
        ? AuthService().currentUserName
        : 'Teacher';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryNavy, AppTheme.royalBlue],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $name',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Summary of notes, students, and activity. Use the right sidebar to open each page.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Overview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (ctx, c) {
              final wide = c.maxWidth > 700;
              return GridView.count(
                crossAxisCount: wide ? 4 : 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: wide ? 1.45 : 1.25,
                children: const [
                  _Kpi('notes', 'Notes', Icons.note_alt, AppTheme.royalBlue),
                  _Kpi(
                    'suggestions',
                    'Suggestions',
                    Icons.lightbulb,
                    AppTheme.academicGold,
                  ),
                  _Kpi(
                    'students',
                    'Students',
                    Icons.groups,
                    AppTheme.accentEmerald,
                  ),
                  _Kpi(
                    'attendance',
                    'Attendance',
                    Icons.fact_check,
                    AppTheme.accentRose,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          const Text(
            'Recent Notes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _RecentList(collection: 'notes', emptyText: 'No notes yet.'),
          const SizedBox(height: 24),
          const Text(
            'Recent Suggestions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _RecentList(
            collection: 'suggestions',
            emptyText: 'No suggestions yet.',
          ),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  final String collection;
  final String label;
  final IconData icon;
  final Color color;

  const _Kpi(this.collection, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snap) {
        final n = snap.hasData ? '${snap.data!.docs.length}' : '—';
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 8),
                Text(
                  n,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RecentList extends StatelessWidget {
  final String collection;
  final String emptyText;

  const _RecentList({required this.collection, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snap) {
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                emptyText,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ),
          );
        }
        return Column(
          children: docs.map((doc) {
            final d = doc.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  d['title']?.toString().isNotEmpty == true
                      ? d['title']
                      : 'Untitled',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text(
                  d['body'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
