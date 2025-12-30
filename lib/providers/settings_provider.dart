import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path_lib;

/// Settings Provider for managing app settings using SQLite
class SettingsProvider extends ChangeNotifier {
  Database? _db;

  // Settings state
  Locale _locale = const Locale('en');
  String _userName = 'User Name';
  String _userEmail = 'user@example.com';

  // Getters
  Locale get locale => _locale;
  String get userName => _userName;
  String get userEmail => _userEmail;

  SettingsProvider() {
    _initSettings();
  }

  Future<void> _initSettings() async {
    final dbPath = await getDatabasesPath();
    final settingsPath = path_lib.join(dbPath, 'settings.db');

    _db = await openDatabase(
      settingsPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE settings(
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );

    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    if (_db == null) return;

    final langResult = await _db!.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['languageCode'],
    );
    if (langResult.isNotEmpty) {
      _locale = Locale(langResult.first['value'] as String);
    }

    final nameResult = await _db!.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['userName'],
    );
    if (nameResult.isNotEmpty) {
      _userName = nameResult.first['value'] as String;
    }

    final emailResult = await _db!.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['userEmail'],
    );
    if (emailResult.isNotEmpty) {
      _userEmail = emailResult.first['value'] as String;
    }

    notifyListeners();
  }

  Future<void> _saveSetting(String key, String value) async {
    if (_db == null) return;
    await _db!.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Set language
  Future<void> setLanguage(Locale locale) async {
    _locale = locale;
    await _saveSetting('languageCode', locale.languageCode);
    notifyListeners();
  }

  // Update user profile
  Future<void> updateProfile({String? name, String? email}) async {
    if (name != null) {
      _userName = name;
      await _saveSetting('userName', name);
    }
    if (email != null) {
      _userEmail = email;
      await _saveSetting('userEmail', email);
    }
    notifyListeners();
  }
}
