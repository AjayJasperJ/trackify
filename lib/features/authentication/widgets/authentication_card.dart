import 'package:flutter/material.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_elevation.dart';

class AuthenticationCard extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const AuthenticationCard({
    super.key,
    required this.child,
    this.maxWidth = 420,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 600;

    Widget content = Padding(
      padding: const EdgeInsets.all(AppSpacing.s32),
      child: child,
    );

    if (isDesktop) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: AppElevation.minimal,
            ),
            child: content,
          ),
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: content,
      ),
    );
  }
}
