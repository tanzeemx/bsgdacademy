import 'package:flutter/material.dart';
import '../widgets/app_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_theme.dart';
import '../main.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    final notes = [
      {'title': 'Calculus Complete Formula & Shortcut Sheet', 'class': 'Class 12', 'pages': '32 Pages', 'size': '3.4 MB'},
      {'title': 'Newtonian Mechanics Vector Derivation Bank', 'class': 'Class 11', 'pages': '48 Pages', 'size': '5.1 MB'},
      {'title': 'Organic Chemistry Reactions Summary Handout', 'class': 'Class 12', 'pages': '24 Pages', 'size': '2.8 MB'},
    ];

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
                const Text('PDF Lecture Notes & Handouts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('Chapter-wise study notes, formula compendiums, and model questions.', style: TextStyle(color: AppTheme.textMuted)),
                const SizedBox(height: 20),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: notes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final n = notes[i];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.picture_as_pdf, color: AppTheme.accentRose, size: 30),
                        title: Text(n['title']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: Text('${n['class']} • ${n['pages']} • ${n['size']}', style: const TextStyle(fontSize: 12)),
                        trailing: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.royalBlue, foregroundColor: Colors.white),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Downloading: ${n['title']}')),
                            );
                          },
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text('PDF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
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