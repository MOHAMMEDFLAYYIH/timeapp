import 'category_model.dart';

/// Statistics for a single category
class CategoryStat {
  /// Category reference
  final Category category;

  /// Total tasks in this category
  final int totalTasks;

  /// Completed tasks in this category
  final int completedTasks;

  /// Completion rate (0.0 to 1.0)
  double get completionRate {
    if (totalTasks == 0) return 0.0;
    return completedTasks / totalTasks;
  }

  /// Completion percentage (0 to 100)
  int get completionPercentage {
    return (completionRate * 100).round();
  }

  CategoryStat({
    required this.category,
    required this.totalTasks,
    required this.completedTasks,
  });

  @override
  String toString() {
    return 'CategoryStat(category: ${category.name}, total: $totalTasks, '
        'completed: $completedTasks, rate: ${completionPercentage}%)';
  }
}

/// Daily completion statistics
class DailyCompletion {
  /// Date for these statistics
  final DateTime date;

  /// Number of tasks completed on this date
  final int completedCount;

  /// Total tasks that existed on this date
  final int totalCount;

  DailyCompletion({
    required this.date,
    required this.completedCount,
    required this.totalCount,
  });

  /// Day name (e.g., 'Mon', 'Tue')
  String get dayName {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  @override
  String toString() {
    return 'DailyCompletion(date: $date, completed: $completedCount, total: $totalCount)';
  }
}

/// Comprehensive analytics model containing all statistics
class Analytics {
  /// Total number of tasks
  final int totalTasks;

  /// Number of completed tasks
  final int completedTasks;

  /// Number of pending tasks
  int get pendingTasks => totalTasks - completedTasks;

  /// Overall completion rate (0.0 to 1.0)
  double get completionRate {
    if (totalTasks == 0) return 0.0;
    return completedTasks / totalTasks;
  }

  /// Overall completion percentage (0 to 100)
  int get completionPercentage {
    return (completionRate * 100).round();
  }

  /// Statistics per category
  final List<CategoryStat> categoryStats;

  /// Daily completion data (typically for last 7 days)
  final List<DailyCompletion> dailyCompletions;

  /// Tasks completed today
  final int completedToday;

  /// Tasks completed this week
  final int completedThisWeek;

  Analytics({
    required this.totalTasks,
    required this.completedTasks,
    required this.categoryStats,
    required this.dailyCompletions,
    required this.completedToday,
    required this.completedThisWeek,
  });

  /// Create empty analytics (for initial state)
  factory Analytics.empty() {
    return Analytics(
      totalTasks: 0,
      completedTasks: 0,
      categoryStats: [],
      dailyCompletions: [],
      completedToday: 0,
      completedThisWeek: 0,
    );
  }

  @override
  String toString() {
    return 'Analytics(total: $totalTasks, completed: $completedTasks, '
        'rate: ${completionPercentage}%, today: $completedToday, '
        'thisWeek: $completedThisWeek)';
  }
}
