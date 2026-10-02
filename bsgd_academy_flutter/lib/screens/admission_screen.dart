import 'package:flutter/material.dart';
import '../widgets/app_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_theme.dart';
import 'student_dashboard_screen.dart';
import '../main.dart';

class AdmissionScreen extends StatefulWidget {
  const AdmissionScreen({super.key});

  @override
  State<AdmissionScreen> createState() => _AdmissionScreenState();
}

class _AdmissionScreenState extends State<AdmissionScreen> {
  String _selectedClass = 'Class 12';
  String _selectedGroup = 'Science';
  String _selectedShift = 'Morning';

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppNavBar(onToggleTheme: appState.toggleTheme, isDark: appState.isDarkMode),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.academicGold.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                      child: const Text('ADMISSIONS ACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.academicGold)),
                    ),
                    const SizedBox(height: 10),
                    const Text('Student Admission Form', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    const Text('Register your academic profile to enter scheduled batches.', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                    const SizedBox(height: 20),
                    const TextField(decoration: InputDecoration(labelText: 'Full Student Name *', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedClass,
                      decoration: const InputDecoration(labelText: 'Academic Class *', border: OutlineInputBorder()),
                      items: ['Class 9', 'Class 10', 'Class 11', 'Class 12', 'Admission Unit']
                          .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedClass = val!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedGroup,
                      decoration: const InputDecoration(labelText: 'Academic Group *', border: OutlineInputBorder()),
                      items: ['Science', 'Commerce / Business Studies', 'Humanities / Arts']
                          .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedGroup = val!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedShift,
                      decoration: const InputDecoration(labelText: 'Batch Shift *', border: OutlineInputBorder()),
                      items: ['Morning', 'Day', 'Evening']
                          .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedShift = val!),
                    ),
                    const SizedBox(height: 12),
                    const TextField(decoration: InputDecoration(labelText: 'Student Mobile Phone *', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    const TextField(decoration: InputDecoration(labelText: 'Guardian Mobile Phone *', border: OutlineInputBorder())),
                    const SizedBox(height: 22),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.academicGold,
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Admission registered successfully! Welcome to BSGD Academy.')),
                        );
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StudentDashboardScreen()));
                      },
                      child: const Text('Complete Registration & Enter LMS', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}