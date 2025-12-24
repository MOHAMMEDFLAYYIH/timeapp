import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'category_model.dart';
import '../app_theme.dart';

/// Repository for Category data access using Hive
class CategoryRepository {
  late Box<Category> _categoryBox;
  final Uuid _uuid = const Uuid();

  /// Initialize the category repository
  Future<void> init() async {
    _categoryBox = await Hive.openBox<Category>(
      DatabaseConstants.categoriesBox,
    );

    // Seed default categories if box is empty
    if (_categoryBox.isEmpty) {
      await _seedDefaultCategories();
    }
  }

  /// Seed default categories on first run
  Future<void> _seedDefaultCategories() async {
    final defaultCategories = [
      Category(
        id: _uuid.v4(),
        name: 'Work',
        colorValue: 0xFF2563EB,
        iconCode: Icons.work_outline.codePoint,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Personal',
        colorValue: 0xFF7C3AED,
        iconCode: Icons.person_outline.codePoint,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Shopping',
        colorValue: 0xFF10B981,
        iconCode: Icons.shopping_cart_outlined.codePoint,
      ),
      Category(
        id: _uuid.v4(),
        name: 'Health',
        colorValue: 0xFFEF4444,
        iconCode: Icons.favorite_border.codePoint,
      ),
    ];

    for (final category in defaultCategories) {
      await _categoryBox.put(category.id, category);
    }
  }

  /// Get all categories from storage
  Future<List<Category>> getAllCategories() async {
    try {
      return _categoryBox.values.toList();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  /// Get a single category by ID
  Future<Category?> getCategoryById(String id) async {
    try {
      return _categoryBox.get(id);
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

      await _categoryBox.put(categoryWithId.id, categoryWithId);
      return categoryWithId;
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  /// Update an existing category
  Future<Category> updateCategory(Category category) async {
    try {
      if (!_categoryBox.containsKey(category.id)) {
        throw Exception('Category with ID ${category.id} not found');
      }

      await _categoryBox.put(category.id, category);
      return category;
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  /// Delete a category by ID
  Future<void> deleteCategory(String id) async {
    try {
      if (!_categoryBox.containsKey(id)) {
        throw Exception('Category with ID $id not found');
      }

      await _categoryBox.delete(id);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  /// Check if a category name already exists
  Future<bool> categoryNameExists(String name, {String? excludeId}) async {
    try {
      return _categoryBox.values.any(
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
      return _categoryBox.length;
    } catch (e) {
      throw Exception('Failed to get category count: $e');
    }
  }

  /// Delete all categories
  Future<void> deleteAllCategories() async {
    try {
      await _categoryBox.clear();
    } catch (e) {
      throw Exception('Failed to delete all categories: $e');
    }
  }

  /// Close the repository
  Future<void> close() async {
    await _categoryBox.close();
  }
}
