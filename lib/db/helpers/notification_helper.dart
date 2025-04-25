import 'package:mystudymate/db/database.dart';
import 'package:mystudymate/models/notification_model.dart';
import 'package:mystudymate/models/user_model.dart';

class NotificationHelper {
  final DatabaseHelper dbHelper;

  NotificationHelper(this.dbHelper);

  Future<int> createNotification(Notification notification) async {
    final db = await dbHelper.database;
    return await db.insert('notifications', notification.toMap());
  }

  Future<List<Notification>> getNotificationsByUser(int userId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'notifications',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => Notification.fromMap(map)).toList();
  }

  Future<int> getUnreadNotificationCount(int userId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM notifications WHERE userId = ? AND isRead = 0',
      [userId]
    );
    return result[0]['COUNT(*)'] as int;
  }

  Future<int> markAsRead(int notificationId) async {
    final db = await dbHelper.database;
    return await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<int> markAllAsRead(int userId) async {
    final db = await dbHelper.database;
    return await db.update(
      'notifications',
      {'isRead': 1},
      where: 'userId = ? AND isRead = 0',
      whereArgs: [userId],
    );
  }

  Future<int> deleteNotification(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> createAssignmentNotifications(int taskId, String title, List<User> students) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();
    
    for (final student in students) {
      batch.insert('notifications', {
        'userId': student.id!,
        'taskId': taskId,
        'message': 'New assignment: $title',
        'isRead': 0,
        'createdAt': now,
      });
    }
    
    await batch.commit();
  }

  Future<void> notifyTaskCompletion(int taskId, int lecturerId, String taskTitle, int completionCount) async {
    final db = await dbHelper.database;
    await db.insert('notifications', {
      'userId': lecturerId,
      'taskId': taskId,
      'message': completionCount > 0
          ? '$completionCount student(s) completed: $taskTitle'
          : 'Task completed: $taskTitle',
      'isRead': 0,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}