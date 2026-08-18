import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/usecases/usecase.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/sync_tasks.dart';

class TaskController extends GetxController {
  final GetTasks _getTasks = Get.find<GetTasks>();
  final AddTask _addTask = Get.find<AddTask>();
  final UpdateTask _updateTask = Get.find<UpdateTask>();
  final DeleteTask _deleteTask = Get.find<DeleteTask>();
  final SyncTasks _syncTasks = Get.find<SyncTasks>();

  var allTasks = <Task>[].obs;
  var isLoading = false.obs;

  var searchQuery = ''.obs;
  var filterStatus = 'All'.obs;
  var sortType = 'Due Date'.obs;

  var isDarkMode = Get.isDarkMode.obs;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    isLoading.value = true;
    try {
      final tasks = await _getTasks.call(NoParams());
      allTasks.assignAll(tasks);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch tasks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTask(Task task) async {
    await _addTask.call(task);
    await fetchTasks();
  }

  Future<void> updateTask(Task task) async {
    await _updateTask.call(task);
    await fetchTasks();
  }

  Future<void> deleteTask(String id) async {
    await _deleteTask.call(id);
    await fetchTasks();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(updatedTask);
  }

  Future<void> syncTasks() async {
    isLoading.value = true;
    try {
      await _syncTasks.call(NoParams());
      await fetchTasks();
    } finally {
      isLoading.value = false;
    }
  }

  List<Task> get filteredAndSortedTasks {
    List<Task> result = allTasks.toList();

    if (searchQuery.value.isNotEmpty) {
      result = result
          .where(
            (task) => task.title.toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ),
          )
          .toList();
    }

    if (filterStatus.value == 'Completed') {
      result = result.where((task) => task.isCompleted).toList();
    } else if (filterStatus.value == 'Pending') {
      result = result.where((task) => !task.isCompleted).toList();
    }

    if (sortType.value == 'Due Date') {
      result.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    } else if (sortType.value == 'Priority') {
      int priorityValue(String p) {
        switch (p.toLowerCase()) {
          case 'high':
            return 3;
          case 'medium':
            return 2;
          case 'low':
            return 1;
          default:
            return 0;
        }
      }

      result.sort((a, b) {
        return priorityValue(b.priority).compareTo(priorityValue(a.priority));
      });
    }

    return result;
  }
}
