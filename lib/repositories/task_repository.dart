import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/task_model.dart';
import '../data/local_db_helper.dart';
import '../data/firestore_helper.dart';

class TaskRepository {
  final LocalDBHelper _localDBHelper = LocalDBHelper();
  final FirestoreHelper _firestoreHelper = FirestoreHelper();

  Future<List<Task>> getTasks() async {
    // 1. Fetch from local DB first for offline-first experience
    final localTasks = await _localDBHelper.getTasks();
    
    // 2. If online, try to fetch from remote and update local
    if (await _isOnline()) {
      try {
        final remoteTasks = await _firestoreHelper.getAllTasks();
        
        // Merge strategy: for simplicity, we assume remote is truth if synced, 
        // but we should not overwrite unsynced local changes.
        // A robust sync strategy would involve conflict resolution, but here we'll
        // sync unsynced local tasks to remote, then pull all remote.
        await _syncLocalToRemote();
        
        // After sync, remote is the source of truth, but we keep local updated.
        // For simple offline-first, if we pull everything, we might overwrite.
        // Let's stick to a simpler strategy: Local is source of truth. We just push to remote.
        // If we wanted multi-device sync, we'd need timestamps and a more complex merge.
      } catch (e) {
        print("Error fetching from remote: \$e");
      }
    }
    
    return _localDBHelper.getTasks();
  }

  Future<void> addTask(Task task) async {
    final isOnline = await _isOnline();
    Task taskToSave = task.copyWith(isSynced: isOnline);
    
    // Always save to local DB first
    await _localDBHelper.insertTask(taskToSave);
    
    if (isOnline) {
      try {
        await _firestoreHelper.addTask(taskToSave);
      } catch (e) {
        print("Failed to add to remote, setting isSynced to false");
        await _localDBHelper.updateTask(taskToSave.copyWith(isSynced: false));
      }
    }
  }

  Future<void> updateTask(Task task) async {
    final isOnline = await _isOnline();
    Task taskToSave = task.copyWith(isSynced: isOnline);
    
    await _localDBHelper.updateTask(taskToSave);
    
    if (isOnline) {
      try {
        await _firestoreHelper.updateTask(taskToSave);
      } catch (e) {
        print("Failed to update to remote, setting isSynced to false");
        await _localDBHelper.updateTask(taskToSave.copyWith(isSynced: false));
      }
    }
  }

  Future<void> deleteTask(String id) async {
    // For delete, we remove locally. If offline, it's removed locally but remains on remote.
    // A robust offline delete requires soft-deletes (isDeleted flag). 
    // For this simple implementation, we will just attempt to delete.
    await _localDBHelper.deleteTask(id);
    
    if (await _isOnline()) {
      try {
        await _firestoreHelper.deleteTask(id);
      } catch (e) {
        print("Failed to delete from remote");
      }
    }
  }

  Future<void> syncPendingTasks() async {
    if (await _isOnline()) {
      await _syncLocalToRemote();
    }
  }

  Future<void> _syncLocalToRemote() async {
    final unsyncedTasks = await _localDBHelper.getUnsyncedTasks();
    for (var task in unsyncedTasks) {
      try {
        // We assume it's an upsert on Firestore (set with merge or just set)
        await _firestoreHelper.addTask(task);
        // Mark as synced locally
        await _localDBHelper.updateTask(task.copyWith(isSynced: true));
      } catch (e) {
        print("Failed to sync task \${task.id}");
      }
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
