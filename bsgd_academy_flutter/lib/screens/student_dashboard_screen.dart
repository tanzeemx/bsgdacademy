import 'package:flutter/material.dart';

import '../widgets/app_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_theme.dart';
import 'live_class_screen.dart';
import 'exams_screen.dart';
import 'notes_screen.dart';
import 'results_screen.dart';
import '../main.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

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
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Student Identity & Batch Banner
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryNavy, AppTheme.royalBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxTheme.softShadow],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.academicGold,
                        child: Text(
                          'TA',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tanzeem Ahmed',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Roll: #1001 • Class 12 Science (Morning Shift)',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.academicGold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
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
                        icon: const Icon(Icons.live_tv, size: 16),
                        label: const Text(
                          'Enter Live Room',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Academic Performance KPI Grid
                LayoutBuilder(
                  builder: (ctx, constraints) {
                    final bool isWide = constraints.maxWidth > 700;
                    return GridView.count(
                      crossAxisCount: isWide ? 4 : 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: isWide ? 1.6 : 1.3,
                      children: [
                        _buildMetricCard(
                          label: 'Attendance',
                          value: '94.2%',
                          sub: '28 Days Streak',
                          icon: Icons.check_circle_outline,
                          color: AppTheme.accentEmerald,
                        ),
                        _buildMetricCard(
                          label: 'Merit Rank',
                          value: '4th / 142',
                          sub: 'Top 3% in Batch',
                          icon: Icons.emoji_events_outlined,
                          color: AppTheme.royalBlue,
                        ),
                        _buildMetricCard(
                          label: 'GPA Standing',
                          value: '5.00 (A+)',
                          sub: 'Avg Score: 88.5%',
                          icon: Icons.star_border,
                          color: AppTheme.academicGold,
                        ),
                        _buildMetricCard(
                          label: 'Tuition Fee',
                          value: '৳ 0.00 Due',
                          sub: 'October Cleared',
                          icon: Icons.receipt_outlined,
                          color: AppTheme.accentEmerald,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),

                // 3. Subject-wise Syllabus Progress
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Subject Syllabus Progression',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotesScreen(),
                                ),
                              ),
                              icon: const Icon(Icons.download, size: 16),
                              label: const Text('Lecture Notes'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildProgressRow(
                          'Higher Mathematics',
                          0.82,
                          AppTheme.royalBlue,
                          '18/22 Ch.',
                        ),
                        const SizedBox(height: 14),
                        _buildProgressRow(
                          'Physics (1st & 2nd Paper)',
                          0.74,
                          AppTheme.accentEmerald,
                          '15/20 Ch.',
                        ),
                        const SizedBox(height: 14),
                        _buildProgressRow(
                          'Chemistry',
                          0.68,
                          AppTheme.academicGold,
                          '14/20 Ch.',
                        ),
                        const SizedBox(height: 14),
                        _buildProgressRow(
                          'ICT',
                          0.90,
                          const Color(0xFF8B5CF6),
                          '6/6 Ch.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Quick Actions Bar
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.royalBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ExamsScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.edit_note),
                        label: const Text(
                          'Take Model Test',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ResultsScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.emoji_events),
                        label: const Text(
                          'View Merit Standings',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required String sub,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(
    String subject,
    double pct,
    Color color,
    String chapters,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              subject,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            Text(
              '$chapters (${(pct * 100).toInt()}%)',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: pct,
          backgroundColor: AppTheme.borderLight,
          color: color,
          minHeight: 7,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

class BoxTheme {
  static BoxShadow softShadow = BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 16,
    offset: const Offset(0, 4),
  );
}

typedef NotesScreen = NoticeScreen;
