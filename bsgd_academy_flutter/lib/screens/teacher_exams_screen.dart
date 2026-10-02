import 'package:flutter/material.dart';
import '../widgets/app_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_theme.dart';
import '../main.dart';

class TeacherExamsScreen extends StatelessWidget {
  const TeacherExamsScreen({super.key});

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
                const Text('Exam & Written Script Evaluator', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('Inspect student submissions and assign marks.', style: TextStyle(color: AppTheme.textMuted)),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pending Written Script for Grading', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const Divider(height: 20),
                        ListTile(
                          title: const Text('Nusrat Jahan (Roll 1002)', style: TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: const Text('Physics 1st Paper - Newtonian Mechanics • 3 Pages PDF'),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.academicGold, foregroundColor: Colors.black),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Grade Written Script'),
                                  content: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(decoration: InputDecoration(labelText: 'Award Marks (Out of 30)')),
                                      SizedBox(height: 10),
                                      TextField(maxLines: 2, decoration: InputDecoration(labelText: 'Teacher Feedback')),
                                    ],
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Grade released to student.')),
                                        );
                                      },
                                      child: const Text('Publish Grade'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text('Grade Paper', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                          ),
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