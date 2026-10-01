import 'package:flutter/material.dart';
import '../../core/data/demo_data.dart';
import '../../core/theme/app_colors.dart';

class LessonCard extends StatelessWidget {
  const LessonCard(this.lesson, {super.key});
  final Lesson lesson;

  @override
  Widget build(BuildContext context) => Container(
        width: 190,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1FF),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(child: Text(lesson.emoji, style: const TextStyle(fontSize: 40))),
            ),
            const SizedBox(height: 10),
            Text(lesson.subject.toUpperCase(), style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900)),
            Text(lesson.title, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w800)),
            const Spacer(),
            Text('▶  ${lesson.duration}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
          ],
        ),
      );
}
