import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/task_model.dart';
import '../../controllers/task_controller.dart';
import 'add_edit_task_screen.dart';

class TaskDetailsScreen extends StatelessWidget {
  final Task task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final TaskController controller = Get.find<TaskController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Get.to(() => AddEditTaskScreen(task: task));
            },
            tooltip: 'Edit Task',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Confirm delete dialog could be added here
              controller.deleteTask(task.id);
              Get.back();
              Get.snackbar('Deleted', 'Task has been deleted.');
            },
            tooltip: 'Delete Task',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Obx(() {
                  // We need to fetch the updated task if it was modified.
                  // For simplicity, we can rely on the fact that GetX state updates
                  // will rebuild if we listen to the specific item, but we are passing static task.
                  // To fix this, we can find the task from the controller.
                  final currentTask = controller.allTasks.firstWhere(
                    (t) => t.id == task.id,
                    orElse: () => task,
                  );

                  return Checkbox(
                    value: currentTask.isCompleted,
                    onChanged: (val) {
                      controller.toggleTaskCompletion(currentTask);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
                const Text('Mark as Completed', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 24),
            Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.flag, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Priority: \${task.priority}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 24),
                const Icon(Icons.cloud_sync, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  task.isSynced ? 'Synced' : 'Offline',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (task.dueDate != null)
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Due: \${DateFormat.yMMMd().format(task.dueDate!)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            const SizedBox(height: 32),
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              task.description.isEmpty
                  ? 'No description provided.'
                  : task.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),
            Text(
              'Created on: \${DateFormat.yMMMd().add_jm().format(task.createdAt)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
