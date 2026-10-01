import 'package:flutter/material.dart';
import '../../core/data/demo_data.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/lesson_card.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Video Lessons', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: AppColors.text)),
          const Text('BSGD Online Academy recorded video repository.', style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 18),
          const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search subjects or topics...')),
          const SizedBox(height: 18),
          Wrap(
            spacing: 7,
            children: ['All', 'Mathematics', 'Physics', 'English']
                .map((s) => Chip(
                      label: Text(s),
                      backgroundColor: s == 'All' ? AppColors.primary : Colors.white,
                      labelStyle: TextStyle(color: s == 'All' ? Colors.white : AppColors.muted),
                    ))
                .toList(),
          ),
          const SizedBox(height: 15),
          ...lessons.map((e) => Padding(padding: const EdgeInsets.only(bottom: 12), child: SizedBox(height: 205, child: LessonCard(e)))),
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Upload feature ready for storage integration.')),
            ),
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Upload Video Lesson (Teacher)'),
          )
        ],
      );
}
