import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'features/home/home_screen.dart';
import 'features/classes/classes_screen.dart';
import 'features/lessons/lessons_screen.dart';
import 'features/suggestions/suggestions_screen.dart';
import 'features/profile/profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  final pages = const [
    HomeScreen(),
    ClassesScreen(),
    LessonsScreen(),
    SuggestionsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: index, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.video_camera_front_outlined), label: 'Classes'),
          NavigationDestination(icon: Icon(Icons.play_circle_outline), label: 'Lessons'),
          NavigationDestination(icon: Icon(Icons.lightbulb_outline), label: 'Suggestions'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
      floatingActionButton: index == 0
          ? FloatingActionButton.extended(
              onPressed: () => showModalBottomSheet(
                context: context,
                showDragHandle: true,
                builder: (_) => SafeArea(
                  child: Wrap(
                    children: [
                      const ListTile(
                        title: Text('BSGD Content Generator', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      ListTile(
                        leading: const Icon(Icons.video_call),
                        title: const Text('Schedule Live Class'),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => index = 1);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.video_library),
                        title: const Text('Add Video Lesson'),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => index = 2);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.upload_file),
                        title: const Text('Upload Suggestion'),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => index = 3);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Create'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }
}
