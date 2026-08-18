import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getAllTasks(String userId);
  Future<void> addTask(String userId, TaskModel task);
  Future<void> updateTask(String userId, TaskModel task);
  Future<void> deleteTask(String userId, String id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore _firestore;

  TaskRemoteDataSourceImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference _getUserTasksCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  @override
  Future<void> addTask(String userId, TaskModel task) async {
    final data = task.toJson();
    data.remove('isSynced');
    await _getUserTasksCollection(userId).doc(task.id).set(data);
  }

  @override
  Future<void> updateTask(String userId, TaskModel task) async {
    final data = task.toJson();
    data.remove('isSynced');
    await _getUserTasksCollection(userId).doc(task.id).update(data);
  }

  @override
  Future<void> deleteTask(String userId, String id) async {
    await _getUserTasksCollection(userId).doc(id).delete();
  }

  @override
  Future<List<TaskModel>> getAllTasks(String userId) async {
    final snapshot = await _getUserTasksCollection(userId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['isSynced'] = 1;
      return TaskModel.fromJson(data);
    }).toList();
  }
}
