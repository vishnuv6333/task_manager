class Task {
  final String id;
  final String title;
  final String description;
  final String priority; // e.g., 'Low', 'Medium', 'High'
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  final bool isSynced;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    this.dueDate,
    this.isCompleted = false,
    required this.createdAt,
    this.isSynced = false,
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
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      priority: json['priority'] as String,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      // Handle boolean conversion from SQLite (1 or 0) or Firestore (bool)
      isCompleted: json['isCompleted'] == 1 || json['isCompleted'] == true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isSynced: json['isSynced'] == 1 || json['isSynced'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      // Use 1/0 for booleans to make it easier for SQLite. Firestore can handle ints,
      // or we can convert them back to bools in the repository.
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }
}
