import 'package:mystudymate/db/database.dart';
import 'package:mystudymate/models/notification_model.dart';
import 'package:mystudymate/models/task_model.dart';
import 'package:mystudymate/db/helpers/notification_helper.dart';

class DeadlineHelper {
  final DatabaseHelper dbHelper;
  final NotificationHelper notificationHelper;

  DeadlineHelper(this.dbHelper, this.notificationHelper);

  Future<void> checkDeadlines() async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    final oneHourLater = now.add(Duration(hours: 1));

    // Get tasks with deadlines within the next hour
    final tasks = await db.query(
      'tasks',
      where: 'deadline BETWEEN ? AND ? AND isCompleted = 0',
      whereArgs: [now.toIso8601String(), oneHourLater.toIso8601String()],
    );

    for (var taskMap in tasks) {
      final task = Task.fromMap(taskMap);
      // Check if notification already exists
      final existing = await db.query(
        'notifications',
        where: 'taskId = ? AND message LIKE ?',
        whereArgs: [task.id, '%due in less than 1 hour%'],
      );

      if (existing.isEmpty) {
        await notificationHelper.createNotification(
          Notification(
            userId: task.userId,
            taskId: task.id!,
            message: 'Task "${task.title}" is due in less than 1 hour!',
            isRead: false,
            createdAt: DateTime.now(), // 👈 Fix here
          ),
        );
      }
    }
  }
}
