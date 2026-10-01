import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app.dart';

void main() => runApp(const BSGDOnlineAcademyApp());

class BSGDOnlineAcademyApp extends StatelessWidget {
  const BSGDOnlineAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BSGD Online Academy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3978F6)),
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        textTheme: GoogleFonts.nunitoTextTheme(),
      ),
      home: const AppShell(),
    );
  }
}
