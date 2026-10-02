import 'package:flutter/material.dart';

import '../widgets/app_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_theme.dart';
import 'teacher_attendance_screen.dart';
import 'teacher_students_screen.dart';
import 'teacher_exams_screen.dart';
import 'live_class_screen.dart';
import '../main.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppNavBar(
        onToggleTheme: appState.toggleTheme,
        isDark: appState.isDarkMode,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Bar with Primary Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Faculty Command Center',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Manage enrolled cohorts, attendance sheets, and examinations.',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentRose,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LiveClassScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.broadcast_on_home, size: 16),
                      label: const Text(
                        'Launch Studio',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Faculty KPI Metrics Grid
                LayoutBuilder(
                  builder: (ctx, constraints) {
                    final isWide = constraints.maxWidth > 700;
                    return GridView.count(
                      crossAxisCount: isWide ? 4 : 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: isWide ? 1.5 : 1.3,
                      children: [
                        _buildKpiCard(
                          'Total Students',
                          '428',
                          '6 Active Batches',
                          Icons.groups,
                          AppTheme.royalBlue,
                        ),
                        _buildKpiCard(
                          'Today Attendance',
                          '92.4%',
                          '395 Present',
                          Icons.how_to_reg,
                          AppTheme.accentEmerald,
                        ),
                        _buildKpiCard(
                          'Tuition Collected',
                          '৳ 3,45,000',
                          '94% Invoices Paid',
                          Icons.payments,
                          AppTheme.academicGold,
                        ),
                        _buildKpiCard(
                          'Pending Written',
                          '14 Papers',
                          'Requires Grading',
                          Icons.edit_note,
                          AppTheme.accentRose,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),

                // Active Batches Cards
                const Text(
                  'Active Batches by Shift',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildBatchTile(
                      context: context,
                      title: 'HSC Higher Math & Physics (Class 12)',
                      subtitle: 'Science • Morning Shift (7:30 AM – 10:30 AM)',
                      studentsCount: '142 Students',
                      color: AppTheme.royalBlue,
                    ),
                    const SizedBox(height: 12),
                    _buildBatchTile(
                      context: context,
                      title: 'SSC Core Preparation (Class 10)',
                      subtitle: 'All Groups • Day Shift (11:00 AM – 2:00 PM)',
                      studentsCount: '164 Students',
                      color: AppTheme.academicGold,
                    ),
                    const SizedBox(height: 12),
                    _buildBatchTile(
                      context: context,
                      title: 'University Engineering Admission Care',
                      subtitle:
                          'Science Unit • Evening Shift (5:30 PM – 8:30 PM)',
                      studentsCount: '122 Students',
                      color: AppTheme.accentEmerald,
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Quick Management Tools
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Administrative Shortcuts',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const TeacherAttendanceScreen(),
                                ),
                              ),
                              icon: const Icon(Icons.fact_check),
                              label: const Text('Take Attendance Register'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TeacherStudentsScreen(),
                                ),
                              ),
                              icon: const Icon(Icons.person_search),
                              label: const Text(
                                'Student Roster (Class/Group/Shift)',
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TeacherExamsScreen(),
                                ),
                              ),
                              icon: const Icon(Icons.grading),
                              label: const Text('Grade Written Scripts'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard(
    String label,
    String val,
    String sub,
    IconData icon,
    Color color,
  ) {
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
              val,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
            ),
            Text(
              sub,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String studentsCount,
    required Color color,
  }) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: ListTile(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                studentsCount,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.royalBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TeacherAttendanceScreen(),
                  ),
                ),
                child: const Text(
                  'Attendance',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
