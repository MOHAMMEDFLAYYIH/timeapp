import 'package:flutter/material.dart';
import '../app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _buildSection(
                theme: theme,
                title: 'Introduction',
                content:
                    'Welcome to Task Manager. We are committed to protecting your privacy and ensuring complete transparency about how we handle your data.',
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSection(
                theme: theme,
                title: 'Data Collection',
                content:
                    'Task Manager stores all your data locally on your device. We do not collect, store, or transmit any personal information to external servers. Your tasks, categories, and settings remain private on your device.',
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSection(
                theme: theme,
                title: 'Local Storage',
                content:
                    'We use Hive database for local storage to keep your tasks and settings. This data is stored only on your device and is not accessible by anyone else.',
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSection(
                theme: theme,
                title: 'Notifications',
                content:
                    'If you enable push notifications, they are handled locally on your device by the operating system. We do not have access to your notification data.',
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSection(
                theme: theme,
                title: 'Data Security',
                content:
                    'Your data security is important to us. All data remains on your device and is protected by your device\'s security features (password, biometrics, etc.).',
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSection(
                theme: theme,
                title: 'Changes to Privacy Policy',
                content:
                    'We may update this privacy policy from time to time. Any changes will be reflected in the app update.',
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSection(
                theme: theme,
                title: 'Contact Us',
                content:
                    'If you have any questions about this privacy policy, please contact us at support@taskmanager.app',
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Last updated: December 2025',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required String title,
    required String content,
  }) {
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
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
