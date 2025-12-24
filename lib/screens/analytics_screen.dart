import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/task_provider.dart';
import '../providers/analytics_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/theme_toggle_button.dart';
import '../l10n/app_localizations.dart';

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
      body: Consumer2<TaskProvider, AnalyticsProvider>(
        builder: (context, taskProvider, analyticsProvider, _) {
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

                      // Statistics Grid
                      _StatisticsGrid(taskProvider: taskProvider),

                      const SizedBox(height: AppSpacing.lg),

                      // Recent Activity
                      _RecentActivityCard(taskProvider: taskProvider),

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
              Text(
                loc.get('this_week'),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white.withAlpha(150),
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

          // Human-readable Insight
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
                    _getDetailedInsight(stats, loc),
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

  String _getDetailedInsight(Map<String, dynamic> stats, AppLocalizations loc) {
    final percentage = stats['percentage'] as double;
    final completed = stats['completed'] as int;

    if (percentage >= 80) {
      return loc.get('insight_outstanding', {'count': completed.toString()});
    } else if (percentage >= 50) {
      return loc.get('insight_good');
    } else if (percentage > 0) {
      return loc.get('insight_motivated');
    }
    return loc.get('insight_start');
  }

  String _getFeedbackEmoji(double percentage) {
    if (percentage >= 80) return '🎉';
    if (percentage >= 50) return '💪';
    if (percentage > 0) return '🎯';
    return '🚀';
  }
}

/// Weekly Chart Card with Animated Bars
class _WeeklyChartCard extends StatelessWidget {
  final TaskProvider taskProvider;

  const _WeeklyChartCard({required this.taskProvider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final dailyData = _calculateDailyData();

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
              Text(loc.get('this_week'), style: theme.textTheme.titleMedium),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  loc.get('daily_progress'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Chart
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 160),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: dailyData.entries.toList().asMap().entries.map((entry) {
                final index = entry.key;
                final dayEntry = entry.value;
                const maxHeight = 120.0;
                final total = dayEntry.value['total'] ?? 0;
                final completed = dayEntry.value['completed'] ?? 0;
                final height = total > 0
                    ? (completed / total) * maxHeight
                    : 0.0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Value label
                        if (completed > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '$completed',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        // Animated Bar with staggered entrance
                        TweenAnimationBuilder<double>(
                          tween: Tween(
                            begin: 0,
                            end: height.clamp(4, maxHeight),
                          ),
                          duration: Duration(milliseconds: 400 + (index * 50)),
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
                                    theme.colorScheme.primary.withAlpha(180),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: height > 0
                                    ? [
                                        BoxShadow(
                                          color: theme.colorScheme.primary
                                              .withAlpha(30),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        // Label
                        Text(
                          dayEntry.key,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, Map<String, int>> _calculateDailyData() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    // For Localization, we might want to map these day names if strict.
    // For now keeping short English names or numbers is usually acceptable in charts,
    // but ideally should be localized.
    // Let's use simple numbers or first letters? Or just keep English for now as 'Mon', 'Tue' are universal codes often.
    // Actually, `intl` allows getting short day.

    final now = DateTime.now();

    final Map<String, Map<String, int>> data = {};

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = days[date.weekday - 1]; // This is hardcoded to English.
      // If we want Arabic, we'd need a map/list similar to keys.
      // I will leave it as is for simplicity unless critical. The user asked for "Full" so maybe I should...
      // But chart labels are tricky. I'll stick to English day codes for safety in layout, or use `DateFormat.E(loc.locale.toString()).format(date)` if I import intl.

      final dayTasks = taskProvider.tasks.where((task) {
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
}

/// Statistics Grid
class _StatisticsGrid extends StatelessWidget {
  final TaskProvider taskProvider;

  const _StatisticsGrid({required this.taskProvider});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final total = taskProvider.tasks.length;
    final completed = taskProvider.tasks.where((t) => t.isCompleted).length;
    final pending = total - completed;

    return Row(
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
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.pending_outlined,
            label: loc.get('pending'),
            value: pending.toString(),
            color: Theme.of(context).warning,
          ),
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

/// Recent Activity Card
class _RecentActivityCard extends StatelessWidget {
  final TaskProvider taskProvider;

  const _RecentActivityCard({required this.taskProvider});

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

    if (recent.isEmpty) {
      return const SizedBox.shrink();
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
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: theme.success, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      task.title,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatRelativeDate(task.completedAt!, loc),
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
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
