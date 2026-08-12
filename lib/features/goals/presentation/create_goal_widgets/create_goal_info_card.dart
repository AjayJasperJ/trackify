import 'package:flutter/material.dart';
import 'create_goal_section_card.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_form_styles.dart';

// ── Widget ─────────────────────────────────────────────────────────────────────
class CreateGoalInfoCard extends StatelessWidget {
  final TextEditingController goalNameController;
  final TextEditingController descController;
  final TextEditingController categoryController;
  final int selectedPriority;
  final ValueChanged<int> onPriorityChanged;
  final ValueChanged<String> onCategoryChanged;
  const CreateGoalInfoCard({
    super.key,
    required this.goalNameController,
    required this.descController,
    required this.categoryController,
    required this.selectedPriority,
    required this.onPriorityChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {

    return CreateGoalSectionCard(
      icon: Icons.info,
      title: 'Goal Information',
      children: [
        _buildTextField(
          'Goal Name',
          'e.g. Master React Framework',
          controller: goalNameController,
          isLarge: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Description',
          'What does success look like?',
          controller: descController,
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: const [
                  'Professional',
                  'Health',
                  'Personal',
                  'Finance'
                ].contains(categoryController.text)
                    ? categoryController.text
                    : 'Professional',
                isExpanded: true,
                decoration: AppFormStyles.input(label: 'Category'),
                items: ['Professional', 'Health', 'Personal', 'Finance']
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onCategoryChanged(v);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Priority',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 44,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildPriorityBtn('Low', 0),
                        _buildPriorityBtn('Med', 1),
                        _buildPriorityBtn('High', 2),
                        _buildPriorityBtn('Crit', 3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    TextEditingController? controller,
    bool isLarge = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style:
          TextStyle(fontSize: isLarge ? 16 : 14, color: AppColors.onSurface),
      decoration: AppFormStyles.input(
        label: label,
        hint: hint,
      ),
    );
  }

  Widget _buildPriorityBtn(String text, int index) {
    final isSelected = selectedPriority == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onPriorityChanged(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.surfaceContainerHighest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? AppColors.onSurface
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
