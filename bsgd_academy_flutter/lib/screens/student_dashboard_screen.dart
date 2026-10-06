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
import 'login_screen.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final auth = AuthService();
    final name = auth.currentUserName.isNotEmpty
        ? auth.currentUserName
        : 'Student';

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppNavBar(
        onToggleTheme: appState.toggleTheme,
        isDark: appState.isDarkMode,
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth > 800;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, $name',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              auth.isStudentLoggedIn
                                  ? 'You are signed in to the Student Portal.'
                                  : 'Guest view — sign in for full access.',
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!auth.isStudentLoggedIn)
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(
                                  initialRole: UserRole.student,
                                  targetScreen: StudentDashboardScreen(),
                                ),
                              ),
                            );
                          },
                          child: const Text('Student Login'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quick action cards
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: wide ? 4 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: wide ? 1.2 : 1.1,
                    children: [
                      _dashCard(
                        context,
                        icon: Icons.menu_book,
                        title: 'Courses',
                        color: AppTheme.royalBlue,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CoursesScreen(),
                          ),
                        ),
                      ),
                      _dashCard(
                        context,
                        icon: Icons.campaign_outlined,
                        title: 'Notices',
                        color: AppTheme.accentEmerald,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NoticeScreen(),
                          ),
                        ),
                      ),
                      _dashCard(
                        context,
                        icon: Icons.lightbulb_outline,
                        title: 'Suggestions',
                        color: AppTheme.academicGold,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PublicSuggestionScreen(),
                          ),
                        ),
                      ),
                      _dashCard(
                        context,
                        icon: Icons.video_library_outlined,
                        title: 'Live / Videos',
                        color: AppTheme.accentRose,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CoursesScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),
                  const Text(
                    'Latest notices',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('notes')
                        .orderBy('createdAt', descending: true)
                        .limit(5)
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                d['body'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NoticeScreen(),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
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

  Widget _dashCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
