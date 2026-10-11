import 'package:flutter/material.dart';
import '../widgets/app_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_theme.dart';
import '../main.dart';

class LiveClassScreen extends StatefulWidget {
  const LiveClassScreen({super.key});

  @override
  State<LiveClassScreen> createState() => _LiveClassScreenState();
}

class _LiveClassScreenState extends State<LiveClassScreen> {
  final List<String> _chatMessages = [
    'Nusrat (Roll 1002): Sir, could you re-explain problem 3?',
    'Rahim (Roll 1003): Formula is clear now sir!',
    'Sir Tanzeem (Instructor): Check formula 4 on your lecture notes sheet.',
  ];
  final TextEditingController _chatCtrl = TextEditingController();

  void _sendChat() {
    if (_chatCtrl.text.trim().isEmpty) return;
    setState(() {
      _chatMessages.add('You (Student): ${_chatCtrl.text.trim()}');
      _chatCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppNavBar(onToggleTheme: appState.toggleTheme, isDark: appState.isDarkMode),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Simulated Stream Frame
                Container(
                  width: double.infinity,
                  height: 380,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.academicGold, width: 2),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.live_tv, size: 54, color: AppTheme.accentRose),
                          SizedBox(height: 12),
                          Text(
                            'Calculus Master Problem Clinic Live Stream',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                          ),
                          SizedBox(height: 4),
                          Text('Instructor: Sir Tanzeem • Morning Shift Batch', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentRose,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.circle, size: 8, color: Colors.white),
                              SizedBox(width: 6),
                              Text('LIVE (84 Students)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Live Chat Box
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.chat_bubble_outline, color: AppTheme.royalBlue, size: 18),
                            SizedBox(width: 8),
                            Text('Live Classroom Discussion', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          ],
                        ),
                        const Divider(height: 20),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _chatMessages.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(_chatMessages[i], style: const TextStyle(fontSize: 13)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _chatCtrl,
                                decoration: const InputDecoration(
                                  hintText: 'Ask a question in class...',
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (_) => _sendChat(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filled(
                              style: IconButton.styleFrom(backgroundColor: AppTheme.royalBlue),
                              icon: const Icon(Icons.send, size: 18),
                              onPressed: _sendChat,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}