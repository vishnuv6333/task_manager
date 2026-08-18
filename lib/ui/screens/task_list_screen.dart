import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/task_controller.dart';
import '../widgets/task_tile.dart';
import 'add_edit_task_screen.dart';
import 'task_details_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController controller = Get.find<TaskController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => controller.syncTasks(),
            tooltip: 'Sync with Cloud',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => controller.searchQuery.value = val,
                  decoration: const InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Filter Status
                    Obx(
                      () => DropdownButton<String>(
                        value: controller.filterStatus.value,
                        underline: const SizedBox(),
                        items: ['All', 'Pending', 'Completed']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            controller.filterStatus.value = val;
                          }
                        },
                      ),
                    ),
                    // Sort Type
                    Obx(
                      () => DropdownButton<String>(
                        value: controller.sortType.value,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.sort),
                        items: ['Due Date', 'Priority']
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text('Sort: \$e'),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            controller.sortType.value = val;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Task List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.allTasks.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final tasks = controller.filteredAndSortedTasks;

              if (tasks.isEmpty) {
                return const Center(
                  child: Text('No tasks found. Add a new one!'),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchTasks,
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskTile(
                      task: task,
                      onTap: () {
                        Get.to(() => TaskDetailsScreen(task: task));
                      },
                      onToggleCompletion: (val) {
                        controller.toggleTaskCompletion(task);
                      },
                      onDelete: () {
                        controller.deleteTask(task.id);
                        Get.snackbar('Deleted', '\${task.title} deleted.');
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddEditTaskScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
