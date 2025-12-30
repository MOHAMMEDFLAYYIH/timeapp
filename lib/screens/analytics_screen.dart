import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/category_provider.dart';
import '../providers/analytics_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/theme_toggle_button.dart';
import '../l10n/app_localizations.dart';
import 'add_edit_task_screen.dart';

/// Analytics Screen with premium dashboard design
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.get('analytics_title')),
        actions: const [ThemeToggleButton()],
      ),
      body: Consumer3<TaskProvider, AnalyticsProvider, CategoryProvider>(
        builder:
            (context, taskProvider, analyticsProvider, categoryProvider, _) {
              if (taskProvider.isLoading) {
                return LoadingState(message: loc.get('loading_analytics'));
              }

              if (taskProvider.tasks.isEmpty) {
                return EmptyState(
                  icon: Icons.analytics_outlined,
                  title: loc.get('no_data_yet'),
                  description: loc.get('complete_tasks_desc'),
                );
              }

              // Responsive layout with constrained width on wide screens
              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen =
                      constraints.maxWidth >= AppBreakpoints.mobile;

                  // Constrain content width to maintain readability
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: ListView(
                        padding: EdgeInsets.all(
                          isWideScreen ? AppSpacing.lg : AppSpacing.md,
                        ),
                        children: [
                          // Weekly Productivity Card
                          _WeeklyProductivityCard(taskProvider: taskProvider),

                          const SizedBox(height: AppSpacing.lg),

                          // Weekly Chart
                          _WeeklyChartCard(taskProvider: taskProvider),

                          const SizedBox(height: AppSpacing.lg),

                          // Statistics Grid (with Average Card)
                          _StatisticsGrid(taskProvider: taskProvider),

                          const SizedBox(height: AppSpacing.lg),

                          // Recent Activity
                          _RecentActivityCard(
                            taskProvider: taskProvider,
                            categoryProvider: categoryProvider,
                          ),

                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
      ),
    );
  }
}

/// Weekly Productivity Summary Card with Premium Design
class _WeeklyProductivityCard extends StatelessWidget {
  final TaskProvider taskProvider;

