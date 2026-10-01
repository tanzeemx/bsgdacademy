import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SuggestionsScreen extends StatelessWidget {
  const SuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Study Suggestions', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: AppColors.text)),
          const Text('Uploaded notes, formulas, and teacher recommendations.', style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 18),
          const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search suggestions and PDFs...')),
          const SizedBox(height: 16),
          const _Suggestion(Icons.description_outlined, 'MATHEMATICS', 'Trigonometry Formula Sheet', 'Quick revision sheet for sine, cosine and tangent.', 'Updated today', Color(0xFFEAF1FF)),
          const _Suggestion(Icons.assignment_outlined, 'PHYSICS', 'Chapter 3 Practice Questions', 'Practice problem set with hint answers.', '2 days ago', Color(0xFFE4F7F2)),
          const _Suggestion(Icons.lightbulb_outline, 'ENGLISH', 'Essay Structure Guidelines', 'Writing formats for exams and assignments.', 'This week', Color(0xFFFFF0E2)),
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Redirecting to document uploader...')),
            ),
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Suggestion / Material'),
          )
        ],
      );
}

class _Suggestion extends StatelessWidget {
  const _Suggestion(this.icon, this.subject, this.title, this.detail, this.date, this.color);
  final IconData icon;
  final String subject, title, detail, date;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(13)),
              child: Icon(icon, color: AppColors.navy),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subject, style: const TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(title, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w900)),
                  Text(detail, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  const SizedBox(height: 5),
                  Text(date, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
                ],
              ),
            )
          ],
        ),
      );
}
