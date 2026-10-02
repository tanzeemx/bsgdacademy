import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final UserRole initialRole;
  final Widget targetScreen;

  const LoginScreen({
    super.key,
    required this.initialRole,
    required this.targetScreen,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late UserRole _selectedRole;
  final TextEditingController _idCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _obscurePassword = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
    if (_selectedRole == UserRole.student) {
      _idCtrl.text = '1001';
      _passCtrl.text = '123456';
    } else {
      _idCtrl.text = 'teacher';
      _passCtrl.text = 'admin123';
    }
  }

  void _handleLogin() {
    final id = _idCtrl.text.trim();
    final pass = _passCtrl.text;
    final auth = AuthService();

    bool success = false;
    if (_selectedRole == UserRole.student) {
      success = auth.loginStudent(id, pass);
    } else {
      success = auth.loginTeacher(id, pass);
    }

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => widget.targetScreen),
      );
    } else {
      setState(() {
        _errorMessage =
            'Invalid password or identifier. Please check demo credentials.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isStudent = _selectedRole == UserRole.student;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isStudent ? 'Student Verification' : 'Faculty Verification',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isStudent
                            ? AppTheme.royalBlue.withOpacity(0.12)
                            : AppTheme.accentRose.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isStudent ? Icons.school : Icons.admin_panel_settings,
                        color: isStudent
                            ? AppTheme.royalBlue
                            : AppTheme.accentRose,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isStudent ? 'Student Sign In' : 'Faculty Access',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Password authentication required to enter.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 24),

                    // Role Switcher Tab
                    SegmentedButton<UserRole>(
                      segments: const [
                        ButtonSegment(
                          value: UserRole.student,
                          label: Text(
                            'Student',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          icon: Icon(Icons.school, size: 16),
                        ),
                        ButtonSegment(
                          value: UserRole.teacher,
                          label: Text(
                            'Teacher',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          icon: Icon(Icons.shield, size: 16),
                        ),
                      ],
                      selected: {_selectedRole},
                      onSelectionChanged: (Set<UserRole> newSelection) {
                        setState(() {
                          _selectedRole = newSelection.first;
                          _errorMessage = '';
                          if (_selectedRole == UserRole.student) {
                            _idCtrl.text = '1001';
                            _passCtrl.text = '123456';
                          } else {
                            _idCtrl.text = 'teacher';
                            _passCtrl.text = 'admin123';
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    if (_errorMessage.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.accentRose.withOpacity(0.1),
                          border: Border.all(color: AppTheme.accentRose),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppTheme.accentRose,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(
                                  color: AppTheme.accentRose,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    TextField(
                      controller: _idCtrl,
                      decoration: InputDecoration(
                        labelText: isStudent
                            ? 'Roll Number or Email'
                            : 'Faculty Username',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: _passCtrl,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Security Password',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _handleLogin(),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isStudent
                            ? AppTheme.royalBlue
                            : AppTheme.primaryNavy,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _handleLogin,
                      child: Text(
                        'Unlock & Enter ${isStudent ? "Portal" : "Dashboard"}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Demo Credentials helper note
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.royalBlue.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DEMO CREDENTIALS:',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.royalBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isStudent
                                ? 'Student Roll: 1001  |  Password: 123456'
                                : 'Teacher User: teacher  |  Password: admin123',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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
