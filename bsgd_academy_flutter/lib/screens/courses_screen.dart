import 'package:flutter/material.dart';
import '../widgets/app_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_theme.dart';
import 'admission_screen.dart';
import '../main.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    final courses = [
      {'title': 'HSC Higher Math 1st & 2nd Paper', 'class': 'Class 12', 'group': 'Science', 'fee': '৳ 3,000 / Mo'},
      {'title': 'Physics Mechanics & Electromagnetism', 'class': 'Class 12', 'group': 'Science', 'fee': '৳ 3,000 / Mo'},
      {'title': 'SSC Special Model Test Series', 'class': 'Class 10', 'group': 'All Groups', 'fee': '৳ 2,500 / Full'},
      {'title': 'University Engineering Admission Care', 'class': 'Admission', 'group': 'Science', 'fee': '৳ 8,500 / Full'},
    ];

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppNavBar(onToggleTheme: appState.toggleTheme, isDark: appState.isDarkMode),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Academic Batches & Courses', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('Enroll in academic batches organized by Class, Group, and Shift.', style: TextStyle(color: AppTheme.textMuted)),
                const SizedBox(height: 24),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: courses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final c = courses[i];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.royalBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.menu_book, color: AppTheme.royalBlue),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c['title']!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Text('${c['class']} • Group: ${c['group']}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(c['fee']!, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.royalBlue, fontSize: 14)),
                                const SizedBox(height: 6),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.academicGold,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdmissionScreen())),
                                  child: const Text('Enroll', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}