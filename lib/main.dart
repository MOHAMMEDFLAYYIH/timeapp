import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app_theme.dart';
import 'l10n/app_localizations.dart';
import 'providers/task_provider.dart';
import 'providers/category_provider.dart';
import 'providers/analytics_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'screens/web_not_supported_screen.dart';
import 'services/notification_service.dart';

/// Main entry point of the Task Manager application
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database factory for Desktop (Windows/Linux)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Set system UI overlay style
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // NOTE: Orientation lock removed to support landscape on tablets/desktop
  // On phones, the OS typically handles orientation based on sensor

  // Initialize Notification Service
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions();

  runApp(kIsWeb ? const WebNotSupportedScreen() : const TaskManagerApp());
}

/// Theme Mode Provider for managing light/dark theme
class ThemeModeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

/// Root application widget
class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme provider
        ChangeNotifierProvider(create: (_) => ThemeModeProvider()),

        // Settings provider
        ChangeNotifierProvider(create: (_) => SettingsProvider()),

        // Category provider (initialized first as tasks depend on categories)
        ChangeNotifierProvider(
          create: (_) => CategoryProvider()..loadCategories(),
        ),

        // Task provider
        ChangeNotifierProvider(create: (_) => TaskProvider()..loadTasks()),

        // Analytics provider (depends on tasks)
        ChangeNotifierProxyProvider<TaskProvider, AnalyticsProvider>(
          create: (_) => AnalyticsProvider(),
          update: (_, taskProvider, analyticsProvider) =>
              analyticsProvider!..updateAnalytics(taskProvider.tasks),
        ),
      ],
      child: Consumer2<ThemeModeProvider, SettingsProvider>(
        builder: (context, themeProvider, settingsProvider, _) {
          return MaterialApp(
            // App Configuration
            title: 'Task Manager',
            debugShowCheckedModeBanner: false,

            // Localization
            locale: settingsProvider.locale,
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              if (locale == null) return supportedLocales.first;
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },

            // Theme Configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // Home Screen
            home: const HomeScreen(),

            // Page Transitions
            builder: (context, child) {
              return MediaQuery(
                // Prevent text scaling beyond 1.2 for better layout
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    MediaQuery.of(
                      context,
                    ).textScaler.scale(1.0).clamp(0.8, 1.2),
                  ),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
