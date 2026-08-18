import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class FirestoreHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'tasks';

  Future<void> addTask(Task task) async {
    // Exclude isSynced from firestore
    final data = task.toJson();
    data.remove('isSynced');
    await _firestore.collection(collectionName).doc(task.id).set(data);
  }

  Future<void> updateTask(Task task) async {
    final data = task.toJson();
    data.remove('isSynced');
    await _firestore.collection(collectionName).doc(task.id).update(data);
  }

  Future<void> deleteTask(String id) async {
    await _firestore.collection(collectionName).doc(id).delete();
  }

  Future<List<Task>> getAllTasks() async {
    final snapshot = await _firestore.collection(collectionName).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      // Firestore does not store isSynced, default it to true when fetching from remote
      data['isSynced'] = 1;
      return Task.fromJson(data);
    }).toList();
  }
}
