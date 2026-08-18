import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class LocalDBHelper {
  static const String dbName = 'tasks_database.db';
  static const String tableName = 'tasks';

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            priority TEXT,
            dueDate TEXT,
            isCompleted INTEGER NOT NULL,
            createdAt TEXT NOT NULL,
            isSynced INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<Task>> getTasks() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(tableName, orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) {
      return Task.fromJson(maps[i]);
    });
  }

  Future<void> insertTask(Task task) async {
    final dbClient = await db;
    await dbClient.insert(
      tableName,
      task.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTask(Task task) async {
    final dbClient = await db;
    await dbClient.update(
      tableName,
      task.toJson(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(String id) async {
    final dbClient = await db;
    await dbClient.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Task>> getUnsyncedTasks() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      tableName,
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) {
      return Task.fromJson(maps[i]);
    });
  }
}
