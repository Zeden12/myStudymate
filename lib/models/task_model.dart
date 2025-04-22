class Task {
  final int? id;
  final int userId;
  final String title;
  final String? description;
  final String category; // Consider enum if limited options
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

  // Add copyWith for immutable updates
  Task copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    String? category,
    String? module,
    DateTime? deadline,
    bool? isCompleted,
    bool? isAssigned,
    String? assignedSchool,
    String? assignedDepartment,
    String? assignedLevel,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      module: module ?? this.module,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      isAssigned: isAssigned ?? this.isAssigned,
      assignedSchool: assignedSchool ?? this.assignedSchool,
      assignedDepartment: assignedDepartment ?? this.assignedDepartment,
      assignedLevel: assignedLevel ?? this.assignedLevel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title.trim(),
      'description': description?.trim(),
      'category': category.trim(),
      'module': module?.trim(),
      'deadline': deadline?.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'isAssigned': isAssigned ? 1 : 0,
      'assignedSchool': assignedSchool?.trim(),
      'assignedDepartment': assignedDepartment?.trim(),
      'assignedLevel': assignedLevel?.trim(),
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