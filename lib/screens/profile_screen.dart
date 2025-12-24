import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../main.dart'; // For ThemeModeProvider
import '../providers/settings_provider.dart';
import '../widgets/theme_toggle_button.dart';
import 'edit_profile_screen.dart';
import 'privacy_policy_screen.dart';
import 'help_support_screen.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeModeProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = theme.brightness == Brightness.dark;

    // Check if context has access to localizations, otherwise fallback/handle error
    // In a properly set up app with MaterialApp localizations configured, this should not be null.
    final loc = AppLocalizations.of(context);
    if (loc == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.get('settings')),
        actions: const [ThemeToggleButton()],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth >= AppBreakpoints.mobile;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: EdgeInsets.all(
                  isWideScreen ? AppSpacing.lg : AppSpacing.md,
                ),
                children: [
                  // Compact Profile Header
                  _buildProfileHeader(context, theme, settingsProvider),

                  const SizedBox(height: AppSpacing.lg),

                  // Appearance Section
                  _buildSectionLabel(theme, loc.get('appearance')),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSettingsCard(
                    theme: theme,
                    children: [
                      _buildAnimatedSwitchTile(
                        theme: theme,
                        icon: isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        title: loc.get('dark_mode'),
                        subtitle: isDark ? loc.get('on') : loc.get('off'),
                        value: isDark,
                        onChanged: (_) => themeProvider.toggleTheme(),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Preferences Section
                  _buildSectionLabel(theme, loc.get('preferences')),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSettingsCard(
                    theme: theme,
                    children: [
                      _buildNavigationTile(
                        context: context,
                        theme: theme,
                        icon: Icons.language_rounded,
                        title: loc.get('language'),
                        subtitle: settingsProvider.locale.languageCode == 'ar'
                            ? 'العربية'
                            : 'English',
                        onTap: () =>
                            _showLanguageSheet(context, settingsProvider),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // About Section
                  _buildSectionLabel(theme, loc.get('about')),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSettingsCard(
                    theme: theme,
                    children: [
                      _buildInfoTile(
                        theme: theme,
                        icon: Icons.info_outline_rounded,
                        title: loc.get('version'),
                        trailing: Text(
                          '1.0.0',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: theme.colorScheme.outline.withAlpha(50),
                      ),
                      _buildNavigationTile(
                        context: context,
                        theme: theme,
                        icon: Icons.privacy_tip_outlined,
                        title: loc.get('privacy_policy'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: theme.colorScheme.outline.withAlpha(50),
                      ),
                      _buildNavigationTile(
                        context: context,
                        theme: theme,
                        icon: Icons.help_outline_rounded,
                        title: loc.get('help_support'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HelpSupportScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Log Out - Outline style for destructive action
                  OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context, theme),
                    icon: Icon(Icons.logout_rounded, color: theme.error),
                    label: Text(
                      loc.get('log_out'),
                      style: TextStyle(color: theme.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.error.withAlpha(100)),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    ThemeData theme,
    SettingsProvider settings,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withAlpha(30),
                  theme.colorScheme.primary.withAlpha(15),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withAlpha(50),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.person_rounded,
              size: 28,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settings.userName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  settings.userEmail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(ThemeData theme, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required ThemeData theme,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildAnimatedSwitchTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: theme.colorScheme.primary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    );
  }

  Widget _buildNavigationTile({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    );
  }

  Widget _buildInfoTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required Widget trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      title: Text(title),
      trailing: trailing,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    );
  }

  void _showLanguageSheet(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  loc.get('select_language'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ListTile(
                leading: settingsProvider.locale.languageCode == 'en'
                    ? Icon(
                        Icons.check_rounded,
                        color: theme.colorScheme.primary,
                      )
                    : const SizedBox(width: 24),
                title: const Text('English'),
                onTap: () {
                  settingsProvider.setLanguage(const Locale('en'));
                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: settingsProvider.locale.languageCode == 'ar'
                    ? Icon(
                        Icons.check_rounded,
                        color: theme.colorScheme.primary,
                      )
                    : const SizedBox(width: 24),
                title: const Text('العربية'),
                onTap: () {
                  settingsProvider.setLanguage(const Locale('ar'));
                  Navigator.pop(sheetContext);
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, ThemeData theme) {
    final loc = AppLocalizations.of(context);
    // Safety check just in case, though build() checks too
    if (loc == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.get('log_out')),
        content: Text(loc.get('log_out_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.get('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: theme.error),
            child: Text(loc.get('log_out')),
          ),
        ],
      ),
    );
  }
}
