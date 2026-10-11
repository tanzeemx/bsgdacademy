import 'package:flutter/material.dart';
import '../widgets/app_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_theme.dart';
import 'mcq_exam_screen.dart';
import 'written_exam_screen.dart';
import '../main.dart';

class ExamsScreen extends StatelessWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppNavBar(onToggleTheme: appState.toggleTheme, isDark: appState.isDarkMode),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Examination Center', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('Take auto-graded MCQ tests with negative marking or submit handwritten CQ written papers.', style: TextStyle(color: AppTheme.textMuted)),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppTheme.accentEmerald.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                              child: const Text('LIVE MCQ EXAM', style: TextStyle(color: AppTheme.accentEmerald, fontWeight: FontWeight.w800, fontSize: 11)),
                            ),
                            const Spacer(),
                            const Text('Duration: 15 Mins', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text('HSC Higher Math 1st Paper - Calculus Special Model Test', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 6),
                        const Text('4 Questions • Negative Marking: 0.25 • Instant score calculation & answer key.', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.academicGold,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const McqExamScreen())),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Start MCQ Test Now', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppTheme.royalBlue.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                              child: const Text('WRITTEN EXAM', style: TextStyle(color: AppTheme.royalBlue, fontWeight: FontWeight.w800, fontSize: 11)),
                            ),
                            const Spacer(),
                            const Text('Duration: 45 Mins', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text('Physics 1st Paper - Newtonian Mechanics Written Test', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 6),
                        const Text('Total Marks: 30 • Download Question Paper & upload answer sheet photo.', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.royalBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WrittenExamScreen())),
                          icon: const Icon(Icons.upload_file, size: 16),
                          label: const Text('Enter Written Test', style: TextStyle(fontWeight: FontWeight.w800)),
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
}