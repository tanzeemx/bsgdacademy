import 'package:flutter/material.dart';
import '../../core/data/demo_data.dart';
import '../../core/theme/app_colors.dart';

class ClassCard extends StatelessWidget {
  const ClassCard(this.item, {super.key});
  final StudyClass item;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.09),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.video_camera_front, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.text)),
                      ),
                      if (item.live)
                        const Text('LIVE', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.w900))
                    ],
                  ),
                  Text('${item.subject} •${item.teacher}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  Text(item.time, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted)
          ],
        ),
      );
}
