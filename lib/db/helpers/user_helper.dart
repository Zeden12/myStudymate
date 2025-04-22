import 'package:mystudymate/models/user_model.dart';
import '../database.dart';

class UserHelper {
  final DatabaseHelper dbHelper;

  UserHelper(this.dbHelper);

  Future<int> insertUser(User user) async {
    final db = await dbHelper.database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }

  Future<User?> authenticateUser(String email, String password) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }

  Future<List<User>> getStudentsByCriteria(String school, String department, String level) async {
  final db = await dbHelper.database;
  final result = await db.query(
    'users',
    where: 'role = ? AND school = ? AND department = ? AND level = ?',
    whereArgs: [
      'student', 
      school.trim(), 
      department.trim(), 
      level.trim()
    ],
  );
  return result.map((map) => User.fromMap(map)).toList();
}
}