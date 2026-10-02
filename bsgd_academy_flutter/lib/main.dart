import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const BsgdOnlineAcademyApp());
}

class BsgdOnlineAcademyApp extends StatefulWidget {
  const BsgdOnlineAcademyApp({super.key});

  @override
  State<BsgdOnlineAcademyApp> createState() => _BsgdOnlineAcademyAppState();
}

class _BsgdOnlineAcademyAppState extends State<BsgdOnlineAcademyApp> {
  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      isDarkMode: _isDarkMode,
      toggleTheme: toggleTheme,
      child: MaterialApp(
        title: 'BSGD Online Academy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: const HomeScreen(),
      ),
    );
  }
}

class AppStateScope extends InheritedWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const AppStateScope({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
    required super.child,
  });

  static AppStateScope of(BuildContext context) {
    final AppStateScope? result = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(result != null, 'No AppStateScope found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppStateScope oldWidget) => isDarkMode != oldWidget.isDarkMode;
}