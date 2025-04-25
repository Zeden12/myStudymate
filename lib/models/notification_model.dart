import 'package:flutter/foundation.dart';

@immutable
class Notification {
  final int? id;
  final int userId;
  final int? taskId;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  Notification({
    this.id,
    required this.userId,
    this.taskId,
    required this.message,
    DateTime? createdAt,
    this.isRead = false,
  }) : createdAt = createdAt != null 
          ? DateTime.fromMicrosecondsSinceEpoch(createdAt.microsecondsSinceEpoch)
          : DateTime.now();

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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notification &&
        other.id == id &&
        other.userId == userId &&
        other.taskId == taskId &&
        other.message == message &&
        other.createdAt == createdAt &&
        other.isRead == isRead;
  }

  @override
  int get hashCode {
    return Object.hash(id, userId, taskId, message, createdAt, isRead);
  }

  @override
  String toString() {
    return 'Notification(id: $id, userId: $userId, taskId: $taskId, '
        'message: $message, createdAt: $createdAt, isRead: $isRead)';
  }
}