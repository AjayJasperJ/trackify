import 'package:flutter/material.dart';
import '../../../theme/app_spacing.dart';

class AuthenticationHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthenticationHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline, size: 48), // Replace with App Logo
        const SizedBox(height: AppSpacing.s24),
        Text(
          title,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.s8),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: AppSpacing.s32),
      ],
    );
  }
}
