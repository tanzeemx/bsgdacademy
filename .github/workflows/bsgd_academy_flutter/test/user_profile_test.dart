import 'package:bsgd_online_academy/models/user_profile.dart';
import 'package:bsgd_online_academy/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfile', () {
    test('unknown or missing role falls back to student', () {
      expect(UserProfile.fromMap('u', {'role': 'superuser'}).role, 'student');
      expect(UserProfile.fromMap('u', {}).role, 'student');
    });

    test('admin and teacher roles are recognised', () {
      expect(UserProfile.fromMap('u', {'role': 'admin'}).isAdmin, isTrue);
      expect(UserProfile.fromMap('u', {'role': 'Teacher'}).isTeacher, isTrue);
    });

    test('disabled accounts are inactive', () {
      expect(UserProfile.fromMap('u', {'status': 'disabled'}).isActive, isFalse);
      expect(UserProfile.fromMap('u', {}).isActive, isTrue);
    });

    test('reads classLevel written by the admission form', () {
      final p = UserProfile.fromMap('u', {'classLevel': 'HSC'});
      expect(p.studentClass, 'HSC');
    });

    test('tolerates non-string field types', () {
      final p = UserProfile.fromMap('u', {'roll': 1234, 'phone': 1700000000});
      expect(p.roll, '1234');
    });
  });

  group('login form role rules', () {
    test('student form accepts students only', () {
      expect(AuthService.allowedRolesFor(UserRole.student), {'student'});
    });
    test('faculty form accepts teachers and admins, never students', () {
      final roles = AuthService.allowedRolesFor(UserRole.teacher);
      expect(roles, containsAll(['teacher', 'admin']));
      expect(roles, isNot(contains('student')));
    });
    test('guest has no allowed roles', () {
      expect(AuthService.allowedRolesFor(UserRole.guest), isEmpty);
    });
  });
}
