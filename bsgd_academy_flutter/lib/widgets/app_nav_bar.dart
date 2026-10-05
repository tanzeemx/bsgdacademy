import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../services/auth_service.dart';

import '../screens/home_screen.dart';
import '../screens/courses_screen.dart';
import '../screens/live_class_screen.dart';
import '../screens/contact_screen.dart';
import '../screens/admission_screen.dart';
import '../screens/student_dashboard_screen.dart';
import '../screens/teacher_dashboard_screen.dart';
import '../screens/login_screen.dart';

class AppNavBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const AppNavBar({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  Size get preferredSize => const Size.fromHeight(65);

  void _navigateToStudent(BuildContext context) {
    final auth = AuthService();
    if (auth.isStudentLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const StudentDashboardScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(
            initialRole: UserRole.student,
            targetScreen: StudentDashboardScreen(),
          ),
        ),
      );
    }
  }

  void _navigateToTeacher(BuildContext context) {
    final auth = AuthService();
    if (auth.isTeacherLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TeacherDashboardScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(
            initialRole: UserRole.teacher,
            targetScreen: TeacherDashboardScreen(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;
    final auth = AuthService();

    return AppBar(
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Open Navigation Drawer',
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: InkWell(
        onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.royalBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'BSGD Online Academy',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (isDesktop) ...[
          _buildNavAction(context, 'Home', const HomeScreen()),
          _buildNavAction(context, 'Courses', const CoursesScreen()),
          _buildNavAction(context, 'Live Class', const LiveClassScreen()),
          _buildNavAction(context, 'Contact', const ContactScreen()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.academicGold,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdmissionScreen()),
              ),
              child: const Text(
                'Admission',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
              ),
            ),
          ),
        ],

        // Theme Toggle
        IconButton(
          tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode_outlined),
          onPressed: onToggleTheme,
        ),

        // Secured User Menu (Requires Password)
        PopupMenuButton<String>(
          tooltip: 'Access Portals',
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.royalBlue.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              (auth.isStudentLoggedIn || auth.isTeacherLoggedIn)
                  ? Icons.verified_user
                  : Icons.lock_outline,
              color: AppTheme.royalBlue,
              size: 20,
            ),
          ),
          onSelected: (value) {
            if (value == 'student') {
              _navigateToStudent(context);
            } else if (value == 'teacher') {
              _navigateToTeacher(context);
            } else if (value == 'logout_student') {
              auth.logoutStudent();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out of Student Portal.')),
              );
            } else if (value == 'logout_teacher') {
              auth.logoutTeacher();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out of Teacher Dashboard.'),
                ),
              );
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: 'student',
              child: Row(
                children: [
                  const Icon(
                    Icons.school_outlined,
                    color: AppTheme.royalBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Student Portal',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        auth.isStudentLoggedIn
                            ? 'Logged in: ${auth.currentUserName}'
                            : 'Password Required',
                        style: TextStyle(
                          fontSize: 11,
                          color: auth.isStudentLoggedIn
                              ? AppTheme.accentEmerald
                              : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (auth.isStudentLoggedIn)
              const PopupMenuItem(
                value: 'logout_student',
                child: Text(
                  '→ Logout Student',
                  style: TextStyle(
                    color: AppTheme.accentRose,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'teacher',
              child: Row(
                children: [
                  const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: AppTheme.accentRose,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Teacher Hub',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        auth.isTeacherLoggedIn
                            ? 'Authenticated: Faculty'
                            : 'Password Required',
                        style: TextStyle(
                          fontSize: 11,
                          color: auth.isTeacherLoggedIn
                              ? AppTheme.accentEmerald
                              : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (auth.isTeacherLoggedIn)
              const PopupMenuItem(
                value: 'logout_teacher',
                child: Text(
                  '→ Logout Teacher',
                  style: TextStyle(
                    color: AppTheme.accentRose,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildNavAction(BuildContext context, String title, Widget screen) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: null,
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      onPressed: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }
}
