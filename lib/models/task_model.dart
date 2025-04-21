class Task {
  final int? id;
  final int userId;
  final String title;
  final String? description;
  final String category;
  final String? module;
  final DateTime? deadline;
  final bool isCompleted;
  final bool isAssigned;
  final String? assignedSchool;
  final String? assignedDepartment;
  final String? assignedLevel;

  Task({
    this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.category,
    this.module,
    this.deadline,
    this.isCompleted = false,
    this.isAssigned = false,
    this.assignedSchool,
    this.assignedDepartment,
    this.assignedLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'module': module,
      'deadline': deadline?.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'isAssigned': isAssigned ? 1 : 0,
      'assignedSchool': assignedSchool,
      'assignedDepartment': assignedDepartment,
      'assignedLevel': assignedLevel,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      module: map['module'],
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
      isCompleted: map['isCompleted'] == 1,
      isAssigned: map['isAssigned'] == 1,
      assignedSchool: map['assignedSchool'],
      assignedDepartment: map['assignedDepartment'],
      assignedLevel: map['assignedLevel'],
    );
  }
}