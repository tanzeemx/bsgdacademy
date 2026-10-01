import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Profile', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: AppColors.text)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: Color(0xFFEAF1FF),
                  child: Icon(Icons.person, size: 38, color: AppColors.primary),
                ),
                SizedBox(height: 10),
                Text('BSGD Member', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.text)),
                Text('student@bsgd.com', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                SizedBox(height: 12),
                Chip(label: Text('ACTIVE SESSION')),
              ],
            ),
          ),
          const SizedBox(height: 15),
          const _Item(Icons.person_outline, 'Personal Information'),
          const _Item(Icons.school_outlined, 'Enrolled Courses'),
          const _Item(Icons.notifications_none, 'Notification Settings'),
          const _Item(Icons.language, 'Language Preferences'),
          const _Item(Icons.help_outline, 'Help & Support'),
          const _Item(Icons.settings_outlined, 'Account Settings'),
        ],
      );
}

class _Item extends StatelessWidget {
  const _Item(this.icon, this.title);
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, color: AppColors.navy, size: 20),
        ),
        title: Text(title, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
      );
}
