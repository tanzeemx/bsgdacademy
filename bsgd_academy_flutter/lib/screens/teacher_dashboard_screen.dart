import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'teacher_notes_screen.dart';
import 'teacher_suggestion_screen.dart';
import 'teacher_message_screen.dart';
import 'home_screen.dart';

enum TeacherMenu { dashboard, notes, suggestion, message, liveClass }

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  TeacherMenu _selected = TeacherMenu.dashboard;
  bool _rightBarOpen = true;

  Future<void> _logout() async {
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  Widget _buildContent() {
    switch (_selected) {
      case TeacherMenu.dashboard:
        return const _DashboardSummary();
      case TeacherMenu.notes:
        return const TeacherNotesScreen();
      case TeacherMenu.suggestion:
        return const TeacherSuggestionScreen();
      case TeacherMenu.message:
        return const TeacherMessageScreen();
      case TeacherMenu.liveClass:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.live_tv, size: 64, color: AppTheme.textMuted),
              SizedBox(height: 16),
              Text(
                'Live Class — Coming Soon',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final name = auth.currentUserName.isNotEmpty
        ? auth.currentUserName
        : 'Teacher';

    return Scaffold(
      body: Row(
        children: [
          // ========== LEFT SIDEBAR ==========
          Container(
            width: 220,
            color: AppTheme.primaryNavy,
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Icon(
                    Icons.school,
                    color: AppTheme.academicGold,
                    size: 36,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'BSGD Academy',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const Text(
                    'Teacher Panel',
                    style: TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                  const SizedBox(height: 28),
                  _leftItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    menu: TeacherMenu.dashboard,
                  ),
                  _leftItem(
                    icon: Icons.note_alt_outlined,
                    label: 'Notes',
                    menu: TeacherMenu.notes,
                  ),
                  _leftItem(
                    icon: Icons.lightbulb_outline,
                    label: 'Suggestion',
                    menu: TeacherMenu.suggestion,
                  ),
                  _leftItem(
                    icon: Icons.chat_outlined,
                    label: 'Message',
                    menu: TeacherMenu.message,
                  ),
                  _leftItem(
                    icon: Icons.live_tv_outlined,
                    label: 'Live Class',
                    menu: TeacherMenu.liveClass,
                  ),
                  const Spacer(),
                  const Divider(color: Colors.white24, height: 1),
                  ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.white70,
                      size: 20,
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    onTap: _logout,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // ========== MAIN CONTENT ==========
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _menuTitle(_selected),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: AppTheme.royalBlue,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'T',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Toggle right bar
                      IconButton(
                        tooltip: _rightBarOpen
                            ? 'Hide info panel'
                            : 'Show info panel',
                        icon: Icon(
                          _rightBarOpen
                              ? Icons.view_sidebar
                              : Icons.view_sidebar_outlined,
                          color: AppTheme.royalBlue,
                        ),
                        onPressed: () =>
                            setState(() => _rightBarOpen = !_rightBarOpen),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _buildContent()),
              ],
            ),
          ),

          // ========== RIGHT SIDEBAR (collapsible) ==========
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: _rightBarOpen ? 260 : 0,
            child: _rightBarOpen
                ? Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border(
                        left: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: SafeArea(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Quick Info',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () =>
                                    setState(() => _rightBarOpen = false),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _infoTile(Icons.person, 'Logged in as', name),
                          _infoTile(
                            Icons.email_outlined,
                            'Email',
                            AuthService().currentUserEmail.isNotEmpty
                                ? AuthService().currentUserEmail
                                : '—',
                          ),
                          const Divider(height: 28),
                          const Text(
                            'Shortcuts',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _shortcutChip(
                            'Post Note',
                            Icons.note_alt,
                            () => setState(() => _selected = TeacherMenu.notes),
                          ),
                          _shortcutChip(
                            'Add Suggestion',
                            Icons.lightbulb,
                            () => setState(
                              () => _selected = TeacherMenu.suggestion,
                            ),
                          ),
                          _shortcutChip(
                            'Open Messages',
                            Icons.chat,
                            () =>
                                setState(() => _selected = TeacherMenu.message),
                          ),
                          const Divider(height: 28),
                          const Text(
                            'Tips',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Notes are visible to all students.\n'
                            '• Suggestions are for important study material.\n'
                            '• Use Message for private student chat.\n'
                            '• Live Class will be available soon.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _leftItem({
    required IconData icon,
    required String label,
    required TeacherMenu menu,
  }) {
    final selected = _selected == menu;
    return InkWell(
      onTap: () => setState(() => _selected = menu),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppTheme.royalBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : Colors.white70,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white70,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppTheme.royalBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shortcutChip(String label, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.royalBlue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.royalBlue),
              const SizedBox(width: 8),
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
      ),
    );
  }

  String _menuTitle(TeacherMenu m) {
    switch (m) {
      case TeacherMenu.dashboard:
        return 'Dashboard Summary';
      case TeacherMenu.notes:
        return 'Notes & Notifications';
      case TeacherMenu.suggestion:
        return 'Suggestions';
      case TeacherMenu.message:
        return 'Messages';
      case TeacherMenu.liveClass:
        return 'Live Class';
    }
  }
}

// ========== DASHBOARD SUMMARY (richer content) ==========
class _DashboardSummary extends StatelessWidget {
  const _DashboardSummary();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryNavy, AppTheme.royalBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${AuthService().currentUserName.isNotEmpty ? AuthService().currentUserName : "Teacher"}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Manage notes, suggestions, and student messages from one place.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // KPI cards
          const Text(
            'Overview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (ctx, constraints) {
              final wide = constraints.maxWidth > 700;
              return GridView.count(
                crossAxisCount: wide ? 4 : 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: wide ? 1.45 : 1.25,
                children: [
                  _LiveKpi(
                    label: 'Notes Posted',
                    collection: 'notes',
                    icon: Icons.note_alt,
                    color: AppTheme.royalBlue,
                  ),
                  _LiveKpi(
                    label: 'Suggestions',
                    collection: 'suggestions',
                    icon: Icons.lightbulb,
                    color: AppTheme.academicGold,
                  ),
                  _LiveKpi(
                    label: 'Chat Rooms',
                    collection: 'chats',
                    icon: Icons.chat,
                    color: AppTheme.accentEmerald,
                  ),
                  _kpiStatic(
                    'Live Class',
                    'Soon',
                    Icons.live_tv,
                    AppTheme.accentRose,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // Recent notes
          const Text(
            'Recent Notes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notes')
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
                      'No notes yet. Go to Notes to publish your first update.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
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
                      leading: const CircleAvatar(
                        backgroundColor: AppTheme.royalBlue,
                        child: Icon(Icons.note, color: Colors.white, size: 18),
                      ),
                      title: Text(
                        d['title']?.toString().isNotEmpty == true
                            ? d['title']
                            : 'Untitled note',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        d['body'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: d['fileName'] != null
                          ? const Icon(Icons.attach_file, size: 16)
                          : null,
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),

          // Recent suggestions
          const Text(
            'Recent Suggestions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('suggestions')
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
                      'No suggestions yet. Share study tips from the Suggestion menu.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
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
                      leading: const CircleAvatar(
                        backgroundColor: AppTheme.academicGold,
                        child: Icon(
                          Icons.lightbulb,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
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
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _kpiStatic(String label, String value, IconData icon, Color color) {
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
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveKpi extends StatelessWidget {
  final String label;
  final String collection;
  final IconData icon;
  final Color color;

  const _LiveKpi({
    required this.label,
    required this.collection,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snap) {
        final count = snap.hasData ? snap.data!.docs.length.toString() : '—';
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
                  count,
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
