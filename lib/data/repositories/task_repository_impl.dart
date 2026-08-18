import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/task_model.dart';
import '../datasources/task_local_data_source.dart';
import '../datasources/task_remote_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  TaskRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.authRepository,
  });

  Future<String> _getUserId() async {
    final user = await authRepository.getCurrentUser();
    if (user == null) throw Exception('User not logged in');
    return user.id;
  }

  @override
  Future<List<Task>> getTasks() async {
    final userId = await _getUserId();
    if (await _isOnline()) {
      try {
        await _syncLocalToRemote(userId);
      } catch (e) {}
    }
    return localDataSource.getTasks(userId);
  }

  @override
  Future<void> addTask(Task task) async {
    final userId = await _getUserId();
    final isOnline = await _isOnline();
    Task taskToSave = task.copyWith(isSynced: isOnline, userId: userId);
    final taskModel = TaskModel.fromEntity(taskToSave);

    await localDataSource.cacheTask(taskModel);

    if (isOnline) {
      try {
        await remoteDataSource.addTask(userId, taskModel);
      } catch (e) {
        await localDataSource.updateTask(
          TaskModel.fromEntity(taskToSave.copyWith(isSynced: false)),
        );
      }
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    final userId = await _getUserId();
    final isOnline = await _isOnline();
    Task taskToSave = task.copyWith(isSynced: isOnline, userId: userId);
    final taskModel = TaskModel.fromEntity(taskToSave);

    await localDataSource.updateTask(taskModel);

    if (isOnline) {
      try {
        await remoteDataSource.updateTask(userId, taskModel);
      } catch (e) {
        await localDataSource.updateTask(
          TaskModel.fromEntity(taskToSave.copyWith(isSynced: false)),
        );
      }
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    final userId = await _getUserId();
    await localDataSource.deleteTask(id);
    if (await _isOnline()) {
      try {
        await remoteDataSource.deleteTask(userId, id);
        // ignore: empty_catches
      } catch (e) {}
    }
  }

  @override
  Future<void> syncTasks() async {
    final userId = await _getUserId();
    if (await _isOnline()) {
      await _syncLocalToRemote(userId);
    }
  }

  Future<void> _syncLocalToRemote(String userId) async {
    final unsyncedTasks = await localDataSource.getUnsyncedTasks(userId);
    for (var taskModel in unsyncedTasks) {
      try {
        await remoteDataSource.addTask(userId, taskModel);
        await localDataSource.updateTask(
          TaskModel.fromEntity(taskModel.copyWith(isSynced: true)),
        );
      } catch (e) {}
    }
  }

  Future<bool> _isOnline() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.ethernet)) {
      return true;
    }
    return false;
  }
}
