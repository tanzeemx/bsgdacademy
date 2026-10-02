import 'package:flutter/material.dart';
import '../widgets/app_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_theme.dart';
import '../main.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

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
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Contact & Coaching Helpline', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    const Text('Have inquiries regarding batches, timings, or technical assistance?', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                    const SizedBox(height: 20),
                    const ListTile(
                      dense: true,
                      leading: Icon(Icons.phone, color: AppTheme.royalBlue),
                      title: Text('+880 1711-223344', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('Morning & Evening Support Shifts'),
                    ),
                    const ListTile(
                      dense: true,
                      leading: Icon(Icons.email, color: AppTheme.royalBlue),
                      title: Text('academy@bsgdigita.com', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('Official Academic Inquiries'),
                    ),
                    const Divider(height: 30),
                    const Text('Send Us a Message', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    const TextField(decoration: InputDecoration(labelText: 'Student / Guardian Name', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    const TextField(decoration: InputDecoration(labelText: 'Contact Phone Number', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    const TextField(maxLines: 3, decoration: InputDecoration(labelText: 'Your Inquiry Details', border: OutlineInputBorder())),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.royalBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Inquiry dispatched to BSGD Academy academic coordinator.')),
                        );
                      },
                      child: const Text('Submit Message', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}