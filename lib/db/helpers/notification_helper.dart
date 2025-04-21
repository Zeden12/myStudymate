import 'package:mystudymate/models/notification_model.dart';
import 'package:mystudymate/models/user_model.dart';
import '../database.dart';

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

  Future<int> markAsRead(int notificationId) async {
    final db = await dbHelper.database;
    return await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
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
    
    for (final student in students) {
      batch.insert('notifications', {
        'userId': student.id,
        'taskId': taskId,
        'message': 'New assignment: $title',
        'isRead': 0,
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
    
    await batch.commit();
  }
}