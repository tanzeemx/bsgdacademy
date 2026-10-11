import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';

enum UserRole { student, teacher, admin, guest }

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
  bool get isAdminLoggedIn => isLoggedIn && _profile!.isAdmin;

  String get currentUserName => _profile?.name ?? '';
  String get currentUserRoll => _profile?.roll ?? '';
  String get currentUserEmail => _profile?.email ?? '';
  User? get firebaseUser => _auth.currentUser;

  /// Restores the profile for an already signed-in Firebase user.
  Future<void> init() async {
    final user = _auth.currentUser;
    if (user != null) await profileFor(user.uid);
  }

  /// Returns the profile for [uid], using the cached copy when it matches.
  /// Returns null when the profile is missing or could not be loaded
  /// (see [error]).
  Future<UserProfile?> profileFor(String uid, {bool forceRefresh = false}) async {
    if (!forceRefresh && _profile != null && _profile!.uid == uid) {
      return _profile;
    }
    return _loadProfile(uid);
  }

  /// Which roles may use each login form. The faculty form also accepts
  /// admins so staff do not need a separate entry point.
  static Set<String> allowedRolesFor(UserRole expected) {
    switch (expected) {
      case UserRole.student:
        return {UserProfile.roleStudent};
      case UserRole.teacher:
        return {UserProfile.roleTeacher, UserProfile.roleAdmin};
      case UserRole.admin:
        return {UserProfile.roleAdmin};
      case UserRole.guest:
        return <String>{};
    }
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

      final profile = await _loadProfile(uid);
      if (profile == null) {
        await _auth.signOut();
        _profile = null;
        _error ??= 'Your account has no profile yet. Please contact the academy.';
        return false;
      }

      if (!profile.isActive) {
        await _auth.signOut();
        _profile = null;
        _error = 'This account has been disabled. Please contact the academy.';
        return false;
      }

      if (!allowedRolesFor(expectedRole).contains(profile.role)) {
        await _auth.signOut();
        _profile = null;
        _error = expectedRole == UserRole.student
            ? 'This is not a student account.'
            : 'This account does not have faculty access.';
        return false;
      }

      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e);
      return false;
    } catch (e) {
      debugPrint('Sign-in error: $e');
      _error = 'Something went wrong. Please try again.';
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

  Future<bool> sendPasswordReset(String email) async {
    _error = null;
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _profile = null;
    _error = null;
    notifyListeners();
  }

  void logoutStudent() => signOut();
  void logoutTeacher() => signOut();

  /// Resolves the role from *trusted* documents only:
  ///  1. `users/{uid}` with role `admin`
  ///  2. `teachers/{uid}`  -> always teacher
  ///  3. `students/{uid}`  -> always student
  ///  4. `users/{uid}`     -> role normalised (student self-registration)
  /// The `role` field inside `teachers` / `students` documents is ignored.
  Future<UserProfile?> _loadProfile(String uid) async {
    try {
      final userSnap = await _db.collection('users').doc(uid).get();
      final userData = userSnap.data();

      if (userData != null &&
          UserProfile.normalizeRole(userData['role']) ==
              UserProfile.roleAdmin) {
        _profile = UserProfile.fromMap(uid, userData);
        return _profile;
      }

      final teacherSnap = await _db.collection('teachers').doc(uid).get();
      final teacherData = teacherSnap.data();
      if (teacherData != null) {
        _profile = UserProfile.fromMap(uid, {
          ...teacherData,
          'role': UserProfile.roleTeacher,
        });
        return _profile;
      }

      final studentSnap = await _db.collection('students').doc(uid).get();
      final studentData = studentSnap.data();
      if (studentData != null) {
        _profile = UserProfile.fromMap(uid, {
          ...studentData,
          'role': UserProfile.roleStudent,
        });
        return _profile;
      }

      if (userData != null) {
        _profile = UserProfile.fromMap(uid, userData);
        return _profile;
      }

      _profile = null;
      return null;
    } on FirebaseException catch (e) {
      debugPrint('Profile load failed: ${e.code}');
      _profile = null;
      _error = e.code == 'permission-denied'
          ? 'You do not have permission to load this profile.'
          : 'Could not load your profile. Check your connection and retry.';
      return null;
    } catch (e) {
      debugPrint('Profile load error: $e');
      _profile = null;
      _error = 'Could not load your profile. Please retry.';
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
        return 'Login failed. Please try again.';
    }
  }
}
