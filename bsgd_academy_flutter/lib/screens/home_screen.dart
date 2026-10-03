import 'package:flutter/material.dart';

import '../widgets/app_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_theme.dart';
import 'courses_screen.dart';
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
            // 1. Top Emergency Notice Ticker
            _buildAnnouncementBar(),

            // 2. Hero Section
            _buildHeroSection(context),

            // 3. Stats & Trust Metrics Strip
            _buildStatsStrip(context),

            // 4. Live Broadcast Tonight Alert
            _buildUpcomingLiveAlert(context),

            // 5. Core Academy Capabilities
            _buildCorePillars(context),

            // 6. Featured Batches by Class & Shift
            _buildFeaturedBatches(context),

            // 7. Lead Instructor Spotlight
            _buildInstructorSpotlight(context),

            // 8. Student Success Stories & Testimonials
            _buildTestimonialsSection(context),

            // 9. Quick FAQ Accordion Preview
            _buildFaqSection(context),

            // 10. Start Learning Final CTA Banner
            _buildFinalCta(context),

            // 11. Full Educational Footer
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // 1. Top Announcement Bar
  Widget _buildAnnouncementBar() {
    return Container(
      color: AppTheme.royalBlue,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.campaign, color: AppTheme.academicGold, size: 18),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'HSC 2026 Special Model Test Series Admissions Active! Morning and Day shift batches open.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 2. Hero Intro Section
  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
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
                  horizontal: 14,
                  vertical: 6,
                ),
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
                      'PREMIER ONLINE COACHING & LMS INFRASTRUCTURE',
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
                  fontSize: 34,
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
                      MaterialPageRoute(builder: (_) => const ExamsScreen()),
                    ),
                    icon: const Icon(Icons.edit_note, size: 18),
                    label: const Text(
                      'Take Model Test',
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

  // 3. Stats Strip
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
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
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
    return Column(
      children: [
        Icon(icon, color: AppTheme.royalBlue, size: 26),
        const SizedBox(height: 6),
        Text(
          val,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: AppTheme.royalBlue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  // 4. Upcoming Live Alert
  Widget _buildUpcomingLiveAlert(BuildContext context) {
    return Container(
      color: AppTheme.primaryNavy,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
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
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 8),
                          SizedBox(width: 6),
                          Text(
                            'LIVE LECTURE TONIGHT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'HSC Higher Math: Differential Calculus Master Problem Clinic',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Today at 7:30 PM • Morning & Day Batches • Conducted by Sir Tanzeem',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.academicGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 5. Core Pillars
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

  // 6. Featured Batches
  Widget _buildFeaturedBatches(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Featured Coaching Batches',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Sorted by Class, Group (Science/Commerce/Arts), and Shift.',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CoursesScreen()),
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('View All Batches'),
                  ),
                ],
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
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(
                  shift,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: color,
                    fontSize: 15,
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

  // 7. Lead Instructor Spotlight
  Widget _buildInstructorSpotlight(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 46,
                    backgroundColor: AppTheme.primaryNavy,
                    child: Icon(
                      Icons.school,
                      size: 48,
                      color: AppTheme.academicGold,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lead Mentor & Academic Director',
                          style: TextStyle(
                            color: AppTheme.royalBlue,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Prof. A. R. Rahman (Sir Tanzeem)',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'M.Sc. in Pure Mathematics & Theoretical Physics • 15+ Years Board Exam Experience',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '"My teaching philosophy is simple: master the core derivation once, and complex problems will resolve themselves naturally. No shortcut tricks, only crystal-clear logic."',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 8. Testimonials Section
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
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
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
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  // 9. FAQ Section
  Widget _buildFaqSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
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

  // 10. Final CTA Banner
  Widget _buildFinalCta(BuildContext context) {
    return Container(
      color: AppTheme.royalBlue,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
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
                  fontSize: 24,
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

  // 11. Multi-Column Educational Footer
  Widget _buildFooter(BuildContext context) {
    return Container(
      color: AppTheme.primaryNavy,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    '© 2026 BSGD Online Academy. All rights reserved.',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  Text(
                    'Coaching Management Platform',
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
            const Text(
              'BSGD Online Academy',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
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
