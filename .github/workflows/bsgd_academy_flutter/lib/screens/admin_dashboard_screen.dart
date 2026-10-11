import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';

/// Admin landing screen. Shows live counts from Firestore only; nothing is
/// fabricated. Real authorization is enforced by `firestore.rules`; the
/// role check here is only a UI guard.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<Map<String, int>> _stats;

  @override
  void initState() {
    super.initState();
    _stats = _load();
  }

  Future<int> _count(Query<Map<String, dynamic>> q) async {
    final snap = await q.count().get();
    return snap.count ?? 0;
  }

  Future<Map<String, int>> _load() async {
    final db = FirebaseFirestore.instance;
    final results = await Future.wait<int>([
      _count(db.collection('users').where('role', isEqualTo: 'student')),
      _count(db.collection('teachers')),
      _count(db.collection('courses')),
      _count(db.collection('exams')),
      _count(db.collection('notes')),
      _count(db.collection('videos')),
    ]);
    return {
      'Students (registered)': results[0],
      'Teachers': results[1],
      'Courses': results[2],
      'Exams': results[3],
      'Notes': results[4],
      'Videos': results[5],
    };
  }

  void _reload() => setState(() => _stats = _load());

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final isAdmin = auth.profile?.isAdmin ?? false;
    final name = auth.currentUserName.isEmpty ? 'Admin' : auth.currentUserName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: isAdmin ? _reload : null,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => auth.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: !isAdmin
          ? const Center(child: Text('Admin access required.'))
          : FutureBuilder<Map<String, int>>(
              future: _stats,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Could not load statistics.'),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _reload,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                final stats = snap.data!;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Welcome, $name',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Live counts from Firestore. Management screens '
                      '(admissions, courses, batches, results) are not '
                      'built yet.',
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final e in stats.entries)
                          _StatCard(label: e.key, value: e.value),
                      ],
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.royalBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
