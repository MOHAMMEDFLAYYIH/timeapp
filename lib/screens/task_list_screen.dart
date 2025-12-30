import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/category_chip.dart';
import '../widgets/empty_state.dart';
import '../widgets/theme_toggle_button.dart';
import 'add_edit_task_screen.dart';
import '../l10n/app_localizations.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String? _selectedCategoryId;
  bool _isFabPressed = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.get('nav_tasks')),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              final taskProvider = context.read<TaskProvider>();
              final categoryProvider = context.read<CategoryProvider>();
              showSearch(
                context: context,
                delegate: TaskSearchDelegate(
                  tasks: taskProvider.tasks,
                  categoryProvider: categoryProvider,
                  onTaskTap: (taskId) => _navigateToEditTask(context, taskId),
                  onToggleComplete: (task) => _toggleTaskCompletion(task),
                ),
              );
            },
          ),
          const ThemeToggleButton(),
        ],
      ),
      body: Consumer2<TaskProvider, CategoryProvider>(
        builder: (context, taskProvider, categoryProvider, _) {
          if (taskProvider.isLoading) {
            return LoadingState(message: loc.get('loading_tasks'));
          }

          // Responsive layout with constrained width on wide screens
          return LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await taskProvider.loadTasks();
                    },
                    child: CustomScrollView(
                      slivers: [
                        // Category Filter
                        SliverToBoxAdapter(
                          child: _buildCategoryFilter(categoryProvider),
                        ),

                        // Task Lists
                        ..._buildTaskSections(
                          taskProvider,
                          categoryProvider,
                          loc,
                        ),

                        // Bottom Padding
                        const SliverPadding(
                          padding: EdgeInsets.only(bottom: 100),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: GestureDetector(
        onTapDown: (_) => setState(() => _isFabPressed = true),
        onTapUp: (_) {
          setState(() => _isFabPressed = false);
          _navigateToAddTask(context);
        },
        onTapCancel: () => setState(() => _isFabPressed = false),
        child: AnimatedScale(
          scale: _isFabPressed ? 0.9 : 1.0,
          duration: AppDurations.micro,
          curve: Curves.easeOut,
          child: const FloatingActionButton(
            onPressed: null, // Handled by GestureDetector
            child: Icon(Icons.add_rounded),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(CategoryProvider categoryProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          AllCategoriesChip(
            isSelected: _selectedCategoryId == null,
            onTap: () => setState(() => _selectedCategoryId = null),
          ),
          const SizedBox(width: AppSpacing.sm),
          ...categoryProvider.categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: CategoryChip(
                category: category,
                isSelected: _selectedCategoryId == category.id,
                onTap: () => setState(() => _selectedCategoryId = category.id),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Widget> _buildTaskSections(
    TaskProvider taskProvider,
    CategoryProvider categoryProvider,
    AppLocalizations loc,
  ) {
    // Filter tasks by category
    var tasks = taskProvider.tasks;
    if (_selectedCategoryId != null) {
      tasks = tasks
          .where((task) => task.categoryId == _selectedCategoryId)
          .toList();
    }

    if (tasks.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.task_alt,
            title: loc.get('no_tasks_yet'),
            description: loc.get('add_first_task'),
            actionLabel: loc.get('add_task'),
            onAction: () => _navigateToAddTask(context),
          ),
        ),
      ];
    }

    // Separate pending and completed tasks
    final pendingTasks = tasks.where((t) => !t.isCompleted).toList();
    final completedTasks = tasks.where((t) => t.isCompleted).toList();

    // Sort pending tasks by due date
    pendingTasks.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });

    final slivers = <Widget>[];

    // Pending Tasks Section
    if (pendingTasks.isNotEmpty) {
      slivers.add(_buildSectionHeader(loc.get('pending'), pendingTasks.length));
      slivers.add(_buildTaskList(pendingTasks, categoryProvider, loc));
    }

    // Completed Tasks Section
    if (completedTasks.isNotEmpty) {
      slivers.add(
        _buildSectionHeader(loc.get('completed'), completedTasks.length),
      );
      slivers.add(_buildTaskList(completedTasks, categoryProvider, loc));
    }

    return slivers;
  }

  Widget _buildSectionHeader(String title, int count) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                count.toString(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(
    List<Task> tasks,
    CategoryProvider categoryProvider,
    AppLocalizations loc,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final task = tasks[index];
          final category = categoryProvider.getCategoryById(task.categoryId);

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: TaskTile(
              task: task,
              category: category,
              onTap: () => _navigateToEditTask(context, task.id),
              onToggleComplete: () => _toggleTaskCompletion(task),
              onDelete: () => _deleteTask(task, loc),
            ),
          );
        }, childCount: tasks.length),
      ),
    );
  }

  void _navigateToAddTask(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
    );
  }

  void _navigateToEditTask(BuildContext context, String taskId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditTaskScreen(taskId: taskId)),
    );
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    final taskProvider = context.read<TaskProvider>();
    await taskProvider.toggleTaskCompletion(task.id);
  }

  Future<void> _deleteTask(Task task, AppLocalizations loc) async {
    final taskProvider = context.read<TaskProvider>();
    await taskProvider.deleteTask(task.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.get('task_deleted')),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: loc.get('undo'),
            onPressed: () async {
              await taskProvider.addTask(task);
            },
          ),
        ),
      );
    }
  }
}

/// Search delegate for finding tasks
class TaskSearchDelegate extends SearchDelegate<String?> {
  final List<Task> tasks;
  final CategoryProvider categoryProvider;
  final Function(String taskId) onTaskTap;
  final Function(Task task) onToggleComplete;

  TaskSearchDelegate({
    required this.tasks,
    required this.categoryProvider,
    required this.onTaskTap,
    required this.onToggleComplete,
  });

  @override
  String get searchFieldLabel => 'Search tasks...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withAlpha(100),
            ),
            const SizedBox(height: 16),
            Text(
              'Search by title or description',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final lowerQuery = query.toLowerCase();
    final filteredTasks = tasks.where((task) {
      final titleMatch = task.title.toLowerCase().contains(lowerQuery);
      final descMatch =
          task.description?.toLowerCase().contains(lowerQuery) ?? false;
      return titleMatch || descMatch;
    }).toList();

    if (filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withAlpha(100),
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks found for "$query"',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredTasks.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        final category = categoryProvider.getCategoryById(task.categoryId);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: IconButton(
              icon: Icon(
                task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: task.isCompleted
                    ? Colors.green
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                onToggleComplete(task);
                close(context, null);
              },
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            subtitle: task.description != null
                ? Text(
                    task.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: category != null
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: category.color.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category.name,
                      style: TextStyle(fontSize: 12, color: category.color),
                    ),
                  )
                : null,
            onTap: () {
              close(context, null);
              onTaskTap(task.id);
            },
          ),
        );
      },
    );
  }
}
