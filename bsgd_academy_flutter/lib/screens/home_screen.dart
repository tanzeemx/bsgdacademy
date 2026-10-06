import 'courses_screen.dart';
import 'public_suggestion_screen.dart';

import 'package:flutter/material.dart';

import '../widgets/app_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_theme.dart';
import 'live_class_screen.dart';
import 'admission_screen.dart';
import 'exams_screen.dart';
import 'notes_screen.dart';
import 'contact_screen.dart';
import 'results_screen.dart';
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
            _buildAnnouncementBar(),
            _buildHeroSection(context),
            _buildStatsStrip(context),
            _buildUpcomingLiveAlert(context),
            _buildCorePillars(context),
            _buildFeaturedBatches(context),
            _buildInstructorSpotlight(context),
            _buildTestimonialsSection(context),
            _buildFaqSection(context),
            _buildFinalCta(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementBar() {
    return Container(
      color: AppTheme.royalBlue,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: const Row(
        children: [
          Icon(Icons.campaign, color: AppTheme.academicGold, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'HSC 2026 Special Model Test Series Admissions Active! Morning and Day shift batches open.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final titleSize = w < 400 ? 24.0 : (w < 600 ? 28.0 : 34.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
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
          constraints: const BoxConstraints(maxWidth: 950),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.royalBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PREMIER ONLINE COACHING & LMS INFRASTRUCTURE',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.royalBlue,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Smart Digital Coaching for Board Exams & Admissions',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Attend interactive live classes, download chapter-wise notes, take auto-graded MCQ tests with negative marking, and track attendance by Class, Group, and Shift.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  color: AppTheme.textMuted,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 14,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.academicGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdmissionScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.how_to_reg, size: 18),
                    label: const Text(
                      'Student Admission',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.royalBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LiveClassScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.live_tv, size: 18),
                    label: const Text(
                      'Join Live Class',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NoticeScreen()),
                    ),
                    icon: const Icon(Icons.campaign_outlined, size: 18),
                    label: const Text(
                      'Notices',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PublicSuggestionScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.lightbulb_outline, size: 18),
                    label: const Text(
                      'Suggestions',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsStrip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: AppTheme.borderLight.withOpacity(0.6)),
          bottom: BorderSide(color: AppTheme.borderLight.withOpacity(0.6)),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final isWide = constraints.maxWidth > 700;
              return isWide
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          '4,500+',
                          'Enrolled Students',
                          Icons.groups,
                        ),
                        _buildStatItem(
                          '98.4%',
                          'Exam Success Rate',
                          Icons.verified_outlined,
                        ),
                        _buildStatItem(
                          '120+',
                          'Live Classes Held',
                          Icons.broadcast_on_personal,
                        ),
                        _buildStatItem(
                          '85+',
                          'PDF Lecture Handouts',
                          Icons.picture_as_pdf,
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                '4,500+',
                                'Enrolled Students',
                                Icons.groups,
                              ),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                '98.4%',
                                'Exam Success Rate',
                                Icons.verified_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                '120+',
                                'Live Classes Held',
                                Icons.broadcast_on_personal,
                              ),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                '85+',
                                'PDF Lecture Handouts',
                                Icons.picture_as_pdf,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String val, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.royalBlue, size: 26),
          const SizedBox(height: 6),
          Text(
            val,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: AppTheme.royalBlue,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  // FIXED: mobile stacks; no right overflow
  Widget _buildUpcomingLiveAlert(BuildContext context) {
    return Container(
      color: AppTheme.primaryNavy,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: LayoutBuilder(
            builder: (context, c) {
              final narrow = c.maxWidth < 640;

              final textBlock = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentRose,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '● LIVE LECTURE TONIGHT',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'HSC Higher Math: Differential Calculus Master Problem Clinic',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Today at 7:30 PM • Morning & Day Batches • Conducted by Sir Tanzeem',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              );

              final button = ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.academicGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LiveClassScreen()),
                ),
                icon: const Icon(Icons.meeting_room, size: 18),
                label: const Text(
                  'Enter Classroom',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              );

              if (narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textBlock,
                    const SizedBox(height: 16),
                    SizedBox(width: double.infinity, child: button),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: textBlock),
                  const SizedBox(width: 12),
                  button,
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCorePillars(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              const Text(
                'Complete Academic Coaching Ecosystem',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Built specifically for comprehensive board exam preparation and competitive admissions.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              LayoutBuilder(
                builder: (ctx, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  return isWide
                      ? Row(
                          children: [
                            Expanded(
                              child: _buildFeatureCard(
                                Icons.videocam_outlined,
                                'Live Virtual Classes',
                                'Interactive digital whiteboard, real-time live chat Q&A, and lecture recordings.',
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildFeatureCard(
                                Icons.quiz_outlined,
                                'MCQ & Written Tests',
                                'Instant automated scoring, 0.25 negative marking, and handwritten CQ answer script grading.',
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildFeatureCard(
                                Icons.picture_as_pdf_outlined,
                                'PDF Lecture Sheets',
                                'Chapter-wise formula sheets, past board question banks, and concise revision notes.',
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildFeatureCard(
                              Icons.videocam_outlined,
                              'Live Virtual Classes',
                              'Interactive digital whiteboard, real-time live chat Q&A, and lecture recordings.',
                            ),
                            const SizedBox(height: 12),
                            _buildFeatureCard(
                              Icons.quiz_outlined,
                              'MCQ & Written Tests',
                              'Instant automated scoring, 0.25 negative marking, and handwritten CQ answer script grading.',
                            ),
                            const SizedBox(height: 12),
                            _buildFeatureCard(
                              Icons.picture_as_pdf_outlined,
                              'PDF Lecture Sheets',
                              'Chapter-wise formula sheets, past board question banks, and concise revision notes.',
                            ),
                          ],
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String desc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.royalBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.royalBlue, size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              desc,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppTheme.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FIXED: header no longer overflows on mobile
  Widget _buildFeaturedBatches(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (ctx, c) {
                  final narrow = c.maxWidth < 560;
                  final titleBlock = const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Featured Coaching Batches',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Sorted by Class, Group (Science/Commerce/Arts), and Shift.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  );
                  final viewAll = TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CoursesScreen()),
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('View All Batches'),
                  );

                  if (narrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [titleBlock, viewAll],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: titleBlock),
                      viewAll,
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (ctx, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  return isWide
                      ? Row(
                          children: [
                            Expanded(
                              child: _buildBatchCard(
                                context,
                                'HSC Higher Math 1st & 2nd Paper',
                                'Class 12 • Science',
                                'Morning Shift (7:30 AM)',
                                '৳ 3,000 / Mo',
                                AppTheme.royalBlue,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildBatchCard(
                                context,
                                'HSC Physics Complete Mechanics',
                                'Class 12 • Science',
                                'Day Shift (11:00 AM)',
                                '৳ 3,000 / Mo',
                                AppTheme.academicGold,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildBatchCard(
                                context,
                                'SSC Model Test Exam Program',
                                'Class 10 • All Groups',
                                'Morning & Evening',
                                '৳ 2,500 / Full',
                                AppTheme.accentEmerald,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildBatchCard(
                              context,
                              'HSC Higher Math 1st & 2nd Paper',
                              'Class 12 • Science',
                              'Morning Shift (7:30 AM)',
                              '৳ 3,000 / Mo',
                              AppTheme.royalBlue,
                            ),
                            const SizedBox(height: 12),
                            _buildBatchCard(
                              context,
                              'HSC Physics Complete Mechanics',
                              'Class 12 • Science',
                              'Day Shift (11:00 AM)',
                              '৳ 3,000 / Mo',
                              AppTheme.academicGold,
                            ),
                            const SizedBox(height: 12),
                            _buildBatchCard(
                              context,
                              'SSC Model Test Exam Program',
                              'Class 10 • All Groups',
                              'Morning & Evening',
                              '৳ 2,500 / Full',
                              AppTheme.accentEmerald,
                            ),
                          ],
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBatchCard(
    BuildContext context,
    String title,
    String meta,
    String shift,
    String price,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                meta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 10.5,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    shift,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    price,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: color,
                      fontSize: 15,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.academicGold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdmissionScreen()),
                  ),
                  child: const Text(
                    'Enroll',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // FIXED: stacks on mobile
  Widget _buildInstructorSpotlight(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: LayoutBuilder(
                builder: (ctx, c) {
                  final narrow = c.maxWidth < 520;
                  final avatar = const CircleAvatar(
                    radius: 46,
                    backgroundColor: AppTheme.primaryNavy,
                    child: Icon(
                      Icons.school,
                      size: 48,
                      color: AppTheme.academicGold,
                    ),
                  );
                  final info = const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lead Mentor & Academic Director',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.royalBlue,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Prof. A. R. Rahman (Sir Tanzeem)',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'M.Sc. in Pure Mathematics & Theoretical Physics • 15+ Years Board Exam Experience',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '"My teaching philosophy is simple: master the core derivation once, and complex problems will resolve themselves naturally. No shortcut tricks, only crystal-clear logic."',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  );

                  if (narrow) {
                    return Column(
                      children: [avatar, const SizedBox(height: 16), info],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      avatar,
                      const SizedBox(width: 24),
                      Expanded(child: info),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestimonialsSection(BuildContext context) {
    final reviews = [
      {
        'name': 'Tanzeem Ahmed',
        'exam': 'HSC 2026 • Science Morning',
        'score': 'GPA 5.00',
        'comment': 'The live problem-solving clinics and chapter-by-chapter PDF notes completely removed my calculus anxiety.',
      },
      {
        'name': 'Nusrat Jahan',
        'exam': 'HSC 2026 • Science Morning',
        'score': 'GPA 5.00',
        'comment': 'The instant MCQ grading with 0.25 negative marking made real board exam conditions feel familiar and manageable.',
      },
      {
        'name': 'Rahim Chowdhury',
        'exam': 'HSC 2026 • Business Studies',
        'score': 'GPA 4.92',
        'comment': 'The structured shift routine and teacher feedback on written scripts helped me maintain daily discipline.',
      },
    ];

    return Container(
      color: Theme.of(context).cardColor.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              const Text(
                'Student Success Stories',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Verified feedback from students across our Morning, Day, and Evening batches.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (ctx, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  return isWide
                      ? Row(
                          children: reviews
                              .map(
                                (r) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    child: _buildReviewCard(r),
                                  ),
                                ),
                              )
                              .toList(),
                        )
                      : Column(
                          children: reviews
                              .map(
                                (r) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildReviewCard(r),
                                ),
                              )
                              .toList(),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, String> r) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.star, color: AppTheme.academicGold, size: 16),
                Icon(Icons.star, color: AppTheme.academicGold, size: 16),
                Icon(Icons.star, color: AppTheme.academicGold, size: 16),
                Icon(Icons.star, color: AppTheme.academicGold, size: 16),
                Icon(Icons.star, color: AppTheme.academicGold, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '"${r['comment']}"',
              style: const TextStyle(fontSize: 12.5, height: 1.5),
            ),
            const SizedBox(height: 14),
            Text(
              r['name']!,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            Text(
              '${r['exam']} (${r['score']})',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            children: [
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Answers to common inquiries regarding classes, exams, and attendance.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      _buildFaqItem(
                        'What happens if I miss a live lecture?',
                        'All live sessions are automatically processed and archived into your Video Vault in 1080p HD, accessible anytime with attached lecture sheets.',
                      ),
                      const Divider(height: 1),
                      _buildFaqItem(
                        'How does the guardian SMS attendance system work?',
                        'When teachers submit the daily attendance register for a batch, guardians of absent students receive an automated SMS notice within 15 minutes.',
                      ),
                      const Divider(height: 1),
                      _buildFaqItem(
                        'How do I take written (CQ) examinations?',
                        'Students download the PDF question paper at the start of the exam, write answers by hand, capture clear photos or a single PDF, and submit before the countdown timer expires.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(String q, String a) {
    return ExpansionTile(
      title: Text(
        q,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            a,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinalCta(BuildContext context) {
    return Container(
      color: AppTheme.royalBlue,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const Text(
                'Ready to Excel in Your Upcoming Board Exams?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Join thousands of students who have secured top GPA 5.00 results through BSGD Online Academy.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13.5),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.academicGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdmissionScreen()),
                ),
                child: const Text(
                  'Apply for Online Admission Today',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FIXED: copyright no longer overflows
  Widget _buildFooter(BuildContext context) {
    return Container(
      color: AppTheme.primaryNavy,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (ctx, constraints) {
                  final isWide = constraints.maxWidth > 750;
                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _buildFooterBrand()),
                            const SizedBox(width: 30),
                            Expanded(
                              child: _buildFooterCol(
                                'Academic Links',
                                [
                                  'Courses & Batches',
                                  'Live Classroom',
                                  'Model Test Exams',
                                  'Exam Results',
                                  'PDF Notes Library',
                                ],
                                [
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CoursesScreen(),
                                    ),
                                  ),
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LiveClassScreen(),
                                    ),
                                  ),
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ExamsScreen(),
                                    ),
                                  ),
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ResultsScreen(),
                                    ),
                                  ),
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const NotesScreen(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildFooterCol(
                                'Quick Support',
                                [
                                  'Contact & Helpline',
                                  'Online Admission',
                                  'Student Portal',
                                  'Teacher Command',
                                ],
                                [
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ContactScreen(),
                                    ),
                                  ),
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AdmissionScreen(),
                                    ),
                                  ),
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AdmissionScreen(),
                                    ),
                                  ),
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ContactScreen(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(flex: 2, child: _buildFooterContact()),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFooterBrand(),
                            const SizedBox(height: 24),
                            _buildFooterContact(),
                            const SizedBox(height: 24),
                          ],
                        );
                },
              ),
              const Divider(color: Colors.white12, height: 40),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '© 2026 BSGD Online Academy. All rights reserved.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Coaching Management Platform',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.academicGold,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.royalBlue,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'BSGD Online Academy',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'An end-to-end digital coaching platform delivering live classes, recorded lectures, auto-graded MCQ tests, written evaluations, and automated attendance registers.',
          style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildFooterCol(
    String title,
    List<String> links,
    List<VoidCallback> actions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(links.length, (i) {
          return InkWell(
            onTap: actions[i],
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                links[i],
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFooterContact() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Campus & Helpline',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
        SizedBox(height: 12),
        Text(
          '📍 Dhanmondi Academic Center, Dhaka',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        SizedBox(height: 4),
        Text(
          '📞 Helpline: +880 1711-223344',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        SizedBox(height: 4),
        Text(
          '✉️ Email: academy@bsgdigita.com',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        SizedBox(height: 4),
        Text(
          '⏰ Shifts: Morning | Day | Evening',
          style: TextStyle(
            color: AppTheme.academicGold,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

typedef NotesScreen = NoticeScreen;
