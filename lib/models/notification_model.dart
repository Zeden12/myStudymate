class Notification {
  final int? id;
  final int userId;
  final int taskId;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  Notification({
    this.id,
    required this.userId,
    required this.taskId,
    required this.message,
    DateTime? createdAt,
    this.isRead = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'taskId': taskId,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead ? 1 : 0,
    };
  }

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'],
      userId: map['userId'],
      taskId: map['taskId'],
      message: map['message'],
      createdAt: DateTime.parse(map['createdAt']),
      isRead: map['isRead'] == 1,
    );
  }

  Notification copyWith({
    int? id,
    int? userId,
    int? taskId,
    String? message,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  String toString() {
    return 'Notification(id: $id, userId: $userId, taskId: $taskId, '
           'message: $message, createdAt: $createdAt, isRead: $isRead)';
  }
}