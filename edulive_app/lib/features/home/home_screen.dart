import 'package:flutter/material.dart';
import '../../core/data/demo_data.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/class_card.dart';
import '../../shared/widgets/lesson_card.dart';
import '../../shared/widgets/section_title.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 25),
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFEAF1FF),
                child: Icon(Icons.school, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BSGD Online Academy', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                    Text('Welcome back 👋', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w900, fontSize: 19)),
                  ],
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF3978F6), Color(0xFF6259D9)]),
              borderRadius: BorderRadius.circular(23),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('BSGD ACADEMY PORTAL', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const SizedBox(height: 12),
                const Text('Empowering\nYour Education.', style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900, height: 1.15)),
                const SizedBox(height: 8),
                const Text('Join live classes, watch uploaded lessons, and review suggestions from teachers.', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 15),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: const Text('Explore classes', style: TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white54)),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle('Your learning overview'),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(child: _Metric(Icons.menu_book, '12', 'Lessons', AppColors.primary)),
              SizedBox(width: 9),
              Expanded(child: _Metric(Icons.schedule, '4.5h', 'Study time', AppColors.teal)),
              SizedBox(width: 9),
              Expanded(child: _Metric(Icons.local_fire_department, '5 days', 'Streak', AppColors.orange)),
            ],
          ),
          const SizedBox(height: 24),
          const SectionTitle('Upcoming live classes', action: 'See all'),
          const SizedBox(height: 10),
          ...classes.take(2).map((e) => ClassCard(e)),
          const SizedBox(height: 15),
          const SectionTitle('Continue learning', action: 'View all'),
          const SizedBox(height: 10),
          SizedBox(
            height: 205,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: lessons.map((e) => Padding(padding: const EdgeInsets.only(right: 10), child: LessonCard(e))).toList(),
            ),
          ),
        ],
      );
}

class _Metric extends StatelessWidget {
  const _Metric(this.icon, this.value, this.label, this.color);
  final IconData icon;
  final String value, label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
          ],
        ),
      );
}
