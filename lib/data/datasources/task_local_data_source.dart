import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks(String userId);
  Future<void> cacheTask(TaskModel taskToCache);
  Future<void> updateTask(TaskModel taskToUpdate);
  Future<void> deleteTask(String id);
  Future<List<TaskModel>> getUnsyncedTasks(String userId);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
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
      version: 2,
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
            isSynced INTEGER NOT NULL,
            userId TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE $tableName ADD COLUMN userId TEXT DEFAULT ""');
        }
      },
    );
  }

  @override
  Future<List<TaskModel>> getTasks(String userId) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      tableName,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) {
      return TaskModel.fromJson(maps[i]);
    });
  }

  @override
  Future<void> cacheTask(TaskModel taskToCache) async {
    final dbClient = await db;
    await dbClient.insert(
      tableName,
      taskToCache.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateTask(TaskModel taskToUpdate) async {
    final dbClient = await db;
    await dbClient.update(
      tableName,
      taskToUpdate.toJson(),
      where: 'id = ?',
      whereArgs: [taskToUpdate.id],
    );
  }

  @override
  Future<void> deleteTask(String id) async {
    final dbClient = await db;
    await dbClient.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<TaskModel>> getUnsyncedTasks(String userId) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      tableName,
      where: 'isSynced = ? AND userId = ?',
      whereArgs: [0, userId],
    );
    return List.generate(maps.length, (i) {
      return TaskModel.fromJson(maps[i]);
    });
  }
}
