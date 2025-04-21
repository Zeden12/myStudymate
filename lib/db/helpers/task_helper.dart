import 'package:mystudymate/models/task_model.dart';
import '../database.dart';

class TaskHelper {
  final DatabaseHelper dbHelper;

  TaskHelper(this.dbHelper);

  Future<int> insertTask(Task task) async {
    final db = await dbHelper.database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getTasksByUser(int userId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'tasks',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'deadline ASC',
    );

    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getUpcomingTasks(int userId) async {
    final db = await dbHelper.database;
    final now = DateTime.now().toIso8601String();
    final result = await db.query(
      'tasks',
      where: 'userId = ? AND deadline >= ? AND isCompleted = 0',
      whereArgs: [userId, now],
      orderBy: 'deadline ASC',
    );

    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getCompletedTasks(int userId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'tasks',
      where: 'userId = ? AND isCompleted = 1',
      whereArgs: [userId],
      orderBy: 'deadline DESC',
    );

    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await dbHelper.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleTaskCompletion(int id, bool isCompleted) async {
    final db = await dbHelper.database;
    return await db.update(
      'tasks',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}