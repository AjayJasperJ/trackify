import 'package:flutter/material.dart';
import 'package:trackify/features/task/domain/entities/task_entity.dart';
import 'package:trackify/theme/app_colors.dart';
import 'package:trackify/theme/app_form_styles.dart';
import 'package:trackify/widgets/form_section_card.dart';

class AddTaskInfoCard extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String? selectedCategory;
  final TaskPriority priority;
  final bool isPrivate;
  final List<String> categories;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<TaskPriority> onPriorityChanged;
  final ValueChanged<bool> onPrivateChanged;

  const AddTaskInfoCard({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.selectedCategory,
    required this.priority,
    required this.isPrivate,
    required this.categories,
    required this.onCategoryChanged,
    required this.onPriorityChanged,
    required this.onPrivateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      icon: Icons.info_outline,
      title: 'TASK DETAILS',
      children: [
        // Task Name Field
        TextFormField(
          controller: titleController,
          style: const TextStyle(color: AppFormStyles.textColor, fontSize: 14),
          decoration: AppFormStyles.input(label: 'Task Name'),
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        // Description Field
        TextFormField(
          controller: descriptionController,
          maxLines: 3,
          style: const TextStyle(color: AppFormStyles.textColor, fontSize: 14),
          decoration: AppFormStyles.input(
            label: 'Description',
            hint: 'Optional description',
          ),
        ),
        const SizedBox(height: 16),
        // Category Selector
        DropdownButtonFormField<String>(
          initialValue: selectedCategory,
          hint: const Text('Select Category'),
          decoration: AppFormStyles.input(label: 'Category'),
          items: categories
              .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
              .toList(),
          onChanged: onCategoryChanged,
        ),
        const SizedBox(height: 16),
        // Priority Selector
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Priority',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildPriorityBtn('None', TaskPriority.none),
                  _buildPriorityBtn('Low', TaskPriority.low),
                  _buildPriorityBtn('Med', TaskPriority.medium),
                  _buildPriorityBtn('High', TaskPriority.high),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Private Switch Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Private Task',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppFormStyles.textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Friends cannot see this task or activity',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isPrivate,
              onChanged: onPrivateChanged,
              activeThumbColor: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityBtn(String text, TaskPriority val) {
    final isSelected = priority == val;

    final Color selectedBgColor = switch (val) {
      TaskPriority.none => AppColors.onSurfaceVariant.withValues(alpha: 0.12),
      TaskPriority.low => const Color(0xFF107C10).withValues(alpha: 0.12),
      TaskPriority.medium => const Color(0xFFD97706).withValues(alpha: 0.12),
      TaskPriority.high => const Color(0xFFDC2626).withValues(alpha: 0.12),
    };

    final Color selectedTextColor = switch (val) {
      TaskPriority.none => AppColors.onSurfaceVariant,
      TaskPriority.low => const Color(0xFF107C10),
      TaskPriority.medium => const Color(0xFFD97706),
      TaskPriority.high => const Color(0xFFDC2626),
    };

    final Color selectedBorderColor = switch (val) {
      TaskPriority.none => AppColors.onSurfaceVariant.withValues(alpha: 0.4),
      TaskPriority.low => const Color(0xFF107C10).withValues(alpha: 0.4),
      TaskPriority.medium => const Color(0xFFD97706).withValues(alpha: 0.4),
      TaskPriority.high => const Color(0xFFDC2626).withValues(alpha: 0.4),
    };

    return Expanded(
      child: GestureDetector(
        onTap: () => onPriorityChanged(val),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? selectedBgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? selectedBorderColor : Colors.transparent,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? selectedTextColor : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
