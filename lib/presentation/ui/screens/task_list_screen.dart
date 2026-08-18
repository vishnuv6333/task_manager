import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/auth_controller.dart';
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
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isDarkMode.value
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () => controller.toggleTheme(),
              tooltip: 'Toggle Theme',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => controller.syncTasks(),
            tooltip: 'Sync with Cloud',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Get.find<AuthController>().logout(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
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
                    const SizedBox(height: 8),
                    // Sort Type
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.sort, size: 18, color: Colors.grey),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Due Date'),
                            selected: controller.sortType.value == 'Due Date',
                            onSelected: (selected) {
                              if (selected) controller.sortType.value = 'Due Date';
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Priority'),
                            selected: controller.sortType.value == 'Priority',
                            onSelected: (selected) {
                              if (selected) controller.sortType.value = 'Priority';
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.allTasks.isEmpty) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Shimmer.fromColors(
                        baseColor: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade300,
                        highlightColor: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade100,
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    );
                  },
                );
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
                        Get.snackbar('Deleted', '${task.title} deleted.');
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
