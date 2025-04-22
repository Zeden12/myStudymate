import 'package:mystudymate/db/helpers/notification_helper.dart';
import 'package:mystudymate/db/helpers/task_helper.dart';
import 'package:mystudymate/db/helpers/user_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('studymate_pro.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Updated version
      onCreate: _createDB,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS task_completions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              taskId INTEGER NOT NULL,
              userId INTEGER NOT NULL,
              completedAt TEXT NOT NULL,
              FOREIGN KEY (taskId) REFERENCES tasks (id) ON DELETE CASCADE,
              FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
            )
          ''');
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    final batch = db.batch();
    
    batch.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT,
        school TEXT NOT NULL,
        department TEXT NOT NULL,
        level TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL CHECK(role IN ('student', 'lecturer'))
      )
    ''');

    batch.execute('''
      CREATE TABLE IF NOT EXISTS tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        module TEXT,
        deadline TEXT,
        isCompleted INTEGER DEFAULT 0,
        isAssigned INTEGER DEFAULT 0,
        assignedSchool TEXT,
        assignedDepartment TEXT,
        assignedLevel TEXT,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE)
    ''');

    batch.execute('''
      CREATE TABLE IF NOT EXISTS notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        taskId INTEGER NOT NULL,
        message TEXT NOT NULL,
        isRead INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (taskId) REFERENCES tasks (id) ON DELETE CASCADE)
    ''');

    batch.execute('''
      CREATE TABLE IF NOT EXISTS task_completions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        completedAt TEXT NOT NULL,
        FOREIGN KEY (taskId) REFERENCES tasks (id) ON DELETE CASCADE,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await batch.commit();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  UserHelper get userHelper => UserHelper(this);
  TaskHelper get taskHelper => TaskHelper(this);
  NotificationHelper get notificationHelper => NotificationHelper(this);
}