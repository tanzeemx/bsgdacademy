import 'package:flutter/material.dart';

enum UserRole { student, teacher, guest }

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isStudentLoggedIn = false;
  bool _isTeacherLoggedIn = false;
  String _currentUserName = '';
  String _currentUserRoll = '';

  bool get isStudentLoggedIn => _isStudentLoggedIn;
  bool get isTeacherLoggedIn => _isTeacherLoggedIn;
  String get currentUserName => _currentUserName;
  String get currentUserRoll => _currentUserRoll;

  // Student Authentication
  bool loginStudent(String identifier, String password) {
    // Validates against demo credentials
    if ((identifier.trim() == '1001' || identifier.trim() == 'student@bsgd.com') &&
        password == '123456') {
      _isStudentLoggedIn = true;
      _currentUserName = 'Tanzeem Ahmed';
      _currentUserRoll = '1001';
      notifyListeners();
      return true;
    }
    return false;
  }

  // Teacher / Admin Authentication
  bool loginTeacher(String username, String password) {
    if ((username.trim().toLowerCase() == 'teacher' ||
            username.trim() == 'admin@bsgd.com') &&
        password == 'admin123') {
      _isTeacherLoggedIn = true;
      _currentUserName = 'Prof. A. R. Rahman';
      _currentUserRoll = 'FACULTY-01';
      notifyListeners();
      return true;
    }
    return false;
  }

  void logoutStudent() {
    _isStudentLoggedIn = false;
    _currentUserName = '';
    _currentUserRoll = '';
    notifyListeners();
  }

  void logoutTeacher() {
    _isTeacherLoggedIn = false;
    notifyListeners();
  }
}