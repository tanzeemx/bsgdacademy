import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';

enum UserRole { student, teacher, guest }

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isLoggedIn => _auth.currentUser != null && _profile != null;
  bool get isStudentLoggedIn => isLoggedIn && _profile!.isStudent;
  bool get isTeacherLoggedIn => isLoggedIn && _profile!.isTeacher;

  String get currentUserName => _profile?.name ?? '';
  String get currentUserRoll => _profile?.roll ?? '';
  String get currentUserEmail => _profile?.email ?? '';
  User? get firebaseUser => _auth.currentUser;

  Future<void> init() async {
    final user = _auth.currentUser;
    if (user != null) await _loadProfile(user.uid);
  }

  Future<bool> signIn({
    required String email,
    required String password,
    required UserRole expectedRole,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid == null) {
        _error = 'Login failed. Please try again.';
        return false;
      }

      final expected = expectedRole == UserRole.teacher ? 'teacher' : 'student';

      final profile = await _loadProfile(uid, expectedRole: expected);
      if (profile == null) {
        await _auth.signOut();
        _error =
            'Account exists but no $expected profile in Firestore. Contact admin.';
        return false;
      }

      if (profile.role != expected) {
        await _auth.signOut();
        _profile = null;
        _error = expectedRole == UserRole.teacher
            ? 'This account is not a teacher account.'
            : 'This account is not a student account.';
        return false;
      }

      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e);
      return false;
    } catch (e) {
      _error = 'Unexpected error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginStudent(String identifier, String password) {
    final email = identifier.contains('@')
        ? identifier.trim()
        : '${identifier.trim()}@bsgd.com';
    return signIn(
      email: email,
      password: password,
      expectedRole: UserRole.student,
    );
  }

  Future<bool> loginTeacher(String username, String password) {
    final email = username.contains('@')
        ? username.trim()
        : '${username.trim()}@bsgd.com';
    return signIn(
      email: email,
      password: password,
      expectedRole: UserRole.teacher,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _profile = null;
    _error = null;
    notifyListeners();
  }

  void logoutStudent() => signOut();
  void logoutTeacher() => signOut();

  /// teachers/{uid} or students/{uid} (doc id = Auth UID)
  Future<UserProfile?> _loadProfile(String uid, {String? expectedRole}) async {
    try {
      if (expectedRole == 'teacher' || expectedRole == null) {
        final doc = await _db.collection('teachers').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          final data = Map<String, dynamic>.from(doc.data()!);
          data['role'] = data['role'] ?? 'teacher';
          _profile = UserProfile.fromMap(uid, data);
          return _profile;
        }
      }

      if (expectedRole == 'student' || expectedRole == null) {
        final doc = await _db.collection('students').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          final data = Map<String, dynamic>.from(doc.data()!);
          data['role'] = data['role'] ?? 'student';
          _profile = UserProfile.fromMap(uid, data);
          return _profile;
        }
      }

      // optional fallback
      final userDoc = await _db.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        _profile = UserProfile.fromMap(uid, userDoc.data()!);
        return _profile;
      }

      _profile = null;
      return null;
    } catch (e) {
      debugPrint('Firestore profile load error: $e');
      _profile = null;
      return null;
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Login failed.';
    }
  }
}
