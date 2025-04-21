class User {
  final int? id;
  final String fullName;
  final String email;
  final String? phone;
  final String? school;
  final String? department;
  final String? level;
  final String password;

  User({
    this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.school,
    this.department,
    this.level,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'school': school,
      'department': department,
      'level': level,
      'password': password,
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
    );
  }
}