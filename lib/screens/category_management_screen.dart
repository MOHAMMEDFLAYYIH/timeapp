import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/category_model.dart';
import '../providers/category_provider.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/empty_state.dart';
import '../l10n/app_localizations.dart';

/// Category Management Screen with premium design
class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.get('nav_categories')),
        actions: const [ThemeToggleButton()],
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, _) {
          if (categoryProvider.isLoading) {
            return LoadingState(message: loc.get('loading_categories'));
          }

          final categories = categoryProvider.categories;

          if (categories.isEmpty) {
            return EmptyState(
              icon: Icons.folder_outlined,
              title: loc.get('no_categories'),
              description: loc.get('create_categories_desc'),
              actionLabel: loc.get('add_category'),
              onAction: () => _showAddCategoryDialog(context),
            );
          }

          // Responsive Grid Layout using LayoutBuilder
          return LayoutBuilder(
            builder: (context, constraints) {
              final columns = AppBreakpoints.getGridColumns(
                constraints.maxWidth,
              );
              final isWideScreen =
                  constraints.maxWidth >= AppBreakpoints.mobile;

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWideScreen
                        ? AppBreakpoints.maxContentWidth
                        : double.infinity,
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      childAspectRatio: isWideScreen ? 2.2 : 1.0,
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.sm,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _CategoryCard(
                        category: category,
                        isVertical: !isWideScreen,
                        onEdit: () =>
                            _showEditCategoryDialog(context, category),
                        onDelete: () => _showDeleteDialog(context, category),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _CategoryFormSheet(),
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CategoryFormSheet(category: category),
    );
  }

  void _showDeleteDialog(BuildContext context, Category category) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.get('delete_category')),
        content: Text(
          loc
              .get('delete_category_confirm')
              .replaceAll('{name}', category.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.get('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<CategoryProvider>().deleteCategory(
                category.id,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loc.get('category_deleted')),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: theme.error),
            child: Text(loc.get('delete')),
          ),
        ],
      ),
    );
  }
}

/// Category Card Widget with Premium Design
class _CategoryCard extends StatefulWidget {
  final Category category;
  final bool isVertical;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CategoryCard({
    required this.category,
    this.isVertical = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onEdit?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: AppDurations.micro,
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          decoration: BoxDecoration(
            color: _isPressed
                ? widget.category.color.withAlpha(10)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: _isPressed
                  ? widget.category.color.withAlpha(100)
                  : theme.colorScheme.outline,
              width: 1,
            ),
          ),
          child: widget.isVertical
              ? _buildVerticalLayout(theme, isDark, loc)
              : _buildHorizontalLayout(theme, isDark, loc),
        ),
      ),
    );
  }

  Widget _buildVerticalLayout(
    ThemeData theme,
    bool isDark,
    AppLocalizations loc,
  ) {
    return Stack(
      children: [
        // Menu Button Top Right
        Positioned(
          top: -4,
          right: -4,
          child: PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                widget.onEdit?.call();
              } else if (value == 'delete') {
                widget.onDelete?.call();
              }
            },
            itemBuilder: (context) => _buildMenuItems(theme, loc),
          ),
        ),

        // Content
        Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.category.color.withAlpha(isDark ? 50 : 40),
                        widget.category.color.withAlpha(isDark ? 30 : 20),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: widget.category.color.withAlpha(40),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    widget.category.icon,
                    color: widget.category.color,
                    size: 24,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Text
                Text(
                  widget.category.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalLayout(
    ThemeData theme,
    bool isDark,
    AppLocalizations loc,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Enhanced Icon Container with gradient
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.category.color.withAlpha(isDark ? 50 : 40),
                  widget.category.color.withAlpha(isDark ? 30 : 20),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: widget.category.color.withAlpha(40),
                width: 1,
              ),
            ),
            child: Icon(
              widget.category.icon,
              color: widget.category.color,
              size: 28,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Name and hint
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.category.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  loc.get('tap_to_edit'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Popup Menu for actions
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                widget.onEdit?.call();
              } else if (value == 'delete') {
                widget.onDelete?.call();
              }
            },
            itemBuilder: (context) => _buildMenuItems(theme, loc),
          ),
        ],
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(
    ThemeData theme,
    AppLocalizations loc,
  ) {
    return [
      PopupMenuItem(
        value: 'edit',
        child: Row(
          children: [
            Icon(
              Icons.edit_outlined,
              size: 20,
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(loc.get('edit')),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete_outline, size: 20, color: theme.error),
            const SizedBox(width: AppSpacing.sm),
            Text(loc.get('delete'), style: TextStyle(color: theme.error)),
          ],
        ),
      ),
    ];
  }
}

