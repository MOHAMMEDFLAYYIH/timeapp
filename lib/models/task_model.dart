/// Task model representing a to-do item
///
/// This is a plain Dart class used for SQLite persistence.
/// Use [toMap] to convert for database storage and
/// [fromMap] factory constructor to create from database data.
class Task {
  final String id;
  final String title;
  final String? description;
  final String categoryId;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? dueDate;
  final DateTime? remindAt;
  final bool hasReminder;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.categoryId,
    required this.isCompleted,
    required this.createdAt,
    this.completedAt,
    this.dueDate,
    this.remindAt,
    this.hasReminder = false,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    DateTime? dueDate,
    DateTime? remindAt,
    bool? hasReminder,
    bool clearRemindAt = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      dueDate: dueDate ?? this.dueDate,
      remindAt: clearRemindAt ? null : (remindAt ?? this.remindAt),
      hasReminder: hasReminder ?? this.hasReminder,
    );
  }

  /// Convert to Map for SQLite storage
  /// Booleans are converted to 0/1
  /// DateTime values are converted to ISO 8601 strings
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'remindAt': remindAt?.toIso8601String(),
      'hasReminder': hasReminder ? 1 : 0,
    };
  }

  /// Create Task from SQLite Map data
  /// Parses integers as booleans (0/1)
  /// Parses ISO 8601 strings as DateTime
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      categoryId: map['categoryId'] as String,
      isCompleted: (map['isCompleted'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      remindAt: map['remindAt'] != null
          ? DateTime.parse(map['remindAt'] as String)
          : null,
      hasReminder: (map['hasReminder'] as int?) == 1,
    );
  }
}
