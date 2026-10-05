import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TeacherAttendancePage extends StatefulWidget {
  const TeacherAttendancePage({super.key});

  @override
  State<TeacherAttendancePage> createState() => _TeacherAttendancePageState();
}

class _TeacherAttendancePageState extends State<TeacherAttendancePage> {
  String _period = 'today';

  DateTime get _startDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_period) {
      case 'today':
        return today;
      case 'yesterday':
        return today.subtract(const Duration(days: 1));
      case 'week':
        return today.subtract(const Duration(days: 7));
      case 'month':
        return DateTime(now.year, now.month - 1, now.day);
      case 'year':
        return DateTime(now.year - 1, now.month, now.day);
      case 'all':
        return DateTime(2020);
      default:
        return today;
    }
  }

  DateTime get _endDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 23, 59, 59);
    if (_period == 'yesterday') {
      final y = today.subtract(const Duration(days: 1));
      return DateTime(y.year, y.month, y.day, 23, 59, 59);
    }
    return today;
  }

  @override
  Widget build(BuildContext context) {
    final periods = {
      'today': 'Today',
      'yesterday': 'Yesterday',
      'week': 'Last Week',
      'month': 'Last Month',
      'year': 'Last Year',
      'all': 'All Time',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Attendance Records',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: periods.entries.map((e) {
                  final selected = _period == e.key;
                  return ChoiceChip(
                    label: Text(e.value),
                    selected: selected,
                    selectedColor: AppTheme.royalBlue,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    onSelected: (_) => setState(() => _period = e.key),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('attendance')
                .orderBy('date', descending: true)
                .limit(200)
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Could not load attendance.\n${snap.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                );
              }

              final docs = (snap.data?.docs ?? []).where((doc) {
                final d = doc.data() as Map<String, dynamic>;
                final ts = d['date'];
                if (ts is! Timestamp) return true;
                final dt = ts.toDate();
                return !dt.isBefore(_startDate) && !dt.isAfter(_endDate);
              }).toList();

              if (docs.isEmpty) {
                return Center(
                  child: Text(
                    'No attendance for this period.\n'
                    'Add documents in Firestore collection "attendance".',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                );
              }

              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: docs.length,
                itemBuilder: (ctx, i) {
                  final d = docs[i].data() as Map<String, dynamic>;
                  final date = d['date'] is Timestamp
                      ? (d['date'] as Timestamp).toDate()
                      : null;
                  final dateStr = date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : '—';
                  final status = '${d['status'] ?? 'P'}';
                  final statusColor = status == 'P'
                      ? AppTheme.accentEmerald
                      : status == 'A'
                          ? AppTheme.accentRose
                          : AppTheme.academicGold;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: statusColor.withOpacity(0.15),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      title: Text(
                        '${d['studentName'] ?? d['name'] ?? 'Student'}'
                        '${d['roll'] != null ? '  •  Roll ${d['roll']}' : ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        '$dateStr'
                        '${d['class'] != null || d['studentClass'] != null ? '  •  Class ${d['class'] ?? d['studentClass']}' : ''}'
                        '${d['shift'] != null ? '  •  ${d['shift']}' : ''}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Text(
                        status == 'P'
                            ? 'Present'
                            : status == 'A'
                                ? 'Absent'
                                : 'Late',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}