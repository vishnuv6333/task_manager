import 'package:get/get.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

class TaskController extends GetxController {
  final TaskRepository _repository = Get.find<TaskRepository>();

  var allTasks = <Task>[].obs;
  var isLoading = false.obs;

  var searchQuery = ''.obs;
  var filterStatus = 'All'.obs; // 'All', 'Pending', 'Completed'
  var sortType = 'Due Date'.obs; // 'Due Date', 'Priority'

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    isLoading.value = true;
    try {
      final tasks = await _repository.getTasks();
      allTasks.assignAll(tasks);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch tasks: \$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTask(Task task) async {
    await _repository.addTask(task);
    await fetchTasks();
  }

  Future<void> updateTask(Task task) async {
    await _repository.updateTask(task);
    await fetchTasks();
  }

  Future<void> deleteTask(String id) async {
    await _repository.deleteTask(id);
    await fetchTasks();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(updatedTask);
  }

  Future<void> syncTasks() async {
    isLoading.value = true;
    try {
      await _repository.syncPendingTasks();
      await fetchTasks();
    } finally {
      isLoading.value = false;
    }
  }

  List<Task> get filteredAndSortedTasks {
    List<Task> result = allTasks.toList();

    // 1. Search Filter
    if (searchQuery.value.isNotEmpty) {
      result = result
          .where((task) =>
              task.title.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    // 2. Status Filter
    if (filterStatus.value == 'Completed') {
      result = result.where((task) => task.isCompleted).toList();
    } else if (filterStatus.value == 'Pending') {
      result = result.where((task) => !task.isCompleted).toList();
    }

    // 3. Sort
    if (sortType.value == 'Due Date') {
      result.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1; // nulls last
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
