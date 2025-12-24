import 'package:flutter/foundation.dart';
import '../models/category_model.dart' as models;
import '../models/category_repository.dart';

/// CategoryProvider manages category state using Provider pattern
///
/// This class extends ChangeNotifier to provide reactive state management.
/// It manages all category-related data and operations.
class CategoryProvider with ChangeNotifier {
  final CategoryRepository _repository = CategoryRepository();

  /// List of all categories
  List<models.Category> _categories = [];

  /// Loading state indicator
  bool _isLoading = false;

  /// Error message if any operation fails
  String? _error;

  /// Getters for read-only access to state
  List<models.Category> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get category count
  int get categoryCount => _categories.length;

  /// Load all categories from repository
  ///
  /// This should be called when the app starts
  /// The repository will auto-seed default categories if none exist
  Future<void> loadCategories() async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.init();
      _categories = await _repository.getAllCategories();

      // Sort categories alphabetically
      _categories.sort((a, b) => a.name.compareTo(b.name));

      notifyListeners();
    } catch (e) {
      _setError('Failed to load categories: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get a category by ID
  ///
  /// [id] - The category ID
  /// Returns the category or null if not found
  models.Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add a new category
  ///
  /// [category] - The category to add
  /// Returns the added category with generated ID
  Future<models.Category?> addCategory(models.Category category) async {
    _clearError();

    try {
      // Check if name already exists
      final nameExists = await _repository.categoryNameExists(category.name);
      if (nameExists) {
        _setError('A category with this name already exists');
        return null;
      }

      final addedCategory = await _repository.addCategory(category);
      _categories.add(addedCategory);
      _sortCategories();
      notifyListeners();
      return addedCategory;
    } catch (e) {
      _setError('Failed to add category: $e');
      return null;
    }
  }

  /// Update an existing category
  ///
  /// [category] - The category with updated values
  Future<bool> updateCategory(models.Category category) async {
    _clearError();

    try {
      // Check if new name conflicts with existing categories
      final nameExists = await _repository.categoryNameExists(
        category.name,
        excludeId: category.id,
      );
      if (nameExists) {
        _setError('A category with this name already exists');
        return false;
      }

      await _repository.updateCategory(category);

      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        _sortCategories();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update category: $e');
      return false;
    }
  }

  /// Delete a category
  ///
  /// [id] - The ID of the category to delete
  /// Note: This should only be called if no tasks use this category
  Future<bool> deleteCategory(String id) async {
    _clearError();

    try {
      await _repository.deleteCategory(id);
      _categories.removeWhere((cat) => cat.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete category: $e');
      return false;
    }
  }

  /// Check if a category can be safely deleted
  ///
  /// [id] - The category ID
  /// [taskCount] - Number of tasks using this category
  /// Returns true if it's safe to delete (no tasks use it)
  bool canDeleteCategory(String id, int taskCount) {
    return taskCount == 0;
  }

  /// Sort categories alphabetically
  void _sortCategories() {
    _categories.sort((a, b) => a.name.compareTo(b.name));
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
