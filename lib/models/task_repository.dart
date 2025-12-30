import 'package:uuid/uuid.dart';
import 'task_model.dart';
import '../database/database_helper.dart';

/// Repository for Task data access using SQLite
///
/// This class provides an abstraction layer over SQLite storage,
/// using the DatabaseHelper singleton for all database operations.
/// All data access goes through this repository following the
/// Repository Pattern for clean architecture.
class TaskRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  /// Initialize the task repository
  /// Opens/initializes the SQLite database
  Future<void> init() async {
    // Trigger database initialization by accessing it
    await _db.database;
  }

  /// Get all tasks from storage
  /// Returns a list of all tasks, or empty list if none exist
  Future<List<Task>> getAllTasks() async {
    try {
      return await _db.getTasks();
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
      return await _db.getTasksByCategory(categoryId);
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
      return await _db.getTasksByDateRange(startDate, endDate);
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
      return await _db.getCompletedTasksByDateRange(startDate, endDate);
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

      await _db.insertTask(taskWithId);
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
      final exists = await _db.taskExists(task.id);
      if (!exists) {
        throw Exception('Task with ID ${task.id} not found');
      }

      await _db.updateTask(task);
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
      final exists = await _db.taskExists(id);
      if (!exists) {
        throw Exception('Task with ID $id not found');
      }

      await _db.deleteTask(id);
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
      final task = await _db.getTaskById(id);
      if (task == null) {
        throw Exception('Task with ID $id not found');
      }

      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        completedAt: !task.isCompleted ? DateTime.now() : null,
        clearCompletedAt: task.isCompleted,
      );

      await _db.updateTask(updatedTask);
      return updatedTask;
    } catch (e) {
      throw Exception('Failed to toggle task completion: $e');
    }
  }

  /// Get count of pending tasks
  Future<int> getPendingTaskCount() async {
    try {
      return await _db.getPendingTaskCount();
    } catch (e) {
      throw Exception('Failed to get pending task count: $e');
    }
  }

  /// Get count of completed tasks
  Future<int> getCompletedTaskCount() async {
    try {
      return await _db.getCompletedTaskCount();
    } catch (e) {
      throw Exception('Failed to get completed task count: $e');
    }
  }

  /// Delete all tasks (use with caution)
  Future<void> deleteAllTasks() async {
    try {
      await _db.deleteAllTasks();
    } catch (e) {
      throw Exception('Failed to delete all tasks: $e');
    }
  }

  /// Close the repository and release resources
  Future<void> close() async {
    await _db.close();
  }
}
