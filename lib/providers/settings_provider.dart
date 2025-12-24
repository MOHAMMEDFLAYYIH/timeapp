import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../app_theme.dart';

/// Settings Provider for managing app settings
class SettingsProvider extends ChangeNotifier {
  late Box _settingsBox;

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
    _settingsBox = await Hive.openBox(DatabaseConstants.settingsBox);
    _loadSettings();
  }

  void _loadSettings() {
    final langCode = _settingsBox.get('languageCode', defaultValue: 'en');
    _locale = Locale(langCode);
    _userName = _settingsBox.get('userName', defaultValue: 'User Name');
    _userEmail = _settingsBox.get(
      'userEmail',
      defaultValue: 'user@example.com',
    );
    notifyListeners();
  }

  // Set language
  Future<void> setLanguage(Locale locale) async {
    _locale = locale;
    await _settingsBox.put('languageCode', locale.languageCode);
    notifyListeners();
  }

  // Update user profile
  Future<void> updateProfile({String? name, String? email}) async {
    if (name != null) {
      _userName = name;
      await _settingsBox.put('userName', name);
    }
    if (email != null) {
      _userEmail = email;
      await _settingsBox.put('userEmail', email);
    }
    notifyListeners();
  }
}
