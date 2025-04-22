class User {
  final int? id;
  final String fullName;
  final String email;
  final String? phone;
  final String school;
  final String department;
  final String level;
  final String password;
  final String role; // Consider enum

  User({
    this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.school,
    required this.department,
    required this.level,
    required this.password,
    required this.role,
  });

  // Add copyWith
  User copyWith({
    int? id,
    String? fullName,
    String? email,
    String? phone,
    String? school,
    String? department,
    String? level,
    String? password,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      school: school ?? this.school,
      department: department ?? this.department,
      level: level ?? this.level,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName.trim(),
      'email': email.trim(),
      'phone': phone?.trim(),
      'school': school.trim(),
      'department': department.trim(),
      'level': level.trim(),
      'password': password, // Note: Should be hashed before storage
      'role': role.trim(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      fullName: map['fullName'],
      email: map['email'],
      phone: map['phone'],
      school: map['school'],
      department: map['department'],
      level: map['level'],
      password: map['password'],
      role: map['role'],
    );
  }
}