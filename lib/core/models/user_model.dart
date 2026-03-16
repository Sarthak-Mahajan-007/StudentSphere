enum UserRole {
  student,
  faculty,
  admin,
  warden,  // Changed from hostelManager to match database constraint
  guest;

  String get value {
    switch (this) {
      case UserRole.student:
        return 'student';
      case UserRole.faculty:
        return 'faculty';
      case UserRole.admin:
        return 'admin';
      case UserRole.warden:
        return 'warden';  // Changed to match database
      case UserRole.guest:
        return 'guest';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'student':
        return UserRole.student;
      case 'faculty':
        return UserRole.faculty;
      case 'admin':
        return UserRole.admin;
      case 'warden':  // Updated to match database
        return UserRole.warden;
      case 'guest':
        return UserRole.guest;
      default:
        return UserRole.guest;
    }
  }
}

class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? studentId;
  final String? department;
  final String? year;
  final String? phone;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final Map<String, dynamic>? additionalData;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.studentId,
    this.department,
    this.year,
    this.phone,
    this.profileImageUrl,
    required this.createdAt,
    this.lastLogin,
    this.additionalData,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role.value,
      'studentId': studentId,
      'department': department,
      'year': year,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'additionalData': additionalData,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unknown',
      role: UserRole.fromString(map['role']?.toString() ?? 'guest'),
      studentId: map['studentId']?.toString(),
      department: map['department']?.toString(),
      year: map['year']?.toString(),
      phone: map['phone']?.toString(),
      profileImageUrl: map['profileImageUrl']?.toString(),
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      lastLogin: map['lastLogin'] != null
          ? DateTime.tryParse(map['lastLogin']?.toString() ?? '')
          : null,
      additionalData: map['additionalData'] as Map<String, dynamic>?,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    UserRole? role,
    String? studentId,
    String? department,
    String? year,
    String? phone,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastLogin,
    Map<String, dynamic>? additionalData,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      year: year ?? this.year,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}

