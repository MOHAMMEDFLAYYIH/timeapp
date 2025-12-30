import 'package:uuid/uuid.dart';
import 'category_model.dart';
import '../database/database_helper.dart';

/// Repository for Category data access using SQLite
class CategoryRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  /// Initialize the category repository
  /// Default categories are seeded in DatabaseHelper._createDb
  Future<void> init() async {
    // Trigger database initialization by accessing it
    await _db.database;
  }

  /// Get all categories from storage
  Future<List<Category>> getAllCategories() async {
    try {
      return await _db.getCategories();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  /// Get a single category by ID
  Future<Category?> getCategoryById(String id) async {
    try {
      return await _db.getCategoryById(id);
    } catch (e) {
      throw Exception('Failed to get category: $e');
    }
  }

  /// Add a new category
  Future<Category> addCategory(Category category) async {
    try {
      final categoryWithId = category.id.isEmpty
          ? category.copyWith(id: _uuid.v4())
          : category;

      await _db.insertCategory(categoryWithId);
      return categoryWithId;
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  /// Update an existing category
  Future<Category> updateCategory(Category category) async {
    try {
      final exists = await _db.categoryExists(category.id);
      if (!exists) {
        throw Exception('Category with ID ${category.id} not found');
      }

      await _db.updateCategory(category);
      return category;
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  /// Delete a category by ID
  Future<void> deleteCategory(String id) async {
    try {
      final exists = await _db.categoryExists(id);
      if (!exists) {
        throw Exception('Category with ID $id not found');
      }

      await _db.deleteCategory(id);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  /// Check if a category name already exists
  Future<bool> categoryNameExists(String name, {String? excludeId}) async {
    try {
      final categories = await _db.getCategories();
      return categories.any(
        (category) =>
            category.name.toLowerCase() == name.toLowerCase() &&
            category.id != excludeId,
      );
    } catch (e) {
      throw Exception('Failed to check category name: $e');
    }
  }

  /// Get category count
  Future<int> getCategoryCount() async {
    try {
      final categories = await _db.getCategories();
      return categories.length;
    } catch (e) {
      throw Exception('Failed to get category count: $e');
    }
  }

  /// Delete all categories
  Future<void> deleteAllCategories() async {
    try {
      final categories = await _db.getCategories();
      for (final category in categories) {
        await _db.deleteCategory(category.id);
      }
    } catch (e) {
      throw Exception('Failed to delete all categories: $e');
    }
  }

  /// Close the repository
  Future<void> close() async {
    await _db.close();
  }
}