/// Category Form Bottom Sheet
class _CategoryFormSheet extends StatefulWidget {
  final Category? category;

  const _CategoryFormSheet({this.category});

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  int _selectedColorIndex = 0;
  int _selectedIconIndex = 0;

  final List<Color> _colors = const [
    Color(0xFF2563EB), // Blue
    Color(0xFF7C3AED), // Violet
    Color(0xFF10B981), // Green
    Color(0xFFEF4444), // Red
    Color(0xFFF59E0B), // Orange
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEC4899), // Pink
    Color(0xFF6366F1), // Indigo
  ];

  final List<IconData> _icons = const [
    Icons.work_outline,
    Icons.person_outline,
    Icons.shopping_cart_outlined,
    Icons.favorite_border,
    Icons.home_outlined,
    Icons.school_outlined,
    Icons.fitness_center,
    Icons.attach_money,
  ];

  bool get isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      // Find matching color and icon indices
      for (int i = 0; i < _colors.length; i++) {
        if (_colors[i].toARGB32() == widget.category!.color.toARGB32()) {
          _selectedColorIndex = i;
          break;
        }
      }
      for (int i = 0; i < _icons.length; i++) {
        if (_icons[i].codePoint == widget.category!.icon.codePoint) {
          _selectedIconIndex = i;
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final loc = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Title
                Text(
                  isEditing
                      ? loc.get('edit_category')
                      : loc.get('new_category'),
                  style: theme.textTheme.headlineMedium,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: loc.get('category_name'),
                    hintText: loc.get('category_hint'),
                  ),
                  textCapitalization: TextCapitalization.words,
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return loc.get('enter_name_error');
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // Color Picker
                Text(loc.get('color'), style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: List.generate(_colors.length, (index) {
                    final isSelected = _selectedColorIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColorIndex = index),
                      child: AnimatedContainer(
                        duration: AppDurations.fast,
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _colors[index],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.onSurface
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  }),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Icon Picker
                Text(loc.get('icon'), style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: List.generate(_icons.length, (index) {
                    final isSelected = _selectedIconIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIconIndex = index),
                      child: AnimatedContainer(
                        duration: AppDurations.fast,
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _colors[_selectedColorIndex].withAlpha(30)
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: isSelected
                                ? _colors[_selectedColorIndex]
                                : theme.colorScheme.outline,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          _icons[index],
                          color: isSelected
                              ? _colors[_selectedColorIndex]
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Save Button
                FilledButton(
                  onPressed: _saveCategory,
                  child: Text(
                    isEditing ? loc.get('update') : loc.get('create'),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;
    final loc = AppLocalizations.of(context)!;
    final categoryProvider = context.read<CategoryProvider>();

    if (isEditing) {
      final updated = widget.category!.copyWith(
        name: _nameController.text.trim(),
        colorValue: _colors[_selectedColorIndex].toARGB32(),
        iconCode: _icons[_selectedIconIndex].codePoint,
      );
      await categoryProvider.updateCategory(updated);
    } else {
      final newCategory = Category(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        colorValue: _colors[_selectedColorIndex].toARGB32(),
        iconCode: _icons[_selectedIconIndex].codePoint,
      );
      await categoryProvider.addCategory(newCategory);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? loc.get('category_updated')
                : loc.get('category_created'),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
