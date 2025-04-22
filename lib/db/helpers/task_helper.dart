import 'package:mystudymate/models/task_model.dart';
import '../database.dart';

class TaskHelper {
  final DatabaseHelper dbHelper;

  TaskHelper(this.dbHelper);

  Future<int> insertTask(Task task) async {
    final db = await dbHelper.database;
    final taskId = await db.insert('tasks', task.toMap());
    
    // Notify students when a task is assigned
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
  }

  Future<List<Task>> getPersonalTasks(int userId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'tasks',
      where: 'userId = ? AND isAssigned = 0',
      whereArgs: [userId],
      orderBy: 'deadline ASC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getAssignedTasks(String school, String department, String level) async {
  final db = await dbHelper.database;
  final result = await db.query(
    'tasks',
    where: 'isAssigned = 1 AND assignedSchool = ? AND assignedDepartment = ? AND assignedLevel = ?',
    whereArgs: [school.trim(), department.trim(), level.trim()],
    orderBy: 'deadline ASC',
  );
  return result.map((map) => Task.fromMap(map)).toList();
}

  Future<List<Task>> getAssignedTasksByLecturer(int userId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'tasks',
      where: 'userId = ? AND isAssigned = 1',
      whereArgs: [userId],
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

  Future<List<Task>> getActiveTasks(int userId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'tasks',
      where: 'userId = ? AND isCompleted = 0',
      whereArgs: [userId],
      orderBy: 'deadline ASC',
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
    if (isCompleted) {
      final taskData = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
      final userId = taskData.isNotEmpty ? taskData[0]['userId'] as int : null;
      
      if (userId != null) {
        await db.insert('task_completions', {
          'taskId': id,
          'userId': userId,
          'completedAt': DateTime.now().toIso8601String(),
        });
      }
    }
    return await db.update(
      'tasks',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getTaskCompletions(int taskId) async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
      SELECT u.fullName, tc.completedAt 
      FROM task_completions tc
      JOIN users u ON tc.userId = u.id
      WHERE tc.taskId = ?
      ORDER BY tc.completedAt DESC
    ''', [taskId]);
  }
}