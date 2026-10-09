import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/app_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../main.dart';
import 'courses_screen.dart';
import 'notes_screen.dart';
import 'public_suggestion_screen.dart';
import 'exams_screen.dart';
import 'results_screen.dart';
import 'home_screen.dart';

enum _StudentPage { summary, exams, notifications, messages }

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  _StudentPage _page = _StudentPage.summary;
  bool _rightOpen = true;

  Future<void> _logout() async {
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _openFullPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _handleSelect(_StudentPage page, {required bool closeDrawer}) {
    setState(() => _page = page);
    if (closeDrawer) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      endDrawer: isWide
          ? null
          : Drawer(
              child: _RightBar(
                selected: _page,
                onSelect: (p) => _handleSelect(p, closeDrawer: true),
                onVisitSite: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                onLogout: () async {
                  Navigator.pop(context);
                  await _logout();
                },
                onOpenResults: () {
                  Navigator.pop(context);
                  _openFullPage(const ResultsScreen());
                },
                onOpenCourses: () {
                  Navigator.pop(context);
                  _openFullPage(const CoursesScreen());
                },
                onOpenSuggestions: () {
                  Navigator.pop(context);
                  _openFullPage(const PublicSuggestionScreen());
                },
                onOpenExamsScreen: () {
                  Navigator.pop(context);
                  _openFullPage(const ExamsScreen());
                },
              ),
            ),
      appBar: AppNavBar(
        onToggleTheme: appState.toggleTheme,
        isDark: appState.isDarkMode,
      ),
      body: Row(
        children: [
          Expanded(child: _buildPage()),
          if (isWide && _rightOpen)
            SizedBox(
              width: 240,
              child: Material(
                elevation: 2,
                child: _RightBar(
                  selected: _page,
                  onSelect: (p) => _handleSelect(p, closeDrawer: false),
                  onVisitSite: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  onLogout: _logout,
                  onOpenResults: () => _openFullPage(const ResultsScreen()),
                  onOpenCourses: () => _openFullPage(const CoursesScreen()),
                  onOpenSuggestions: () =>
                      _openFullPage(const PublicSuggestionScreen()),
                  onOpenExamsScreen: () => _openFullPage(const ExamsScreen()),
                ),
              ),
            ),
          if (isWide)
            InkWell(
              onTap: () => setState(() => _rightOpen = !_rightOpen),
              child: Container(
                width: 18,
                color: AppTheme.royalBlue.withOpacity(0.08),
                child: Center(
                  child: Icon(
                    _rightOpen ? Icons.chevron_right : Icons.chevron_left,
                    size: 16,
                    color: AppTheme.royalBlue,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: isWide
          ? null
          : FloatingActionButton.small(
              backgroundColor: AppTheme.royalBlue,
              tooltip: 'Student menu',
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              child: const Icon(Icons.menu_open, color: Colors.white),
            ),
    );
  }

  Widget _buildPage() {
    switch (_page) {
      case _StudentPage.summary:
        return const _SummaryPage();
      case _StudentPage.exams:
        return _ExamsResultsPage(
          onOpenExams: () => _openFullPage(const ExamsScreen()),
          onOpenResults: () => _openFullPage(const ResultsScreen()),
        );
      case _StudentPage.notifications:
        return const _NotificationsPage();
      case _StudentPage.messages:
        return const _MessagesPage();
    }
  }
}

class _RightBar extends StatelessWidget {
  final _StudentPage selected;
  final ValueChanged<_StudentPage> onSelect;
  final VoidCallback onVisitSite;
  final Future<void> Function() onLogout;
  final VoidCallback onOpenResults;
  final VoidCallback onOpenCourses;
  final VoidCallback onOpenSuggestions;
  final VoidCallback onOpenExamsScreen;

  const _RightBar({
    required this.selected,
    required this.onSelect,
    required this.onVisitSite,
    required this.onLogout,
    required this.onOpenResults,
    required this.onOpenCourses,
    required this.onOpenSuggestions,
    required this.onOpenExamsScreen,
  });

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final name = auth.currentUserName.isNotEmpty
        ? auth.currentUserName
        : 'Student';

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryNavy,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Student Portal',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _item(
                  Icons.dashboard_outlined,
                  'Summary',
                  selected == _StudentPage.summary,
                  () => onSelect(_StudentPage.summary),
                ),
                _item(
                  Icons.quiz_outlined,
                  'Exam & Result',
                  selected == _StudentPage.exams,
                  () => onSelect(_StudentPage.exams),
                ),
                _item(
                  Icons.emoji_events_outlined,
                  'Results',
                  false,
                  onOpenResults,
                ),
                _item(
                  Icons.notifications_outlined,
                  'Notification',
                  selected == _StudentPage.notifications,
                  () => onSelect(_StudentPage.notifications),
                ),
                _item(
                  Icons.chat_bubble_outline,
                  'Message',
                  selected == _StudentPage.messages,
                  () => onSelect(_StudentPage.messages),
                ),
                _item(
                  Icons.menu_book_outlined,
                  'Courses',
                  false,
                  onOpenCourses,
                ),
                _item(
                  Icons.lightbulb_outline,
                  'Suggestions',
                  false,
                  onOpenSuggestions,
                ),
                const Divider(),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.public, size: 20),
                  title: const Text(
                    'Visit Site',
                    style: TextStyle(fontSize: 13.5),
                  ),
                  onTap: onVisitSite,
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.logout,
                    size: 20,
                    color: AppTheme.accentRose,
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppTheme.accentRose,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () => onLogout(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String label, bool active, VoidCallback onTap) {
    return ListTile(
      dense: true,
      selected: active,
      selectedTileColor: AppTheme.royalBlue.withOpacity(0.1),
      leading: Icon(icon, size: 20, color: active ? AppTheme.royalBlue : null),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: active ? FontWeight.w800 : FontWeight.w600,
          color: active ? AppTheme.royalBlue : null,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _SummaryPage extends StatelessWidget {
  const _SummaryPage();

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final name = auth.currentUserName.isNotEmpty
        ? auth.currentUserName
        : 'Student';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Welcome, $name',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'Your learning overview',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth > 700 ? 4 : 2;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: const [
                _KpiCard(
                  icon: Icons.menu_book,
                  label: 'Courses',
                  value: '—',
                  color: AppTheme.royalBlue,
                ),
                _KpiCard(
                  icon: Icons.quiz,
                  label: 'Exams',
                  value: '—',
                  color: AppTheme.academicGold,
                ),
                _KpiCard(
                  icon: Icons.notifications,
                  label: 'Notices',
                  value: '—',
                  color: AppTheme.accentEmerald,
                ),
                _KpiCard(
                  icon: Icons.chat,
                  label: 'Messages',
                  value: '—',
                  color: AppTheme.accentRose,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Latest notices',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notes')
              .orderBy('createdAt', descending: true)
              .limit(6)
              .snapshots(),
          builder: (context, snap) {
            final docs = (snap.data?.docs ?? []).where((doc) {
              final d = doc.data() as Map<String, dynamic>;
              return d['archived'] != true;
            }).toList();
            if (docs.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No notices yet.'),
                ),
              );
            }
            return Column(
              children: docs.map((doc) {
                final d = doc.data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(
                      Icons.campaign_outlined,
                      color: AppTheme.royalBlue,
                    ),
                    title: Text(
                      d['title'] ?? 'Notice',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      d['body'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NoticeScreen()),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamsResultsPage extends StatelessWidget {
  final VoidCallback onOpenExams;
  final VoidCallback onOpenResults;

  const _ExamsResultsPage({
    required this.onOpenExams,
    required this.onOpenResults,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Exam & Result',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Open exams or view published results.',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Card(
                child: InkWell(
                  onTap: onOpenExams,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.quiz_outlined,
                          color: AppTheme.royalBlue,
                          size: 28,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Exams',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'MCQ & written tests',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                child: InkWell(
                  onTap: onOpenResults,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          color: AppTheme.academicGold,
                          size: 28,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Results',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Published scores',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NotificationsPage extends StatelessWidget {
  const _NotificationsPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Notifications',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Notices and updates from teachers.',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notes')
              .orderBy('createdAt', descending: true)
              .limit(40)
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = (snap.data?.docs ?? []).where((doc) {
              final d = doc.data() as Map<String, dynamic>;
              return d['archived'] != true;
            }).toList();
            if (docs.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No notifications yet.'),
                ),
              );
            }
            return Column(
              children: docs.map((doc) {
                final d = doc.data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.royalBlue.withOpacity(0.12),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: AppTheme.royalBlue,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      d['title'] ?? 'Notice',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      d['body'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NoticeScreen()),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _MessagesPage extends StatelessWidget {
  const _MessagesPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Messages',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Direct messages from teachers.',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('messages')
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
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 48,
                        color: AppTheme.royalBlue,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No messages yet',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'When a teacher messages you, it will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: docs.map((doc) {
                final d = doc.data() as Map<String, dynamic>;
                final from = (d['fromName'] ?? 'Teacher').toString();
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.royalBlue.withOpacity(0.15),
                      child: Text(
                        from.isNotEmpty ? from[0].toUpperCase() : 'T',
                      ),
                    ),
                    title: Text(
                      from,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      d['text'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
