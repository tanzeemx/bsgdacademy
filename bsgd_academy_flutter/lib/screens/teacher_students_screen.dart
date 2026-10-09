import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'teacher_exams_screen.dart';

class TeacherStudentsScreen extends StatelessWidget {
  const TeacherStudentsScreen({super.key});

  String _nameOf(Map<String, dynamic> d) {
    final name = d['name']?.toString().trim() ?? '';
    if (name.isNotEmpty) return name;
    final email = d['email']?.toString().trim() ?? '';
    if (email.isNotEmpty) return email.split('@').first;
    return 'Student';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Students',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Logged-in students from Firestore: students/{uid}',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 16),

        // —— Registered students ——
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('students').snapshots(),
          builder: (context, snap) {
            if (snap.hasError) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: ${snap.error}'),
                ),
              );
            }
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = List<QueryDocumentSnapshot>.from(snap.data?.docs ?? []);
            // Sort by name in app (avoids index issues)
            docs.sort((a, b) {
              final na = _nameOf(a.data() as Map<String, dynamic>);
              final nb = _nameOf(b.data() as Map<String, dynamic>);
              return na.toLowerCase().compareTo(nb.toLowerCase());
            });

            if (docs.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No students yet.\n\n'
                    '1) Firebase Authentication → create user\n'
                    '2) Firestore → students → doc ID = that user UID\n'
                    '3) Fields: name, email, role: student, roll, studentClass, group, phone',
                    textAlign: TextAlign.left,
                  ),
                ),
              );
            }

            return Column(
              children: docs.map((doc) {
                final d = doc.data() as Map<String, dynamic>;
                final name = _nameOf(d);
                final email = d['email']?.toString() ?? '—';
                final roll = d['roll']?.toString() ?? '—';
                final klass = d['studentClass']?.toString() ??
                    d['classLevel']?.toString() ??
                    '—';
                final group = d['group']?.toString() ?? '—';
                final phone = d['phone']?.toString() ?? '—';

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.royalBlue.withOpacity(0.15),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'S',
                        style: const TextStyle(
                          color: AppTheme.royalBlue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        [
                          email,
                          if (roll != '—') 'Roll: $roll',
                          if (klass != '—') 'Class $klass',
                          if (group != '—') group,
                          if (phone != '—') phone,
                        ].join('  •  '),
                        style: const TextStyle(fontSize: 12.5),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),

        const SizedBox(height: 28),
        const Text(
          'Pending admissions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'From admission form (not login accounts yet)',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 10),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('admissions')
              .orderBy('createdAt', descending: true)
              .limit(30)
              .snapshots(),
          builder: (context, snap) {
            if (snap.hasError) {
              // orderBy may need index — fallback without order
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('admissions')
                    .limit(30)
                    .snapshots(),
                builder: (context, snap2) {
                  return _admissionList(snap2.data?.docs ?? []);
                },
              );
            }
            if (snap.connectionState == ConnectionState.waiting) {
              return const SizedBox.shrink();
            }
            final docs = (snap.data?.docs ?? []).where((doc) {
              final d = doc.data() as Map<String, dynamic>;
              return d['status'] != 'approved' && d['status'] != 'rejected';
            }).toList();
            return _admissionList(docs);
          },
        ),
      ],
    );
  }

  Widget _admissionList(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No pending admissions.'),
        ),
      );
    }
    return Column(
      children: docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        final name = (d['name'] ?? d['studentName'] ?? 'Applicant').toString();
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.academicGold.withOpacity(0.25),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'A',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              [
                d['email'] ?? '',
                if (d['classLevel'] != null) 'Class ${d['classLevel']}',
                d['group'] ?? '',
                d['phone'] ?? '',
              ].where((e) => e.toString().isNotEmpty).join('  •  '),
            ),
            trailing: const Text(
              'Pending',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}