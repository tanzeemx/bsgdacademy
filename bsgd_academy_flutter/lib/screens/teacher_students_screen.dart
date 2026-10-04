import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TeacherStudentsScreen extends StatelessWidget {
  const TeacherStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          child: Row(
            children: [
              const Text(
                'Student Roster',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                'Firestore: students',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('students')
                .orderBy('roll')
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No students yet.\nAdd documents in Firestore collection "students".',
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      AppTheme.royalBlue.withOpacity(0.08),
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Roll',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Name',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Class',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Group',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Shift',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Phone',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Status',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                    rows: docs.map((doc) {
                      final d = doc.data() as Map<String, dynamic>;
                      return DataRow(
                        cells: [
                          DataCell(Text('${d['roll'] ?? '—'}')),
                          DataCell(Text('${d['name'] ?? '—'}')),
                          DataCell(
                            Text('${d['studentClass'] ?? d['class'] ?? '—'}'),
                          ),
                          DataCell(Text('${d['group'] ?? '—'}')),
                          DataCell(Text('${d['shift'] ?? '—'}')),
                          DataCell(Text('${d['phone'] ?? '—'}')),
                          DataCell(Text('${d['status'] ?? 'Active'}')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
