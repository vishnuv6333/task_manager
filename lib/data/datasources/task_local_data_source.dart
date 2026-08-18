import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks(String userId);
  Future<void> cacheTask(TaskModel taskToCache);
  Future<void> updateTask(TaskModel taskToUpdate);
  Future<void> deleteTask(String id);
  Future<void> hardDeleteTask(String id);
  Future<List<TaskModel>> getUnsyncedTasks(String userId);
  Future<void> upsertTask(TaskModel task);
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
      version: 3,
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
            updatedAt TEXT NOT NULL,
            isDeleted INTEGER NOT NULL DEFAULT 0,
            isSynced INTEGER NOT NULL,
            userId TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE $tableName ADD COLUMN userId TEXT DEFAULT ""');
        }
        if (oldVersion < 3) {
          // Add new columns with defaults so existing data isn't broken
          await db.execute("ALTER TABLE $tableName ADD COLUMN updatedAt TEXT DEFAULT ''");
          await db.execute('ALTER TABLE $tableName ADD COLUMN isDeleted INTEGER DEFAULT 0');
          // For legacy rows, make updatedAt equal to createdAt
          await db.execute('UPDATE $tableName SET updatedAt = createdAt WHERE updatedAt = ""');
        }
      },
    );
  }

  @override
  Future<List<TaskModel>> getTasks(String userId) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      tableName,
      where: 'userId = ? AND isDeleted = ?',
      whereArgs: [userId, 0],
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
  Future<void> upsertTask(TaskModel task) async {
    final dbClient = await db;
    await dbClient.insert(
      tableName,
      task.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteTask(String id) async {
    // Soft delete: keep the row, mark isDeleted=1 and isSynced=0 so it gets pushed.
    final dbClient = await db;
    await dbClient.update(
      tableName,
      {
        'isDeleted': 1,
        'isSynced': 0,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> hardDeleteTask(String id) async {
    // Physically remove the row after syncing the deletion to the cloud
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
