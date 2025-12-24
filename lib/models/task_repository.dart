import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'task_model.dart';
import '../app_theme.dart';

/// Repository for Task data access using Hive
///
/// This class provides an abstraction layer over Hive storage,
/// making it easy to switch to SQLite or other storage solutions later.
/// All data access goes through this repository following the
/// Repository Pattern for clean architecture.
class TaskRepository {
  late Box<Task> _taskBox;
  final Uuid _uuid = const Uuid();

  /// Initialize the task repository
  /// Opens the Hive box for tasks
  Future<void> init() async {
    _taskBox = await Hive.openBox<Task>(DatabaseConstants.tasksBox);
  }

  /// Get all tasks from storage
  /// Returns a list of all tasks, or empty list if none exist
  Future<List<Task>> getAllTasks() async {
    try {
      return _taskBox.values.toList();
    } catch (e) {
      throw Exception('Failed to load tasks: $e');
    }
  }

  /// Get tasks filtered by category
  ///
  /// [categoryId] - The ID of the category to filter by
  /// Returns list of tasks belonging to specified category
  Future<List<Task>> getTasksByCategory(String categoryId) async {
    try {
      return _taskBox.values
          .where((task) => task.categoryId == categoryId)
          .toList();
    } catch (e) {
      throw Exception('Failed to load tasks for category: $e');
    }
  }

  /// Get tasks within a date range
  ///
  /// [startDate] - Start of date range (inclusive)
  /// [endDate] - End of date range (inclusive)
  /// Returns list of tasks created within the date range
  Future<List<Task>> getTasksByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return _taskBox.values
          .where(
            (task) =>
                task.createdAt.isAfter(startDate) &&
                task.createdAt.isBefore(endDate),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to load tasks by date range: $e');
    }
  }

  /// Get tasks completed within a date range
  ///
  /// [startDate] - Start of date range (inclusive)
  /// [endDate] - End of date range (inclusive)
  /// Returns list of tasks completed within the date range
  Future<List<Task>> getCompletedTasksByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return _taskBox.values
          .where(
            (task) =>
                task.isCompleted &&
                task.completedAt != null &&
                task.completedAt!.isAfter(startDate) &&
                task.completedAt!.isBefore(endDate),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to load completed tasks by date range: $e');
    }
  }

  /// Add a new task to storage
  ///
  /// [task] - The task to add
  /// Returns the added task with generated ID
  Future<Task> addTask(Task task) async {
    try {
      // Generate ID if not provided
      final taskWithId = task.id.isEmpty ? task.copyWith(id: _uuid.v4()) : task;

      await _taskBox.put(taskWithId.id, taskWithId);
      return taskWithId;
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  /// Update an existing task
  ///
  /// [task] - The task with updated values
  /// Returns the updated task
  Future<Task> updateTask(Task task) async {
    try {
      if (!_taskBox.containsKey(task.id)) {
        throw Exception('Task with ID ${task.id} not found');
      }

      await _taskBox.put(task.id, task);
      return task;
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  /// Delete a task by ID
  ///
  /// [id] - The ID of the task to delete
  Future<void> deleteTask(String id) async {
    try {
      if (!_taskBox.containsKey(id)) {
        throw Exception('Task with ID $id not found');
      }

      await _taskBox.delete(id);
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  /// Toggle task completion status
  ///
  /// [id] - The ID of the task to toggle
  /// Returns the updated task
  Future<Task> toggleTaskCompletion(String id) async {
    try {
      final task = _taskBox.get(id);
      if (task == null) {
        throw Exception('Task with ID $id not found');
      }

      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        completedAt: !task.isCompleted ? DateTime.now() : null,
        clearCompletedAt: task.isCompleted,
      );

      await _taskBox.put(id, updatedTask);
      return updatedTask;
    } catch (e) {
      throw Exception('Failed to toggle task completion: $e');
    }
  }

  /// Get count of pending tasks
  Future<int> getPendingTaskCount() async {
    try {
      return _taskBox.values.where((task) => !task.isCompleted).length;
    } catch (e) {
      throw Exception('Failed to get pending task count: $e');
    }
  }

  /// Get count of completed tasks
  Future<int> getCompletedTaskCount() async {
    try {
      return _taskBox.values.where((task) => task.isCompleted).length;
    } catch (e) {
      throw Exception('Failed to get completed task count: $e');
    }
  }

  /// Delete all tasks (use with caution)
  Future<void> deleteAllTasks() async {
    try {
      await _taskBox.clear();
    } catch (e) {
      throw Exception('Failed to delete all tasks: $e');
    }
  }

  /// Close the repository and release resources
  Future<void> close() async {
    await _taskBox.close();
  }
}
