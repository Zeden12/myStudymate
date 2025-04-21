class Notification {
  final int? id;
  final int userId;
  final int taskId;
  final String message;
  final String createdAt;
  final bool isRead;

  Notification({
    this.id,
    required this.userId,
    required this.taskId,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'],
      userId: map['userId'],
      taskId: map['taskId'],
      message: map['message'],
      createdAt: map['createdAt'],
      isRead: map['isRead'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'taskId': taskId,
      'message': message,
      'createdAt': createdAt,
      'isRead': isRead ? 1 : 0,
    };
  }
}