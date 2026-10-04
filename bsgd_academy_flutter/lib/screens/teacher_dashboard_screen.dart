import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'teacher_dashboard_summary.dart';
import 'teacher_notes_screen.dart';
import 'teacher_suggestion_screen.dart';
import 'teacher_message_screen.dart';
import 'teacher_students_screen.dart';
import 'teacher_attendance_screen.dart';
import 'teacher_courses_screen.dart';
import 'home_screen.dart';
import 'courses_screen.dart';
import 'live_class_screen.dart';
import 'contact_screen.dart';
import 'admission_screen.dart';

enum TeacherMenu {
  dashboard,
  notes,
  suggestion,
  message,
  students,
  attendance,
  courses,
  liveClass,
}

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  TeacherMenu _selected = TeacherMenu.dashboard;
  bool _leftOpen = true;
  bool _rightOpen = true;

  Future<void> _logout() async {
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  void _viewSite() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  Widget _buildContent() {
    switch (_selected) {
      case TeacherMenu.dashboard:
        return const TeacherDashboardSummary();
      case TeacherMenu.notes:
        return const TeacherNotesScreen();
      case TeacherMenu.suggestion:
        return const TeacherSuggestionScreen();
      case TeacherMenu.message:
        return const TeacherMessageScreen();
      case TeacherMenu.students:
        return const TeacherStudentsScreen();
      case TeacherMenu.attendance:
        return const TeacherAttendancePage();
      case TeacherMenu.courses:
        return const TeacherCoursesScreen();
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
          // ========== LEFT: PUBLIC DRAWER STYLE ==========
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: _leftOpen ? 260 : 0,
            child: _leftOpen
                ? Container(
                    color: Colors.white,
                    child: SafeArea(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0F172A),
                              border: Border(
                                bottom: BorderSide(
                                  color: AppTheme.academicGold,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.royalBlue,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.school,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'BSGD Academy',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        'Coaching Management Suite',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.chevron_left,
                                    color: Colors.white54,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      setState(() => _leftOpen = false),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              children: [
                                _sectionLabelLight('PUBLIC NAVIGATION'),
                                _drawerItem(
                                  Icons.home_outlined,
                                  'Home',
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const HomeScreen(),
                                    ),
                                  ),
                                ),
                                _drawerItem(
                                  Icons.menu_book_outlined,
                                  'Courses & Batches',
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CoursesScreen(),
                                    ),
                                  ),
                                ),
                                _drawerItem(
                                  Icons.videocam_outlined,
                                  'Live Classroom',
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LiveClassScreen(),
                                    ),
                                  ),
                                ),
                                _drawerItem(
                                  Icons.mail_outline,
                                  'Contact & Support',
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ContactScreen(),
                                    ),
                                  ),
                                ),
                                _drawerItem(
                                  Icons.how_to_reg_outlined,
                                  'Online Admission',
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AdmissionScreen(),
                                    ),
                                  ),
                                  highlight: true,
                                ),
                                const Divider(height: 24),
                                _sectionLabelLight('STUDENT PORTALS'),
                                _drawerItem(
                                  Icons.lock_outline,
                                  'Student LMS Portal',
                                  () {},
                                  locked: true,
                                ),
                                _drawerItem(
                                  Icons.quiz_outlined,
                                  'Model Test Exam Center',
                                  () {},
                                ),
                                _drawerItem(
                                  Icons.emoji_events_outlined,
                                  'Results & Merit Board',
                                  () {},
                                ),
                                _drawerItem(
                                  Icons.picture_as_pdf_outlined,
                                  'PDF Lecture Notes',
                                  () {},
                                ),
                                const Divider(height: 24),
                                _sectionLabelLight('TEACHER & ADMIN'),
                                _drawerItem(
                                  Icons.security,
                                  'Teacher Command Hub',
                                  () => setState(
                                    () => _selected = TeacherMenu.dashboard,
                                  ),
                                ),
                                _drawerItem(
                                  Icons.fact_check_outlined,
                                  'Daily Attendance Register',
                                  () => setState(
                                    () => _selected = TeacherMenu.attendance,
                                  ),
                                ),
                                _drawerItem(
                                  Icons.groups_outlined,
                                  'Student Roster',
                                  () => setState(
                                    () => _selected = TeacherMenu.students,
                                  ),
                                ),
                                _drawerItem(
                                  Icons.grading_outlined,
                                  'Exam & Grade Evaluator',
                                  () {},
                                ),
                                const Divider(height: 24),
                                _drawerItem(
                                  Icons.language,
                                  'View Site',
                                  _viewSite,
                                  highlight: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // ========== MAIN CONTENT ==========
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (!_leftOpen)
                        IconButton(
                          tooltip: 'Show general menu',
                          icon: const Icon(Icons.menu),
                          onPressed: () => setState(() => _leftOpen = true),
                        ),
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
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppTheme.royalBlue,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'T',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (!_rightOpen)
                        IconButton(
                          tooltip: 'Show teacher menu',
                          icon: const Icon(Icons.view_sidebar_outlined),
                          onPressed: () => setState(() => _rightOpen = true),
                        ),
                    ],
                  ),
                ),
                Expanded(child: _buildContent()),
              ],
            ),
          ),

          // ========== RIGHT: TEACHER TOOLS ==========
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: _rightOpen ? 220 : 0,
            child: _rightOpen
                ? Container(
                    color: AppTheme.primaryNavy,
                    child: SafeArea(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.admin_panel_settings,
                                  color: AppTheme.academicGold,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Teacher Tools',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.chevron_right,
                                    color: Colors.white54,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      setState(() => _rightOpen = false),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Divider(color: Colors.white24, height: 1),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              children: [
                                _teacherItem(
                                  Icons.dashboard_outlined,
                                  'Dashboard',
                                  TeacherMenu.dashboard,
                                ),
                                _teacherItem(
                                  Icons.note_alt_outlined,
                                  'Notes',
                                  TeacherMenu.notes,
                                ),
                                _teacherItem(
                                  Icons.lightbulb_outline,
                                  'Suggestion',
                                  TeacherMenu.suggestion,
                                ),
                                _teacherItem(
                                  Icons.chat_outlined,
                                  'Message',
                                  TeacherMenu.message,
                                ),
                                _teacherItem(
                                  Icons.groups_outlined,
                                  'Students',
                                  TeacherMenu.students,
                                ),
                                _teacherItem(
                                  Icons.fact_check_outlined,
                                  'Attendance',
                                  TeacherMenu.attendance,
                                ),
                                _teacherItem(
                                  Icons.play_circle_outline,
                                  'Courses',
                                  TeacherMenu.courses,
                                ),
                                _teacherItem(
                                  Icons.live_tv_outlined,
                                  'Live Class',
                                  TeacherMenu.liveClass,
                                ),
                              ],
                            ),
                          ),
                          const Divider(color: Colors.white24, height: 1),
                          ListTile(
                            dense: true,
                            leading: const Icon(
                              Icons.logout,
                              color: Colors.white70,
                              size: 18,
                            ),
                            title: const Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            onTap: _logout,
                          ),
                          const SizedBox(height: 8),
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

  Widget _sectionLabelLight(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: AppTheme.textMuted,
        ),
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool highlight = false,
    bool locked = false,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(
        icon,
        size: 20,
        color: highlight ? AppTheme.academicGold : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
          color: highlight ? AppTheme.academicGold : null,
        ),
      ),
      trailing: locked
          ? const Icon(Icons.lock, size: 14, color: AppTheme.textMuted)
          : null,
      onTap: onTap,
    );
  }

  Widget _teacherItem(IconData icon, String label, TeacherMenu menu) {
    final selected = _selected == menu;
    return InkWell(
      onTap: () => setState(() => _selected = menu),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.royalBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white70,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12.5,
              ),
            ),
          ],
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
      case TeacherMenu.students:
        return 'Students';
      case TeacherMenu.attendance:
        return 'Attendance';
      case TeacherMenu.courses:
        return 'Courses';
      case TeacherMenu.liveClass:
        return 'Live Class';
    }
  }
}
