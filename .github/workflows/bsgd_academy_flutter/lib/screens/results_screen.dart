import 'package:flutter/material.dart';
import '../widgets/app_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_theme.dart';
import '../main.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

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
            constraints: const BoxConstraints(maxWidth: 850),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Exam Results & Merit Standings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('Instant automated scores and teacher-evaluated written grades.', style: TextStyle(color: AppTheme.textMuted)),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildResultRow('HSC Higher Math 1st Paper - Calculus Special', '18.75 / 20.00', 'Rank #1 (93.7%)', AppTheme.accentEmerald),
                        const Divider(height: 24),
                        _buildResultRow('Physics 1st Paper - Newtonian Mechanics', '26.00 / 30.00', 'Graded by Sir', AppTheme.royalBlue),
                        const Divider(height: 24),
                        _buildResultRow('Organic Chemistry Mechanism Test', '22.50 / 25.00', 'Rank #3 (90.0%)', AppTheme.accentEmerald),
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

  Widget _buildResultRow(String title, String score, String badge, Color color) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              const SizedBox(height: 4),
              Text('Score: $score', style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
          child: Text(badge, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11)),
        ),
      ],
    );
  }
}