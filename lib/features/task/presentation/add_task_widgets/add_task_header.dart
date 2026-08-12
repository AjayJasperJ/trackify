import 'package:flutter/material.dart';
import 'package:trackify/theme/app_colors.dart';

/// Screen header for the add/edit task form: primary-accent section label
/// (matching the dashboard's "Today's Tasks" / "Active Goals" headers) plus
/// a short helper line describing the screen.
class AddTaskHeader extends StatelessWidget {
  final bool isEditing;

  const AddTaskHeader({
    super.key,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.add_task, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              isEditing ? 'EDIT TASK' : 'CREATE TASK',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          isEditing
              ? "Update your existing action details."
              : "Create an action you'll complete regularly.",
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
