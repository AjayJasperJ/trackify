import 'package:flutter/material.dart';
import 'package:trackify/features/task/domain/entities/task_entity.dart';
import 'package:trackify/theme/app_form_styles.dart';
import 'package:trackify/widgets/form_section_card.dart';

class AddTaskInfoCard extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String? selectedCategory;
  final TaskPriority priority;
  final List<String> categories;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<TaskPriority> onPriorityChanged;

  const AddTaskInfoCard({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.selectedCategory,
    required this.priority,
    required this.categories,
    required this.onCategoryChanged,
    required this.onPriorityChanged,
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
        DropdownButtonFormField<TaskPriority>(
          initialValue: priority,
          decoration: AppFormStyles.input(label: 'Priority'),
          items: const [
            DropdownMenuItem(value: TaskPriority.none, child: Text('None')),
            DropdownMenuItem(value: TaskPriority.low, child: Text('Low')),
            DropdownMenuItem(value: TaskPriority.medium, child: Text('Medium')),
            DropdownMenuItem(value: TaskPriority.high, child: Text('High')),
          ],
          onChanged: (val) {
            if (val != null) {
              onPriorityChanged(val);
            }
          },
        ),
      ],
    );
  }
}
