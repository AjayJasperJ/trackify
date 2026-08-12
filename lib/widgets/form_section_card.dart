import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_form_styles.dart';

/// Uniform card used by every add/edit form section (task, goal, milestone):
/// icon + primary label header, white rounded-12 body.
class FormSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? action;
  final List<Widget> children;

  const FormSectionCard({
    super.key,
    required this.icon,
    required this.title,
    this.action,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppFormStyles.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              ?action,
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
