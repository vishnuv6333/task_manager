class Task {
  final String id;
  final String title;
  final String description;
  final String priority;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  final bool isSynced;
  final String userId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    this.dueDate,
    this.isCompleted = false,
    required this.createdAt,
    this.isSynced = false,
    required this.userId,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? priority,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
    bool? isSynced,
    String? userId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      userId: userId ?? this.userId,
    );
  }
}
