class Task {
  final int? id;
  final int userId;
  final String title;
  final String? description;
  final String category;
  final String? module;
  final DateTime? deadline;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool isAssigned;
  final String? assignedSchool;
  final String? assignedDepartment;
  final String? assignedLevel;
  final bool isCompletedByMe;

  Task({
    this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.category,
    this.module,
    this.deadline,
    this.isCompleted = false,
    this.completedAt,
    this.isAssigned = false,
    this.assignedSchool,
    this.assignedDepartment,
    this.assignedLevel,
    this.isCompletedByMe = false,
  });

  Task copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    String? category,
    String? module,
    DateTime? deadline,
    bool? isCompleted,
    DateTime? completedAt,
    bool? isAssigned,
    String? assignedSchool,
    String? assignedDepartment,
    String? assignedLevel,
    bool? isCompletedByMe,
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
      completedAt: completedAt ?? this.completedAt,
      isAssigned: isAssigned ?? this.isAssigned,
      assignedSchool: assignedSchool ?? this.assignedSchool,
      assignedDepartment: assignedDepartment ?? this.assignedDepartment,
      assignedLevel: assignedLevel ?? this.assignedLevel,
      isCompletedByMe: isCompletedByMe ?? this.isCompletedByMe,
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
      'completedAt': completedAt?.toIso8601String(),
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
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
      isAssigned: map['isAssigned'] == 1,
      assignedSchool: map['assignedSchool'],
      assignedDepartment: map['assignedDepartment'],
      assignedLevel: map['assignedLevel'],
      isCompletedByMe: map['isCompletedByMe'] == 1,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, isCompleted: $isCompleted, isCompletedByMe: $isCompletedByMe)';
  }
}