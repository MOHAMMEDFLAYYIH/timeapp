import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../models/task_repository.dart';

/// TaskProvider manages task state using Provider pattern
///
/// This class extends ChangeNotifier to provide reactive state management.
/// It acts as the single source of truth for task data throughout the app.
///
/// Key responsibilities:
/// - Load and cache tasks from repository
/// - Provide CRUD operations for tasks
/// - Notify listeners of state changes
/// - Handle errors gracefully
class TaskProvider with ChangeNotifier {
  final TaskRepository _repository = TaskRepository();

  /// List of all tasks
  List<Task> _tasks = [];

  /// Loading state indicator
  bool _isLoading = false;

  /// Error message if any operation fails
  String? _error;

  /// Selected category filter (null = show all)
  String? _selectedCategoryId;

  /// Getters for read-only access to state
  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategoryId => _selectedCategoryId;

  /// Get only completed tasks
  List<Task> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();

  /// Get only pending (incomplete) tasks
  List<Task> get pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList();

  /// Get tasks filtered by selected category
  List<Task> get filteredTasks {
    if (_selectedCategoryId == null) {
      return tasks;
    }
    return _tasks
        .where((task) => task.categoryId == _selectedCategoryId)
        .toList();
  }

  /// Get filtered pending tasks
  List<Task> get filteredPendingTasks =>
      filteredTasks.where((task) => !task.isCompleted).toList();

  /// Get filtered completed tasks
  List<Task> get filteredCompletedTasks =>
      filteredTasks.where((task) => task.isCompleted).toList();

  /// Get task count statistics
  int get totalTaskCount => _tasks.length;
  int get completedTaskCount => completedTasks.length;
  int get pendingTaskCount => pendingTasks.length;

  /// Load all tasks from repository
  ///
  /// This should be called when the app starts or when data needs to be refreshed
  Future<void> loadTasks() async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.init();
      _tasks = await _repository.getAllTasks();

      // Sort tasks: pending first, then by created date (newest first)
      _tasks.sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        return b.createdAt.compareTo(a.createdAt);
      });

      notifyListeners();
    } catch (e) {
      _setError('Failed to load tasks: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new task
  ///
  /// [task] - The task to add
  /// Returns the added task with generated ID
  Future<Task?> addTask(Task task) async {
    _clearError();

    try {
      final addedTask = await _repository.addTask(task);
      _tasks.add(addedTask);
      _sortTasks();
      notifyListeners();
      return addedTask;
    } catch (e) {
      _setError('Failed to add task: $e');
      return null;
    }
  }

  /// Update an existing task
  ///
  /// [task] - The task with updated values
  Future<bool> updateTask(Task task) async {
    _clearError();

    try {
      await _repository.updateTask(task);

      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        _sortTasks();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update task: $e');
      return false;
    }
  }

  /// Delete a task
  ///
  /// [id] - The ID of the task to delete
  Future<bool> deleteTask(String id) async {
    _clearError();

    try {
      await _repository.deleteTask(id);
      _tasks.removeWhere((task) => task.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete task: $e');
      return false;
    }
  }

  /// Toggle task completion status
  ///
  /// [id] - The ID of the task to toggle
  Future<bool> toggleTaskCompletion(String id) async {
    _clearError();

    try {
      final updatedTask = await _repository.toggleTaskCompletion(id);

      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        _sortTasks();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to toggle task: $e');
      return false;
    }
  }

  /// Set category filter
  ///
  /// [categoryId] - The category ID to filter by, or null to show all
  void setCategoryFilter(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  /// Clear category filter
  void clearCategoryFilter() {
    _selectedCategoryId = null;
    notifyListeners();
  }

  /// Get tasks by category
  List<Task> getTasksByCategory(String categoryId) {
    return _tasks.where((task) => task.categoryId == categoryId).toList();
  }

  /// Sort tasks: pending first, then by created date (newest first)
  void _sortTasks() {
    _tasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }
}
