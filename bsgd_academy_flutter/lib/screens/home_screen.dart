import 'package:flutter/material.dart';
import '../widgets/app_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_theme.dart';
import 'courses_screen.dart';
import 'live_class_screen.dart';
import 'admission_screen.dart';
import 'exams_screen.dart';
import '../main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppNavBar(
        onToggleTheme: appState.toggleTheme,
        isDark: appState.isDarkMode,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Live Announcement Ticker
            Container(
              color: AppTheme.royalBlue,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign, color: AppTheme.academicGold, size: 18),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'HSC 2026 Special Model Test Series Admissions Active! Morning and Day shift batches open.',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Hero Intro Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryNavy.withOpacity(0.04),
                    AppTheme.royalBlue.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.royalBlue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, size: 14, color: AppTheme.royalBlue),
                            SizedBox(width: 6),
                            Text(
                              'PREMIER COACHING & LMS INFRASTRUCTURE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.royalBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Smart Digital Coaching for Board Exams & Admissions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Attend live interactive classes, download chapter-wise lecture sheets, give auto-graded MCQ tests, and track attendance by Class, Group, and Shift.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textMuted,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.academicGold,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdmissionScreen())),
                            icon: const Icon(Icons.how_to_reg, size: 18),
                            label: const Text('Student Admission', style: TextStyle(fontWeight: FontWeight.w800)),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.royalBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveClassScreen())),
                            icon: const Icon(Icons.live_tv, size: 18),
                            label: const Text('Join Live Class', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamsScreen())),
                            icon: const Icon(Icons.edit_note, size: 18),
                            label: const Text('Take Model Test', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Academy Pillars
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    children: [
                      const Text(
                        'Core Academy Capabilities',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (ctx, constraints) {
                          final isWide = constraints.maxWidth > 700;
                          return isWide
                              ? Row(
                                  children: [
                                    Expanded(child: _buildFeatureCard(Icons.videocam, 'Live Classroom', 'Attend high-definition broadcasts with live teacher whiteboard and Q&A.')),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildFeatureCard(Icons.quiz, 'Instant MCQ Exams', 'Timed testing with instant score calculation, negative marks, and answer review.')),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildFeatureCard(Icons.picture_as_pdf, 'PDF Lecture Notes', 'Complete chapter formula cards, question banks, and handouts.')),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _buildFeatureCard(Icons.videocam, 'Live Classroom', 'Attend high-definition broadcasts with live teacher whiteboard and Q&A.'),
                                    const SizedBox(height: 12),
                                    _buildFeatureCard(Icons.quiz, 'Instant MCQ Exams', 'Timed testing with instant score calculation, negative marks, and answer review.'),
                                    const SizedBox(height: 12),
                                    _buildFeatureCard(Icons.picture_as_pdf, 'PDF Lecture Notes', 'Complete chapter formula cards, question banks, and handouts.'),
                                  ],
                                );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String desc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.royalBlue, size: 28),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 6),
            Text(desc, style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted, height: 1.5)),
          ],
        ),
      ),
    );
  }
}