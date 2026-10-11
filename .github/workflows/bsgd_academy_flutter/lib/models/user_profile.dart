/// User profile loaded from Firestore (`users`, `teachers` or `students`).
/// Document ID = Firebase Auth UID.
///
/// Roles are only ever *read* from trusted documents. Clients must never be
/// able to write `role` (enforced in `firestore.rules`).
class UserProfile {
  static const String roleStudent = 'student';
  static const String roleTeacher = 'teacher';
  static const String roleAdmin = 'admin';
  static const Set<String> validRoles = {roleStudent, roleTeacher, roleAdmin};

  final String uid;
  final String email;
  final String name;
  final String role; // "student" | "teacher" | "admin"
  final String status; // "active" | "disabled" | "suspended"
  final String? roll;
  final String? studentClass;
  final String? group;
  final String? shift;
  final String? phone;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.status = 'active',
    this.roll,
    this.studentClass,
    this.group,
    this.shift,
    this.phone,
  });

  bool get isTeacher => role == roleTeacher;
  bool get isStudent => role == roleStudent;
  bool get isAdmin => role == roleAdmin;
  bool get isActive => status != 'disabled' && status != 'suspended';

  /// Unknown or missing roles fall back to the least-privileged role.
  static String normalizeRole(Object? raw) {
    final value = raw?.toString().trim().toLowerCase();
    return validRoles.contains(value) ? value! : roleStudent;
  }

  static String? _str(Object? v) => v?.toString();

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      email: _str(data['email']) ?? '',
      name: _str(data['name']) ?? '',
      role: normalizeRole(data['role']),
      status: _str(data['status']) ?? 'active',
      roll: _str(data['roll']),
      // Admission screen writes `classLevel`; older docs use `studentClass`.
      studentClass: _str(data['studentClass']) ?? _str(data['classLevel']),
      group: _str(data['group']),
      shift: _str(data['shift']),
      phone: _str(data['phone']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'status': status,
      if (roll != null) 'roll': roll,
      if (studentClass != null) 'studentClass': studentClass,
      if (group != null) 'group': group,
      if (shift != null) 'shift': shift,
      if (phone != null) 'phone': phone,
    };
  }
}
