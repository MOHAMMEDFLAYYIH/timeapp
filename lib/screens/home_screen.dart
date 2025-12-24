import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../l10n/app_localizations.dart';
import 'task_list_screen.dart';
import 'category_management_screen.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';

/// Responsive Home Screen with Adaptive Navigation
///
/// Features:
/// - Mobile (< 600px): Bottom NavigationBar
/// - Tablet/Desktop (≥ 600px): NavigationRail on left side
/// - Smooth page transitions
/// - Safe area awareness
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  /// Screens corresponding to each navigation destination
  final List<Widget> _screens = const [
    TaskListScreen(),
    CategoryManagementScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  List<NavigationItem> _getNavigationItems(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
      NavigationItem(
        icon: Icons.check_box_outlined,
        selectedIcon: Icons.check_box,
        label: loc.get('nav_tasks'),
      ),
      NavigationItem(
        icon: Icons.folder_outlined,
        selectedIcon: Icons.folder,
        label: loc.get('nav_categories'),
      ),
      NavigationItem(
        icon: Icons.analytics_outlined,
        selectedIcon: Icons.analytics,
        label: loc.get('nav_analytics'),
      ),
      NavigationItem(
        icon: Icons.person_2_outlined,
        selectedIcon: Icons.person_2,
        label: loc.get('nav_settings'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= AppBreakpoints.mobile;

        if (isWideScreen) {
          return _buildWideScreenLayout(context, constraints);
        } else {
          return _buildMobileLayout(context);
        }
      },
    );
  }

  /// Mobile layout with bottom NavigationBar
  Widget _buildMobileLayout(BuildContext context) {
    final theme = Theme.of(context);
    final navItems = _getNavigationItems(context);

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: AppDurations.normal,
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: theme.colorScheme.outline, width: 0.5),
          ),
        ),
        child: SafeArea(
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: navItems
                .map(
                  (item) => NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: item.label,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  /// Wide screen layout with NavigationRail on the left
  Widget _buildWideScreenLayout(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final theme = Theme.of(context);
    final isDesktop = constraints.maxWidth >= AppBreakpoints.tablet;
    final navItems = _getNavigationItems(context);

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Navigation Rail
            Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: theme.colorScheme.outline,
                    width: 0.5,
                  ),
                ),
              ),
              child: NavigationRail(
                selectedIndex: _currentIndex,
                onDestinationSelected: _onDestinationSelected,
                backgroundColor: theme.colorScheme.surface,
                labelType: isDesktop
                    ? NavigationRailLabelType.all
                    : NavigationRailLabelType.selected,
                extended: false,
                minWidth: 72,
                groupAlignment: 0.0,
                indicatorColor: theme.colorScheme.primaryContainer,
                destinations: navItems
                    .map(
                      (item) => NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: Text(item.label),
                      ),
                    )
                    .toList(),
                leading: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Icon(
                    Icons.task_alt_rounded,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                ),
              ),
            ),

            // Main Content Area
            Expanded(
              child: AnimatedSwitcher(
                duration: AppDurations.normal,
                child: _screens[_currentIndex],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}

/// Data class for navigation items
class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
