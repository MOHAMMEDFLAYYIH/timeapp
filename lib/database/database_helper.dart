import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';
import '../models/category_model.dart';

/// DatabaseHelper is a Singleton class that manages SQLite database operations
///
/// Usage:
/// ```dart
/// final db = DatabaseHelper.instance;
/// final tasks = await db.getTasks();
/// ```
class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // Database configuration
  static const String _databaseName = 'task_manager.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String tableTasks = 'tasks';
  static const String tableCategories = 'categories';

  // Private constructor
  DatabaseHelper._init();

  /// Get database instance (lazy initialization)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    // Web is not supported for this SQLite implementation
    if (kIsWeb) {
      throw UnsupportedError(
        'Web is not supported. Please run on Windows or Android.',
      );
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
    );
  }

  /// Create database tables
  Future<void> _createDb(Database db, int version) async {
    // Create tasks table
    await db.execute('''
      CREATE TABLE $tableTasks(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        categoryId TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        completedAt TEXT,
        dueDate TEXT,
        remindAt TEXT,
        hasReminder INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create indexes for faster queries
    await db.execute(
      'CREATE INDEX idx_tasks_category ON $tableTasks(categoryId)',
    );
    await db.execute(
      'CREATE INDEX idx_tasks_completed ON $tableTasks(isCompleted)',
    );
    await db.execute(
      'CREATE INDEX idx_tasks_created ON $tableTasks(createdAt)',
    );
    await db.execute('CREATE INDEX idx_tasks_due ON $tableTasks(dueDate)');

    // Create categories table
    await db.execute('''
      CREATE TABLE $tableCategories(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        colorValue INTEGER NOT NULL,
        iconCode INTEGER NOT NULL
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  /// Handle database upgrades
  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    // Add migration logic here for future versions
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE $tableTasks ADD COLUMN priority INTEGER DEFAULT 0');
    // }
  }

  /// Insert default categories
  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      {
        'id': 'work',
        'name': 'Work',
        'colorValue': 0xFF2563EB,
        'iconCode': 0xe8f9,
      },
      {
        'id': 'personal',
        'name': 'Personal',
        'colorValue': 0xFF7C3AED,
        'iconCode': 0xe491,
      },
      {
        'id': 'shopping',
        'name': 'Shopping',
        'colorValue': 0xFF10B981,
        'iconCode': 0xe59c,
      },
      {
        'id': 'health',
        'name': 'Health',
        'colorValue': 0xFFEF4444,
        'iconCode': 0xe3e1,
      },
    ];

    for (final category in defaultCategories) {
      await db.insert(tableCategories, category);
    }
  }

  // ===========================================================================
  // TASK CRUD OPERATIONS
  // ===========================================================================

  /// Insert a new task
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert(
      tableTasks,
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all tasks
  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableTasks);
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  /// Get a single task by ID
  Future<Task?> getTaskById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableTasks,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Task.fromMap(maps.first);
  }

  /// Get tasks by category ID
  Future<List<Task>> getTasksByCategory(String categoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableTasks,
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  /// Get tasks within a date range (by createdAt)
  Future<List<Task>> getTasksByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableTasks,
      where: 'createdAt >= ? AND createdAt <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  /// Get completed tasks within a date range (by completedAt)
  Future<List<Task>> getCompletedTasksByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableTasks,
      where: 'isCompleted = 1 AND completedAt >= ? AND completedAt <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  /// Update an existing task
  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      tableTasks,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// Delete a task
  Future<int> deleteTask(String id) async {
    final db = await database;
    return await db.delete(tableTasks, where: 'id = ?', whereArgs: [id]);
  }

  /// Delete all tasks
  Future<int> deleteAllTasks() async {
    final db = await database;
    return await db.delete(tableTasks);
  }

  /// Get pending task count
  Future<int> getPendingTaskCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableTasks WHERE isCompleted = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get completed task count
  Future<int> getCompletedTaskCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableTasks WHERE isCompleted = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ===========================================================================
  // CATEGORY CRUD OPERATIONS
  // ===========================================================================

  /// Insert a new category
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert(
      tableCategories,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all categories
  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableCategories);
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  /// Get a single category by ID
  Future<Category?> getCategoryById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  /// Update an existing category
  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      tableCategories,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Delete a category
  Future<int> deleteCategory(String id) async {
    final db = await database;
    return await db.delete(tableCategories, where: 'id = ?', whereArgs: [id]);
  }

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  /// Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Check if a task exists
  Future<bool> taskExists(String id) async {
    final task = await getTaskById(id);
    return task != null;
  }

  /// Check if a category exists
  Future<bool> categoryExists(String id) async {
    final category = await getCategoryById(id);
    return category != null;
  }
}