  const _WeeklyProductivityCard({required this.taskProvider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final stats = _calculateWeeklyStats();
    final percentage = stats['percentage'] as double;

    // Calculate date range for display (#1)
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));
    final dateFormat = DateFormat('MMM d');
    final dateRangeText =
        '(${dateFormat.format(weekAgo)} - ${dateFormat.format(now)})';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withAlpha(180),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                loc.get('weekly_productivity'),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withAlpha(200),
                ),
              ),
              const Spacer(),
              // #1: Show actual date range instead of "This Week"
              Text(
                dateRangeText,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white.withAlpha(180),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              // Circular Progress Indicator
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 8,
                        backgroundColor: Colors.white.withAlpha(30),
                        color: Colors.white.withAlpha(30),
                      ),
                    ),
                    // Progress circle
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: percentage / 100),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: value,
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                            backgroundColor: Colors.transparent,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    // Percentage text
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${percentage.toInt()}%',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.lg),

              // Stats Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tasks Count
                    Row(
                      children: [
                        Text(
                          '${stats['completed']}',
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          ' / ${stats['total']}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white.withAlpha(180),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      loc.get('tasks_completed'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // #2: Dynamic Motivation Message based on percentage
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getFeedbackEmoji(percentage),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    _getDynamicMotivation(
                      percentage,
                      stats['completed'] as int,
                      loc,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateWeeklyStats() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final weeklyTasks = taskProvider.tasks.where((task) {
      return task.createdAt.isAfter(weekAgo);
    }).toList();

    final completed = weeklyTasks.where((t) => t.isCompleted).length;
    final total = weeklyTasks.length;
    final percentage = total > 0 ? (completed / total) * 100 : 0.0;

    return {'completed': completed, 'total': total, 'percentage': percentage};
  }

  // #2: Dynamic motivation messages based on completion percentage
  String _getDynamicMotivation(
    double percentage,
    int completed,
    AppLocalizations loc,
  ) {
    if (percentage >= 100) {
      return 'Outstanding! You crushed it! 🏆';
    } else if (percentage >= 80) {
      return loc.get('insight_outstanding', {'count': completed.toString()});
    } else if (percentage >= 50) {
      return 'Good job! Keep pushing. 💪';
    } else if (percentage > 0) {
      return "Don't give up! Tomorrow is a new start. 🌅";
    }
    return loc.get('insight_start');
  }

  String _getFeedbackEmoji(double percentage) {
    if (percentage >= 100) return '🎉';
    if (percentage >= 80) return '🔥';
    if (percentage >= 50) return '💪';
    if (percentage > 0) return '🎯';
    return '🚀';
  }
}

/// Weekly Chart Card with Animated Bars, Y-Axis Labels, Background Bars, and Touch Tooltip
class _WeeklyChartCard extends StatefulWidget {
  final TaskProvider taskProvider;

  const _WeeklyChartCard({required this.taskProvider});

  @override
  State<_WeeklyChartCard> createState() => _WeeklyChartCardState();
}

class _WeeklyChartCardState extends State<_WeeklyChartCard> {
  // #9: Time frame toggle state
  bool _isWeeklyView = true;
  int? _selectedBarIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final dailyData = _isWeeklyView
        ? _calculateDailyData()
        : _calculateMonthlyData();

    // Calculate max value for Y-axis scale
    int maxValue = 1;
    for (var entry in dailyData.entries) {
      final total = entry.value['total'] ?? 0;
      if (total > maxValue) maxValue = total;
    }
    // Round up to nearest even number for cleaner scale
    maxValue = ((maxValue + 1) ~/ 2) * 2;
    if (maxValue < 4) maxValue = 4;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _isWeeklyView ? loc.get('this_week') : 'This Month',
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              // #9: Time Frame Toggle Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isWeeklyView = !_isWeeklyView;
                    _selectedBarIndex = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swap_horiz,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isWeeklyView ? 'Weekly' : 'Monthly',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Chart with Y-Axis labels (#3)
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 180),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // #3: Y-Axis Labels
                SizedBox(
                  width: 24,
                  height: 140,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$maxValue',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        '${maxValue ~/ 2}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        '0',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Bars
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: dailyData.entries.toList().asMap().entries.map((
                      entry,
                    ) {
                      final index = entry.key;
                      final dayEntry = entry.value;
                      const maxHeight = 120.0;
                      final total = dayEntry.value['total'] ?? 0;
                      final completed = dayEntry.value['completed'] ?? 0;
                      final barHeight = maxValue > 0
                          ? (completed / maxValue) * maxHeight
                          : 0.0;
                      final isSelected = _selectedBarIndex == index;

                      return Expanded(
                        child: GestureDetector(
                          // #5: Touch Tooltip
                          onTap: () {
                            setState(() {
                              _selectedBarIndex = isSelected ? null : index;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // #5: Tooltip on tap
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 3,
                                    ),
                                    margin: const EdgeInsets.only(bottom: 4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '$completed/$total',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                          ),
                                    ),
                                  )
                                else if (completed > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      '$completed',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                // #4: Background Bar + Actual Bar
                                Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    // Background bar (max height indicator)
                                    Container(
                                      height: maxHeight,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.outline
                                            .withAlpha(30),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    // Animated actual bar
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(
                                        begin: 0,
                                        end: barHeight.clamp(0, maxHeight),
                                      ),
                                      duration: Duration(
                                        milliseconds: 400 + (index * 50),
                                      ),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, animatedHeight, _) {
                                        return Container(
                                          height: animatedHeight,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                theme.colorScheme.primary,
                                                theme.colorScheme.primary
                                                    .withAlpha(180),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            boxShadow: barHeight > 0
                                                ? [
                                                    BoxShadow(
                                                      color: theme
                                                          .colorScheme
                                                          .primary
                                                          .withAlpha(30),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        4,
                                                      ),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                // Label
                                Text(
                                  dayEntry.key,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                    fontSize: 10,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : null,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, Map<String, int>> _calculateDailyData() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();

    final Map<String, Map<String, int>> data = {};

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = days[date.weekday - 1];

      final dayTasks = widget.taskProvider.tasks.where((task) {
        return task.createdAt.year == date.year &&
            task.createdAt.month == date.month &&
            task.createdAt.day == date.day;
      }).toList();

      data[dayName] = {
        'total': dayTasks.length,
        'completed': dayTasks.where((t) => t.isCompleted).length,
      };
    }

    return data;
  }

  // #9: Monthly data for toggle
  Map<String, Map<String, int>> _calculateMonthlyData() {
    final now = DateTime.now();
    final Map<String, Map<String, int>> data = {};

    for (int week = 3; week >= 0; week--) {
      final weekStart = now.subtract(
        Duration(days: (week * 7) + now.weekday - 1),
      );
      final weekEnd = weekStart.add(const Duration(days: 6));

      final weekTasks = widget.taskProvider.tasks.where((task) {
        return task.createdAt.isAfter(
              weekStart.subtract(const Duration(days: 1)),
            ) &&
            task.createdAt.isBefore(weekEnd.add(const Duration(days: 1)));
      }).toList();

      final weekLabel = 'W${4 - week}';
      data[weekLabel] = {
        'total': weekTasks.length,
        'completed': weekTasks.where((t) => t.isCompleted).length,
      };
    }

    return data;
  }
}

/// Statistics Grid with Average Tasks Card (#8)
class _StatisticsGrid extends StatelessWidget {
  final TaskProvider taskProvider;

  const _StatisticsGrid({required this.taskProvider});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final total = taskProvider.tasks.length;
    final completed = taskProvider.tasks.where((t) => t.isCompleted).length;
    final pending = total - completed;

    // #8: Calculate average tasks per day (last 7 days)
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weeklyCompleted = taskProvider.tasks
        .where(
          (t) =>
              t.isCompleted &&
              t.completedAt != null &&
              t.completedAt!.isAfter(weekAgo),
        )
        .length;
    final avgPerDay = (weeklyCompleted / 7).toStringAsFixed(1);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.task_alt,
                label: loc.get('total_tasks'),
                value: total.toString(),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatCard(
                icon: Icons.check_circle_outline,
                label: loc.get('completed'),
                value: completed.toString(),
                color: Theme.of(context).success,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.pending_outlined,
                label: loc.get('pending'),
                value: pending.toString(),
                color: Theme.of(context).warning,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // #8: Average Tasks per Day Card
            Expanded(
              child: _StatCard(
                icon: Icons.trending_up,
                label: 'Avg/Day',
                value: avgPerDay,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Individual Stat Card
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Recent Activity Card with Category Colors and Clickable Items (#6, #7, #10)
class _RecentActivityCard extends StatelessWidget {
  final TaskProvider taskProvider;
  final CategoryProvider categoryProvider;

  const _RecentActivityCard({
    required this.taskProvider,
    required this.categoryProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    final recentCompleted =
        taskProvider.tasks
            .where((t) => t.isCompleted && t.completedAt != null)
            .toList()
          ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

    final recent = recentCompleted.take(5).toList();

    // #7: Empty State for Activity
    if (recent.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No recent activity yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Go complete some tasks!',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withAlpha(150),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.get('recent_activity'), style: theme.textTheme.titleMedium),

          const SizedBox(height: AppSpacing.md),

          ...recent.map((task) {
            // #6: Get category color for the task
            final category = categoryProvider.getCategoryById(task.categoryId);
            final iconColor = category?.color ?? theme.success;

            // #10: Make items clickable
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _navigateToTask(context, task),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xs,
                    horizontal: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      // #6: Icon with category color
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: iconColor.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: iconColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: theme.textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (category != null)
                              Text(
                                category.name,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: iconColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatRelativeDate(task.completedAt!, loc),
                            style: theme.textTheme.labelSmall,
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // #10: Navigate to task details
  void _navigateToTask(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditTaskScreen(taskId: task.id)),
    );
  }

  String _formatRelativeDate(DateTime date, AppLocalizations loc) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return loc.get('ago_m', {'m': diff.inMinutes.toString()});
    } else if (diff.inHours < 24) {
      return loc.get('ago_h', {'h': diff.inHours.toString()});
    } else if (diff.inDays < 7) {
      return loc.get('ago_d', {'d': diff.inDays.toString()});
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
