import 'package:flutter/material.dart';
import 'create_goal_section_card.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_form_styles.dart';
import '../../../../../theme/app_categories.dart';

// ── Widget ─────────────────────────────────────────────────────────────────────
class CreateGoalInfoCard extends StatelessWidget {
  final TextEditingController goalNameController;
  final TextEditingController descController;
  final TextEditingController categoryController;
  final int selectedPriority;
  final bool isPrivate;
  final ValueChanged<int> onPriorityChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<bool> onPrivateChanged;
  const CreateGoalInfoCard({
    super.key,
    required this.goalNameController,
    required this.descController,
    required this.categoryController,
    required this.selectedPriority,
    required this.isPrivate,
    required this.onPriorityChanged,
    required this.onCategoryChanged,
    required this.onPrivateChanged,
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
                initialValue: AppCategories.values.contains(categoryController.text)
                    ? categoryController.text
                    : AppCategories.defaultCategory,
                isExpanded: true,
                decoration: AppFormStyles.input(label: 'Category'),
                items: AppCategories.values
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
                    'Private Goal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppFormStyles.textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Friends cannot see this goal or its tasks',
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

    final Color selectedBgColor = switch (index) {
      0 => const Color(0xFF107C10).withValues(alpha: 0.12), // Low (Soft Green)
      1 => const Color(0xFFD97706).withValues(alpha: 0.12), // Med (Soft Amber)
      2 => const Color(0xFFDC2626).withValues(alpha: 0.12), // High (Soft Red)
      _ => const Color(0xFF8B5CF6).withValues(alpha: 0.12), // Crit (Soft Purple)
    };

    final Color selectedTextColor = switch (index) {
      0 => const Color(0xFF107C10),
      1 => const Color(0xFFD97706),
      2 => const Color(0xFFDC2626),
      _ => const Color(0xFF8B5CF6),
    };

    final Color selectedBorderColor = switch (index) {
      0 => const Color(0xFF107C10).withValues(alpha: 0.4),
      1 => const Color(0xFFD97706).withValues(alpha: 0.4),
      2 => const Color(0xFFDC2626).withValues(alpha: 0.4),
      _ => const Color(0xFF8B5CF6).withValues(alpha: 0.4),
    };

    return Expanded(
      child: GestureDetector(
        onTap: () => onPriorityChanged(index),
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
                color: isSelected
                    ? selectedTextColor
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
