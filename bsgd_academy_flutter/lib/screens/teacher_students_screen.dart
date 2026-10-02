import 'package:flutter/material.dart';
import '../widgets/app_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_theme.dart';
import '../main.dart';

class TeacherStudentsScreen extends StatelessWidget {
  const TeacherStudentsScreen({super.key});

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
                const Text('Student Roster Directory', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('View students filtered by Class, Group, and Shift.', style: TextStyle(color: AppTheme.textMuted)),
                const SizedBox(height: 20),
                Card(
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      ListTile(
                        leading: CircleAvatar(child: Text('1001')),
                        title: Text('Tanzeem Ahmed', style: TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('Class 12 • Science (Morning Shift) • Guardian: 01711-223344'),
                        trailing: Text('94.2% Att.', style: TextStyle(color: AppTheme.accentEmerald, fontWeight: FontWeight.w700)),
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: CircleAvatar(child: Text('1002')),
                        title: Text('Nusrat Jahan', style: TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('Class 12 • Science (Morning Shift) • Guardian: 01822-334455'),
                        trailing: Text('98.0% Att.', style: TextStyle(color: AppTheme.accentEmerald, fontWeight: FontWeight.w700)),
                      ),
                    ],
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