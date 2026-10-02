import 'package:flutter/material.dart';

import '../widgets/app_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../main.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  String _filterClass = '12';
  String _filterGroup = 'Science';
  String _filterShift = 'Morning';

  final List<Student> _students = [
    Student(
      roll: '1001',
      name: 'Tanzeem Ahmed',
      studentClass: '12',
      group: 'Science',
      shift: 'Morning',
      phone: '01711-223344',
      status: 'Active',
      attendance: 94.2,
    ),
    Student(
      roll: '1002',
      name: 'Nusrat Jahan',
      studentClass: '12',
      group: 'Science',
      shift: 'Morning',
      phone: '01822-334455',
      status: 'Active',
      attendance: 98.0,
    ),
    Student(
      roll: '1003',
      name: 'Rahim Chowdhury',
      studentClass: '12',
      group: 'Science',
      shift: 'Morning',
      phone: '01933-445566',
      status: 'Active',
      attendance: 88.5,
    ),
    Student(
      roll: '1004',
      name: 'Sadia Islam',
      studentClass: '11',
      group: 'Science',
      shift: 'Day',
      phone: '01744-556677',
      status: 'Active',
      attendance: 91.0,
    ),
    Student(
      roll: '1005',
      name: 'Farhan Kabir',
      studentClass: '10',
      group: 'Science',
      shift: 'Morning',
      phone: '01555-667788',
      status: 'Inactive',
      attendance: 65.0,
    ),
    Student(
      roll: '1006',
      name: 'Amina Begum',
      studentClass: '11',
      group: 'Humanities',
      shift: 'Evening',
      phone: '01666-778899',
      status: 'Active',
      attendance: 96.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    final filtered = _students.where((s) {
      final matchC = _filterClass == 'All' || s.studentClass == _filterClass;
      final matchG = _filterGroup == 'All' || s.group == _filterGroup;
      final matchS = _filterShift == 'All' || s.shift == _filterShift;
      return matchC && matchG && matchS;
    }).toList();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppNavBar(
        onToggleTheme: appState.toggleTheme,
        isDark: appState.isDarkMode,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Action Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attendance Register',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Filter attendance by Class, Group, and Shift.',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentRose,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () {
                        final absentCount = filtered
                            .where((s) => s.currentStatus == 'A')
                            .length;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppTheme.primaryNavy,
                            content: Text(
                              'SMS Dispatched to $absentCount Guardians: "Respected Guardian, your ward was absent from today\'s class at BSGD Academy."',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.sms, size: 16),
                      label: const Text(
                        'Send SMS to Absentees',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Batch Filters Strip
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _filterClass,
                            decoration: const InputDecoration(
                              labelText: 'Class',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: ['All', '10', '11', '12']
                                .map(
                                  (v) => DropdownMenuItem(
                                    value: v,
                                    child: Text('Class $v'),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _filterClass = v!),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _filterGroup,
                            decoration: const InputDecoration(
                              labelText: 'Group',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: ['All', 'Science', 'Commerce', 'Humanities']
                                .map(
                                  (v) => DropdownMenuItem(
                                    value: v,
                                    child: Text(v),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _filterGroup = v!),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _filterShift,
                            decoration: const InputDecoration(
                              labelText: 'Shift',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: ['All', 'Morning', 'Day', 'Evening']
                                .map(
                                  (v) => DropdownMenuItem(
                                    value: v,
                                    child: Text(v),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _filterShift = v!),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Batch Mark Actions
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          for (var s in filtered) {
                            s.currentStatus = 'P';
                          }
                        });
                      },
                      icon: const Icon(
                        Icons.check_circle_outline,
                        color: AppTheme.accentEmerald,
                        size: 18,
                      ),
                      label: const Text(
                        'Mark All Present',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Showing ${filtered.length} Students in Batch',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Attendance Roster List
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final s = filtered[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.royalBlue,
                          child: Text(
                            s.roll,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        title: Text(
                          s.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          'Guardian: ${s.phone} • Class ${s.studentClass} (${s.shift} Shift)',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildAttBtn(
                              'P',
                              AppTheme.accentEmerald,
                              s.currentStatus == 'P',
                              () => setState(() => s.currentStatus = 'P'),
                            ),
                            const SizedBox(width: 4),
                            _buildAttBtn(
                              'A',
                              AppTheme.accentRose,
                              s.currentStatus == 'A',
                              () => setState(() => s.currentStatus = 'A'),
                            ),
                            const SizedBox(width: 4),
                            _buildAttBtn(
                              'L',
                              AppTheme.accentAmber,
                              s.currentStatus == 'L',
                              () => setState(() => s.currentStatus = 'L'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttBtn(
    String label,
    Color color,
    bool active,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : color,
            fontWeight: FontWeight.w800,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
