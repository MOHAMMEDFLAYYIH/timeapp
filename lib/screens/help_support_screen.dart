import 'package:flutter/material.dart';
import '../app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              // FAQ Section
              _buildSectionHeader(theme, 'Frequently Asked Questions'),
              const SizedBox(height: AppSpacing.sm),
              _buildFAQItem(
                theme: theme,
                question: 'How do I create a new task?',
                answer:
                    'Tap the + button at the bottom of the screen or in the task list. Fill in the task details and tap Save.',
              ),
              _buildFAQItem(
                theme: theme,
                question: 'How do I mark a task as complete?',
                answer:
                    'Tap the checkbox next to the task, or swipe the task to the right to mark it as complete.',
              ),
              _buildFAQItem(
                theme: theme,
                question: 'How do I create categories?',
                answer:
                    'Go to Categories screen and tap the + button. Enter a name and choose a color for your new category.',
              ),
              _buildFAQItem(
                theme: theme,
                question: 'How do I delete a task?',
                answer:
                    'Swipe the task to the left to delete it, or long press and select Delete from the menu.',
              ),
              _buildFAQItem(
                theme: theme,
                question: 'Is my data backed up?',
                answer:
                    'Currently, data is stored locally on your device. We recommend regular device backups to protect your data.',
              ),

              const SizedBox(height: AppSpacing.xl),

              // Contact Section
              _buildSectionHeader(theme, 'Contact Support'),
              const SizedBox(height: AppSpacing.sm),
              _buildContactCard(
                theme: theme,
                icon: Icons.email_outlined,
                title: 'Email Support',
                subtitle: 'support@taskmanager.app',
                onTap: () => _showContactDialog(context, 'Email'),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildContactCard(
                theme: theme,
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Live Chat',
                subtitle: 'Available 9 AM - 6 PM',
                onTap: () => _showContactDialog(context, 'Chat'),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildContactCard(
                theme: theme,
                icon: Icons.feedback_outlined,
                title: 'Send Feedback',
                subtitle: 'Help us improve the app',
                onTap: () => _showFeedbackDialog(context, theme),
              ),

              const SizedBox(height: AppSpacing.xl),

              // App Info
              _buildSectionHeader(theme, 'App Information'),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(theme, 'Version', '1.0.0'),
                    Divider(color: theme.colorScheme.outline.withAlpha(50)),
                    _buildInfoRow(theme, 'Build', '2025.12.001'),
                    Divider(color: theme.colorScheme.outline.withAlpha(50)),
                    _buildInfoRow(theme, 'Platform', 'Flutter'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildFAQItem({
    required ThemeData theme,
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        childrenPadding: const EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.md,
        ),
        title: Text(
          question,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Text(
            answer,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 24),
        ),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact via $type'),
        content: Text(
          type == 'Email'
              ? 'Opening email client to support@taskmanager.app'
              : 'Starting live chat session...',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context, ThemeData theme) {
    final feedbackController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: TextField(
          controller: feedbackController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Tell us what you think...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Thank you for your feedback!'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
