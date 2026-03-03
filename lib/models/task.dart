import 'dart:convert';

enum Priority { low, medium, high }

class Task {
  String id;
  String title;
  String? description;
  Priority priority;
  String category;
  bool isCompleted;
  DateTime createdAt;
  DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.priority = Priority.medium,
    this.category = 'General',
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    Priority? priority,
    String? category,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
    bool clearDueDate = false,
    bool clearDescription = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'priority': priority.index,
    'category': category,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    priority: Priority.values[json['priority'] as int],
    category: json['category'] as String? ?? 'General',
    isCompleted: json['isCompleted'] as bool,
    createdAt: DateTime.parse(json['createdAt'] as String),
    dueDate: json['dueDate'] != null
        ? DateTime.parse(json['dueDate'] as String)
        : null,
  );

  static String encode(List<Task> tasks) =>
      json.encode(tasks.map((t) => t.toJson()).toList());

  static List<Task> decode(String source) => (json.decode(source) as List)
      .map((item) => Task.fromJson(item as Map<String, dynamic>))
      .toList();
}
