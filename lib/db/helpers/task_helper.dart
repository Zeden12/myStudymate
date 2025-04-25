import 'package:mystudymate/models/notification_model.dart';
import 'package:mystudymate/models/task_model.dart';
import '../database.dart';
import 'package:flutter/foundation.dart';

class TaskHelper {
  final DatabaseHelper dbHelper;

  TaskHelper(this.dbHelper);

  Future<int> insertTask(Task task) async {
    final db = await dbHelper.database;
    try {
      final taskId = await db.insert('tasks', task.toMap());
      
      if (task.isAssigned && 
          task.assignedSchool != null && 
          task.assignedDepartment != null && 
          task.assignedLevel != null) {
        final students = await dbHelper.userHelper.getStudentsByCriteria(
          task.assignedSchool!,
          task.assignedDepartment!,
          task.assignedLevel!,
        );
        
        await dbHelper.notificationHelper.createAssignmentNotifications(
          taskId,
          task.title,
          students,
        );
      }
      
      return taskId;
    } catch (e) {
      debugPrint('Error inserting task: $e');
      rethrow;
    }
  }

  Future<List<Task>> getPersonalTasks(int userId) async {
    final db = await dbHelper.database;
    try {
      final result = await db.query(
        'tasks',
        where: 'userId = ? AND isAssigned = 0 AND isCompleted = 0',
        whereArgs: [userId],
        orderBy: 'deadline ASC',
      );
      return result.map((map) => Task.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting personal tasks: $e');
      return [];
    }
  }

  Future<List<Task>> getAssignedTasksForStudent(int studentId) async {
    final db = await dbHelper.database;
    try {
      final result = await db.rawQuery('''
        SELECT t.*, 
               CASE WHEN tc.userId IS NOT NULL THEN 1 ELSE 0 END as isCompletedByMe
        FROM tasks t
        LEFT JOIN task_completions tc ON t.id = tc.taskId AND tc.userId = ?
        WHERE t.isAssigned = 1 AND t.isCompleted = 0
        ORDER BY t.deadline ASC
      ''', [studentId]);

      return result.map((map) => Task.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting assigned tasks for student: $e');
      return [];
    }
  }

  Future<List<Task>> getAssignedTasksByLecturer(int userId) async {
    final db = await dbHelper.database;
    try {
      final result = await db.query(
        'tasks',
        where: 'userId = ? AND isAssigned = 1',
        whereArgs: [userId],
        orderBy: 'deadline ASC',
      );
      return result.map((map) => Task.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting lecturer assigned tasks: $e');
      return [];
    }
  }

  Future<List<Task>> getCompletedTasks(int userId) async {
    final db = await dbHelper.database;
    try {
      final result = await db.query(
        'tasks',
        where: 'userId = ? AND isCompleted = 1',
        whereArgs: [userId],
        orderBy: 'completedAt DESC',
      );
      return result.map((map) => Task.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting completed tasks: $e');
      return [];
    }
  }

  Future<int> updateTask(Task task) async {
    final db = await dbHelper.database;
    try {
      return await db.update(
        'tasks',
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
    } catch (e) {
      debugPrint('Error updating task: $e');
      rethrow;
    }
  }

  Future<int> deleteTask(int id) async {
    final db = await dbHelper.database;
    try {
      await db.delete(
        'task_completions',
        where: 'taskId = ?',
        whereArgs: [id],
      );

      return await db.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Error deleting task: $e');
      rethrow;
    }
  }

  Future<int> toggleTaskCompletion(int taskId, int studentId, bool isCompleted) async {
    final db = await dbHelper.database;
    final now = DateTime.now().toIso8601String();

    try {
      if (isCompleted) {

        await db.insert('task_completions', {
          'taskId': taskId,
          'userId': studentId,
          'completedAt': now,
        });

        final task = await getTaskById(taskId);
        await dbHelper.notificationHelper.createNotification(
          Notification(
            userId: task.userId,
            taskId: taskId,
            message: 'Student completed: ${task.title}',
            isRead: false,
            createdAt: DateTime.now(),
          ),
        );
      } else {
        await db.delete(
          'task_completions',
          where: 'taskId = ? AND userId = ?',
          whereArgs: [taskId, studentId],
        );
      }
      return await _updateTaskCompletionStatus(taskId);
    } catch (e) {
      debugPrint('Error toggling task completion: $e');
      rethrow;
    }
  }

  Future<int> _updateTaskCompletionStatus(int taskId) async {
    final db = await dbHelper.database;
    final task = await getTaskById(taskId);

    if (task.isAssigned) {
      final totalStudents = await _countAssignedStudents(taskId);
      final completions = await getTaskCompletions(taskId);
      final isFullyCompleted = completions.length >= totalStudents;

      return await db.update(
        'tasks',
        {
          'isCompleted': isFullyCompleted ? 1 : 0,
          'completedAt': isFullyCompleted ? DateTime.now().toIso8601String() : null,
        },
        where: 'id = ?',
        whereArgs: [taskId],
      );
    }
    return 0;
  }

  Future<List<Map<String, dynamic>>> getTaskCompletions(int taskId) async {
    final db = await dbHelper.database;
    try {
      return await db.rawQuery('''
        SELECT u.fullName, tc.completedAt 
        FROM task_completions tc
        JOIN users u ON tc.userId = u.id
        WHERE tc.taskId = ?
        ORDER BY tc.completedAt DESC
      ''', [taskId]);
    } catch (e) {
      debugPrint('Error getting task completions: $e');
      return [];
    }
  }

  Future<int> _countAssignedStudents(int taskId) async {
    final task = await getTaskById(taskId);
    
    if (task.isAssigned && 
        task.assignedSchool != null && 
        task.assignedDepartment != null && 
        task.assignedLevel != null) {
      final students = await dbHelper.userHelper.getStudentsByCriteria(
        task.assignedSchool!,
        task.assignedDepartment!,
        task.assignedLevel!,
      );
      return students.length;
    }
    return 0;
  }

  Future<Task> getTaskById(int id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) throw Exception('Task not found');
    return Task.fromMap(result.first);
  }

  Future<List<Task>> searchTasks(int userId, String query) async {
    final db = await dbHelper.database;
    try {
      final result = await db.query(
        'tasks',
        where: 'userId = ? AND title LIKE ?',
        whereArgs: [userId, '%$query%'],
      );
      return result.map((map) => Task.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error searching tasks: $e');
      return [];
    }
  }
}