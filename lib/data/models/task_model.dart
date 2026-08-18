import '../../domain/entities/task.dart';

class TaskModel extends Task {
  TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.priority,
    super.dueDate,
    super.isCompleted,
    required super.createdAt,
    super.isSynced,
    required super.userId,
  });

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      priority: task.priority,
      dueDate: task.dueDate,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
      isSynced: task.isSynced,
      userId: task.userId,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      priority: json['priority'] as String,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      isCompleted: json['isCompleted'] == 1 || json['isCompleted'] == true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isSynced: json['isSynced'] == 1 || json['isSynced'] == true,
      userId: json['userId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
      'userId': userId,
    };
  }
}
