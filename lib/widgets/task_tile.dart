import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/category_model.dart';
import '../app_theme.dart';

/// Premium Task Tile with modern design
///
/// Features:
/// - Animated checkbox with success color
/// - Category badge with icon
/// - Due date indicator with warning states
/// - Swipe to delete
/// - Smooth state transitions
class TaskTile extends StatelessWidget {
  final Task task;
  final Category? category;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onDelete;

  const TaskTile({
    super.key,
    required this.task,
    this.category,
    this.onTap,
    this.onToggleComplete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompleted = task.isCompleted;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: _buildDismissBackground(theme),
      child: AnimatedContainer(
        duration: AppDurations.normal,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: colorScheme.outline, width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox
                  _buildCheckbox(theme, isCompleted),

                  const SizedBox(width: AppSpacing.md),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Due Date Row
                        Row(
                          children: [
                            Expanded(child: _buildTitle(theme, isCompleted)),
                            if (task.dueDate != null) _buildDueDateBadge(theme),
                          ],
                        ),

                        // Description
                        if (task.description != null &&
                            task.description!.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          _buildDescription(theme, isCompleted),
                        ],

                        // Category Badge
                        if (category != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          _buildCategoryBadge(theme),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(ThemeData theme, bool isCompleted) {
    return GestureDetector(
      onTap: onToggleComplete,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: isCompleted ? 0.8 : 1.0, end: 1.0),
        duration: AppDurations.normal,
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: AnimatedContainer(
          duration: AppDurations.fast,
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: isCompleted ? theme.success : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCompleted ? theme.success : theme.colorScheme.outline,
              width: 2,
            ),
            boxShadow: isCompleted
                ? [
                    BoxShadow(
                      color: theme.success.withAlpha(40),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: isCompleted
              ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
              : null,
        ),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme, bool isCompleted) {
    return AnimatedDefaultTextStyle(
      duration: AppDurations.fast,
      style: theme.textTheme.titleMedium!.copyWith(
        decoration: isCompleted ? TextDecoration.lineThrough : null,
        color: isCompleted
            ? theme.colorScheme.onSurfaceVariant
            : theme.colorScheme.onSurface,
      ),
      child: Text(task.title, maxLines: 2, overflow: TextOverflow.ellipsis),
    );
  }

  Widget _buildDescription(ThemeData theme, bool isCompleted) {
    return AnimatedOpacity(
      duration: AppDurations.fast,
      opacity: isCompleted ? 0.5 : 1.0,
      child: Text(
        task.description!,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDueDateBadge(ThemeData theme) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
    );

    final isOverdue = dueDate.isBefore(today) && !task.isCompleted;
    final isToday = dueDate.isAtSameMomentAs(today);
    final isTomorrow = dueDate.difference(today).inDays == 1;

    Color badgeColor;
    String dateText;

    if (isOverdue) {
      badgeColor = theme.error;
      dateText = 'Overdue';
    } else if (isToday) {
      badgeColor = theme.warning;
      dateText = 'Today';
    } else if (isTomorrow) {
      badgeColor = theme.colorScheme.primary;
      dateText = 'Tomorrow';
    } else {
      badgeColor = theme.colorScheme.onSurfaceVariant;
      dateText = _formatDate(task.dueDate!);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(25),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        dateText,
        style: theme.textTheme.labelSmall?.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: category!.color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category!.icon, size: 14, color: category!.color),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              category!.name,
              style: theme.textTheme.labelSmall?.copyWith(
                color: category!.color,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissBackground(ThemeData theme) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.error,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: const Icon(
        Icons.delete_outline,
        color: Colors.white,
        size: AppIconSize.md,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
