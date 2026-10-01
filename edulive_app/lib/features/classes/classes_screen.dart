import 'package:flutter/material.dart';
import '../../core/data/demo_data.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/class_card.dart';
import '../../shared/widgets/section_title.dart';

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Live Classes', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: AppColors.text)),
          const Text('BSGD Online Academy scheduled classrooms.', style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFEAF1FF), borderRadius: BorderRadius.circular(17)),
            child: const Text('Join early and have your notebook ready for interactive Q&A.', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 22),
          const SectionTitle('Scheduled for you'),
          const SizedBox(height: 10),
          ...classes.map((e) => ClassCard(e)),
          FilledButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Connecting to streaming server...')),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Schedule a Live Session'),
          )
        ],
      );
}
