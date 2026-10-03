import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class TeacherMessageScreen extends StatefulWidget {
  const TeacherMessageScreen({super.key});

  @override
  State<TeacherMessageScreen> createState() => _TeacherMessageScreenState();
}

class _TeacherMessageScreenState extends State<TeacherMessageScreen> {
  String? _selectedStudentId;
  String? _selectedStudentName;
  final _msgCtrl = TextEditingController();

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _selectedStudentId == null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final teacherName = AuthService().currentUserName;

    // Chat room id = sorted teacherId_studentId
    final ids = [uid, _selectedStudentId!]..sort();
    final chatId = ids.join('_');

    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

    await chatRef.set({
      'participants': [uid, _selectedStudentId],
      'teacherId': uid,
      'studentId': _selectedStudentId,
      'studentName': _selectedStudentName,
      'teacherName': teacherName,
      'lastMessage': text,
      'lastAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await chatRef.collection('messages').add({
      'text': text,
      'senderId': uid,
      'senderRole': 'teacher',
      'createdAt': FieldValue.serverTimestamp(),
    });

    _msgCtrl.clear();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teacherId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Row(
      children: [
        // Student list
        Container(
          width: 260,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Students',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  // Later: load real students collection
                  // For now show chats this teacher already has
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .where('teacherId', isEqualTo: teacherId)
                      .snapshots(),
                  builder: (context, snap) {
                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No conversations yet.\nStart by selecting a student when student list is ready.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (ctx, i) {
                        final d = docs[i].data() as Map<String, dynamic>;
                        final sid = d['studentId'] as String? ?? '';
                        final sname = d['studentName'] as String? ?? 'Student';
                        final selected = sid == _selectedStudentId;
                        return ListTile(
                          selected: selected,
                          selectedTileColor: AppTheme.royalBlue.withOpacity(
                            0.1,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.royalBlue,
                            child: Text(
                              sname.isNotEmpty ? sname[0] : 'S',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            sname,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          subtitle: Text(
                            d['lastMessage'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11),
                          ),
                          onTap: () => setState(() {
                            _selectedStudentId = sid;
                            _selectedStudentName = sname;
                          }),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Chat area
        Expanded(
          child: _selectedStudentId == null
              ? const Center(
                  child: Text(
                    'Select a student to start messaging',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.royalBlue,
                            child: Text(
                              (_selectedStudentName ?? 'S')[0],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _selectedStudentName ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: () {
                          final ids = [teacherId, _selectedStudentId!]..sort();
                          final chatId = ids.join('_');
                          return FirebaseFirestore.instance
                              .collection('chats')
                              .doc(chatId)
                              .collection('messages')
                              .orderBy('createdAt')
                              .snapshots();
                        }(),
                        builder: (context, snap) {
                          final docs = snap.data?.docs ?? [];
                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: docs.length,
                            itemBuilder: (ctx, i) {
                              final d = docs[i].data() as Map<String, dynamic>;
                              final isMe = d['senderId'] == teacherId;
                              return Align(
                                alignment: isMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                        0.35,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? AppTheme.royalBlue
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    d['text'] ?? '',
                                    style: TextStyle(
                                      color: isMe
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _msgCtrl,
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                              onSubmitted: (_) => _send(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: AppTheme.royalBlue,
                            child: IconButton(
                              icon: const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 18,
                              ),
                              onPressed: _send,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
