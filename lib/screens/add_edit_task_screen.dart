import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/category_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/empty_state.dart';
import '../services/notification_service.dart';

/// Add/Edit Task Screen with premium design
class AddEditTaskScreen extends StatefulWidget {
  final String? taskId;

  const AddEditTaskScreen({super.key, this.taskId});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategoryId;
  DateTime? _dueDate;
  DateTime? _remindAt;
  bool _hasReminder = false;
  bool _isLoading = false;
  Task? _existingTask;

  bool get isEditing => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  void _loadTask() {
    if (widget.taskId != null) {
      final taskProvider = context.read<TaskProvider>();
      final task = taskProvider.tasks.firstWhere(
        (task) => task.id == widget.taskId,
        orElse: () => Task(
          id: '',
          title: '',
          categoryId: '',
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
      );

      if (task.id.isNotEmpty) {
        _existingTask = task;
        _titleController.text = task.title;
        _descriptionController.text = task.description ?? '';
        _selectedCategoryId = task.categoryId;
        _dueDate = task.dueDate;
        _remindAt = task.remindAt;
        _hasReminder = task.hasReminder;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? loc.get('edit_task') : loc.get('new_task')),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth >= AppBreakpoints.mobile;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.all(
                    isWideScreen ? AppSpacing.lg : AppSpacing.md,
                  ),
                  children: [
                    // Title Field
                    _buildTitleField(theme, loc),

                    const SizedBox(height: AppSpacing.md),

                    // Description Field
                    _buildDescriptionField(theme, loc),

                    const SizedBox(height: AppSpacing.lg),

                    // Category Selector
                    _buildCategorySelector(theme, loc),

                    const SizedBox(height: AppSpacing.lg),

                    // Due Date Picker
                    _buildDueDatePicker(theme, loc),

                    const SizedBox(height: AppSpacing.lg),

                    // Reminder Toggle
                    _buildReminderSection(theme, loc),

                    const SizedBox(height: AppSpacing.xl),

                    // Save Button
                    _buildSaveButton(theme, loc),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitleField(ThemeData theme, AppLocalizations loc) {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: loc.get('task_title'),
        hintText: loc.get('task_hint'),
        prefixIcon: const Icon(Icons.edit_outlined),
      ),
      textCapitalization: TextCapitalization.sentences,
      autofocus: !isEditing,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return loc.get('enter_title_error');
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField(ThemeData theme, AppLocalizations loc) {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: loc.get('description_optional'),
        hintText: loc.get('description_hint'),
        prefixIcon: const Icon(Icons.notes_outlined),
        alignLabelWithHint: true,
      ),
      textCapitalization: TextCapitalization.sentences,
      maxLines: 3,
    );
  }

  Widget _buildCategorySelector(ThemeData theme, AppLocalizations loc) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, _) {
        if (categoryProvider.isLoading) {
          return Center(child: LoadingState(message: loc.get('loading')));
        }

        final categories = categoryProvider.categories;

        if (categories.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              loc.get('no_categories_available'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          );
        }

        // Set default category
        if (_selectedCategoryId == null && categories.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _selectedCategoryId = categories.first.id;
            });
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.get('category'), style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: categories.map((category) {
                final isSelected = _selectedCategoryId == category.id;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = category.id;
                    });
                  },
                  child: AnimatedContainer(
                    duration: AppDurations.fast,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? category.color.withAlpha(30)
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: isSelected
                            ? category.color
                            : theme.colorScheme.outline,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category.icon,
                          size: 18,
                          color: isSelected
                              ? category.color
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          category.name,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: isSelected
                                ? category.color
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDueDatePicker(ThemeData theme, AppLocalizations loc) {
    final hasDate = _dueDate != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.get('due_date'), style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: _pickDueDate,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: hasDate
                  ? theme.colorScheme.primary.withAlpha(15)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: hasDate
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: hasDate
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    hasDate
                        ? _formatDate(_dueDate!, loc.locale.languageCode)
                        : loc.get('no_due_date'),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: hasDate
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (hasDate)
                  IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      setState(() {
                        _dueDate = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(ThemeData theme, AppLocalizations loc) {
    return FilledButton(
      onPressed: _isLoading ? null : _saveTask,
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(isEditing ? loc.get('update_task') : loc.get('create_task')),
    );
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
        // Default reminder to due date at 9 AM if not set
        if (_hasReminder && _remindAt == null) {
          _remindAt = DateTime(picked.year, picked.month, picked.day, 9, 0);
        }
      });
    }
  }

  Future<void> _pickReminderTime() async {
    final initialTime = _remindAt != null
        ? TimeOfDay.fromDateTime(_remindAt!)
        : const TimeOfDay(hour: 9, minute: 0);

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null && _dueDate != null) {
      setState(() {
        _remindAt = DateTime(
          _dueDate!.year,
          _dueDate!.month,
          _dueDate!.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Widget _buildReminderSection(ThemeData theme, AppLocalizations loc) {
    final canSetReminder = _dueDate != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.get('reminder'), style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: _hasReminder
                ? theme.colorScheme.primaryContainer.withAlpha(30)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: _hasReminder
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    size: 20,
                    color: _hasReminder
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      _hasReminder
                          ? loc.get('reminder_on')
                          : loc.get('no_reminder'),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: _hasReminder
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Switch(
                    value: _hasReminder,
                    onChanged: canSetReminder
                        ? (value) {
                            setState(() {
                              _hasReminder = value;
                              if (value &&
                                  _dueDate != null &&
                                  _remindAt == null) {
                                // Default to 9 AM on due date
                                _remindAt = DateTime(
                                  _dueDate!.year,
                                  _dueDate!.month,
                                  _dueDate!.day,
                                  9,
                                  0,
                                );
                              }
                            });
                          }
                        : null,
                  ),
                ],
              ),
              if (!canSetReminder)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    loc.get('set_due_date_first'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              if (_hasReminder && _remindAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: InkWell(
                    onTap: _pickReminderTime,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: theme.colorScheme.outline),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            DateFormat.jm(
                              loc.locale.languageCode,
                            ).format(_remindAt!),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Icon(
                            Icons.edit,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final loc = AppLocalizations.of(context)!;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.get('select_category_error')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final taskProvider = context.read<TaskProvider>();

    try {
      final task = Task(
        id: isEditing ? widget.taskId! : const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        categoryId: _selectedCategoryId!,
        isCompleted: isEditing ? _existingTask!.isCompleted : false,
        createdAt: isEditing ? _existingTask!.createdAt : DateTime.now(),
        completedAt: isEditing ? _existingTask!.completedAt : null,
        dueDate: _dueDate,
        remindAt: _hasReminder ? _remindAt : null,
        hasReminder: _hasReminder,
      );

      bool success;
      if (isEditing) {
        success = await taskProvider.updateTask(task);
      } else {
        final result = await taskProvider.addTask(task);
        success = result != null;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          // Schedule or cancel notification
          if (task.hasReminder && task.remindAt != null) {
            await NotificationService.instance.scheduleTaskReminder(task);
          } else {
            await NotificationService.instance.cancelTaskReminder(task.id);
          }

          if (!mounted) return;

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing ? loc.get('task_updated') : loc.get('task_created'),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.get('error')}: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date, String locale) {
    return DateFormat.yMMMMd(locale).format(date);
  }
}
