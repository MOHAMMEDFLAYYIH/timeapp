import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../models/analytics_model.dart';
import '../models/category_model.dart' as models;
import '../utils.dart';

/// AnalyticsProvider computes and manages analytics/statistics
///
/// This provider processes task data to generate meaningful statistics
/// including completion rates, daily trends, and category breakdowns.
/// It depends on TaskProvider and updates automatically when tasks change.
class AnalyticsProvider with ChangeNotifier {
  Analytics _analytics = Analytics.empty();
  List<models.Category> _categories = [];

  /// Current analytics data
  Analytics get analytics => _analytics;

  /// Update analytics based on current task list
  ///
  /// This is called automatically when tasks change via ProxyProvider
  void updateAnalytics(List<Task> tasks) {
    _analytics = _calculateAnalytics(tasks);
    notifyListeners();
  }

  /// Set categories for analytics computation
  void setCategories(List<models.Category> categories) {
    _categories = categories;
  }

  /// Calculate comprehensive analytics from tasks
  Analytics _calculateAnalytics(List<Task> tasks) {
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((task) => task.isCompleted).length;

    // Calculate daily completions for last 7 days
    final dailyCompletions = _calculateDailyCompletions(tasks);

    // Calculate category statistics
    final categoryStats = _calculateCategoryStats(tasks);

    // Calculate tasks completed today
    final now = DateTime.now();
    final todayStart = DateUtils.startOfDay(now);
    final todayEnd = DateUtils.endOfDay(now);
    final completedToday = tasks
        .where(
          (task) =>
              task.isCompleted &&
              task.completedAt != null &&
              task.completedAt!.isAfter(todayStart) &&
              task.completedAt!.isBefore(todayEnd),
        )
        .length;

    // Calculate tasks completed this week
    final weekStart = DateUtils.startOfWeek(now);
    final weekEnd = DateUtils.endOfWeek(now);
    final completedThisWeek = tasks
        .where(
          (task) =>
              task.isCompleted &&
              task.completedAt != null &&
              task.completedAt!.isAfter(weekStart) &&
              task.completedAt!.isBefore(weekEnd),
        )
        .length;

    return Analytics(
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      categoryStats: categoryStats,
      dailyCompletions: dailyCompletions,
      completedToday: completedToday,
      completedThisWeek: completedThisWeek,
    );
  }

  /// Calculate daily completion counts for the last 7 days
  List<DailyCompletion> _calculateDailyCompletions(List<Task> tasks) {
    final last7Days = DateUtils.getLastNDays(7);
    final dailyCompletions = <DailyCompletion>[];

    for (final date in last7Days) {
      final dayStart = DateUtils.startOfDay(date);
      final dayEnd = DateUtils.endOfDay(date);

      // Count tasks completed on this day
      final completedCount = tasks
          .where(
            (task) =>
                task.isCompleted &&
                task.completedAt != null &&
                task.completedAt!.isAfter(dayStart) &&
                task.completedAt!.isBefore(dayEnd),
          )
          .length;

      // Count total tasks that existed on this day
      final totalCount = tasks
          .where((task) => task.createdAt.isBefore(dayEnd))
          .length;

      dailyCompletions.add(
        DailyCompletion(
          date: date,
          completedCount: completedCount,
          totalCount: totalCount,
        ),
      );
    }

    return dailyCompletions;
  }

  /// Calculate statistics per category
  List<CategoryStat> _calculateCategoryStats(List<Task> tasks) {
    final categoryStatsMap = <String, CategoryStat>{};

    // Group tasks by category
    for (final task in tasks) {
      if (!categoryStatsMap.containsKey(task.categoryId)) {
        // Find category in list
        final category = _categories.firstWhere(
          (cat) => cat.id == task.categoryId,
          orElse: () => models.Category(
            id: task.categoryId,
            name: 'Unknown',
            colorValue: 0xFF9E9E9E,
            iconCode: 0xe88a,
          ),
        );

        categoryStatsMap[task.categoryId] = CategoryStat(
          category: category,
          totalTasks: 0,
          completedTasks: 0,
        );
      }

      final stat = categoryStatsMap[task.categoryId]!;
      categoryStatsMap[task.categoryId] = CategoryStat(
        category: stat.category,
        totalTasks: stat.totalTasks + 1,
        completedTasks: stat.completedTasks + (task.isCompleted ? 1 : 0),
      );
    }

    // Sort by total tasks (descending)
    final statsList = categoryStatsMap.values.toList();
    statsList.sort((a, b) => b.totalTasks.compareTo(a.totalTasks));

    return statsList;
  }

  /// Get completion trend (comparing this week to last week)
  /// Returns positive value if improving, negative if declining
  double getCompletionTrend() {
    if (_analytics.dailyCompletions.length < 7) {
      return 0.0;
    }

    // Calculate average for first 3 days vs last 3 days
    final firstThreeDays = _analytics.dailyCompletions.take(3);
    final lastThreeDays = _analytics.dailyCompletions.skip(4).take(3);

    final firstAverage = firstThreeDays.isEmpty
        ? 0.0
        : firstThreeDays.map((d) => d.completedCount).reduce((a, b) => a + b) /
              3;

    final lastAverage = lastThreeDays.isEmpty
        ? 0.0
        : lastThreeDays.map((d) => d.completedCount).reduce((a, b) => a + b) /
              3;

    return lastAverage - firstAverage;
  }

  /// Get productivity message based on analytics
  String getProductivityMessage() {
    final rate = _analytics.completionRate;

    if (_analytics.totalTasks == 0) {
      return 'Start by creating your first task!';
    }

    if (rate >= 0.8) {
      return 'Excellent work! You\'re crushing it! 🎉';
    } else if (rate >= 0.6) {
      return 'Great progress! Keep it up! 💪';
    } else if (rate >= 0.4) {
      return 'You\'re making progress! Stay focused! 🎯';
    } else if (rate >= 0.2) {
      return 'You can do it! One task at a time! 🌟';
    } else {
      return 'Let\'s get started! Pick a task! 🚀';
    }
  }
}
