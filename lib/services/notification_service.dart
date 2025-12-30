import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/task_model.dart';

/// Singleton service for managing local push notifications
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Callback when user taps on a notification
  static void Function(String? taskId)? onNotificationTap;

  /// Initialize the notification service
  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Fallback to UTC if timezone detection fails
      debugPrint('Timezone detection failed: $e');
    }

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _isInitialized = true;
    debugPrint('NotificationService initialized');
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    debugPrint('Notification tapped with payload: $payload');
    onNotificationTap?.call(payload);
  }

  /// Request notification permissions (Android 13+)
  Future<bool> requestPermissions() async {
    // Skip on web - notifications not supported
    if (kIsWeb) return true;

    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }
    return true;
  }

  /// Schedule a reminder notification for a task
  Future<void> scheduleTaskReminder(Task task) async {
    if (!_isInitialized) await init();

    final reminderTime = task.remindAt ?? task.dueDate;
    if (reminderTime == null) return;

    // Don't schedule if the time has passed
    if (reminderTime.isBefore(DateTime.now())) {
      debugPrint('Reminder time already passed for task: ${task.id}');
      return;
    }

    // Generate unique notification ID from task ID hash
    final notificationId = task.id.hashCode.abs() % 2147483647;

    const androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for task due date reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

    await _plugin.zonedSchedule(
      notificationId,
      '📋 Task Reminder',
      task.title,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: task.id,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint(
      'Scheduled reminder for task "${task.title}" at $scheduledDate (ID: $notificationId)',
    );
  }

  /// Cancel a scheduled reminder for a task
  Future<void> cancelTaskReminder(String taskId) async {
    final notificationId = taskId.hashCode.abs() % 2147483647;
    await _plugin.cancel(notificationId);
    debugPrint('Cancelled reminder for task ID: $taskId');
  }

  /// Cancel all scheduled reminders
  Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
    debugPrint('Cancelled all reminders');
  }

  /// Check if exact alarms are permitted (Android 12+)
  Future<bool> canScheduleExactAlarms() async {
    // Skip on web
    if (kIsWeb) return true;

    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidPlugin?.canScheduleExactNotifications() ?? false;
    }
    return true;
  }

  /// Show an immediate notification (for testing)
  Future<void> showTestNotification() async {
    if (!_isInitialized) await init();

    const androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for task due date reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      0,
      '🔔 Test Notification',
      'Notifications are working!',
      notificationDetails,
    );
  }
}
