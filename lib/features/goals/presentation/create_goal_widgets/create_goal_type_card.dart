import 'package:flutter/material.dart';
import '../controllers/goal_editor_controller.dart' show GoalType;
import 'create_goal_section_card.dart';
import '../../../../../theme/app_colors.dart';

class CreateGoalTypeCard extends StatelessWidget {
  final GoalType selectedGoalType;
  final ValueChanged<GoalType> onGoalTypeChanged;
  // Date goal
  final DateTime? selectedDate;
  final ValueChanged<DateTime?>? onDateChanged;
  
  // Duration goal
  final int? durationDays;
  final ValueChanged<int?>? onDurationDaysChanged;

  final bool isStrict;
  final ValueChanged<bool> onStrictChanged;

  const CreateGoalTypeCard({
    super.key,
    required this.selectedGoalType,
    required this.onGoalTypeChanged,
    required this.isStrict,
    required this.onStrictChanged,
    this.selectedDate,
    this.onDateChanged,
    this.durationDays,
    this.onDurationDaysChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CreateGoalSectionCard(
      icon: Icons.track_changes,
      title: 'Goal Type',
      children: [
        _buildTypeOption('Open-ended Goal', 'Ongoing progress', GoalType.open),
        const SizedBox(height: 8),
        _buildTypeOption('Target Date Goal', 'Fixed deadline', GoalType.date),
        const SizedBox(height: 8),
        _buildTypeOption('Duration Goal', 'Track for X days', GoalType.duration),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: selectedGoalType == GoalType.open
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: _buildDynamicGoalTypeOptions(context),
                ),
        ),
        const SizedBox(height: 16),
        _buildStrictModeToggle(),
      ],
    );
  }

  Widget _buildTypeOption(String title, String subtitle, GoalType type) {
    final isSelected = selectedGoalType == type;
    return GestureDetector(
      onTap: () => onGoalTypeChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: AppColors.primary,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicGoalTypeOptions(BuildContext context) {
    if (selectedGoalType == GoalType.duration) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goal Duration (Days)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: durationDays?.toString(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g., 90',
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (val) {
                final days = int.tryParse(val);
                onDurationDaysChanged?.call(days);
              },
            ),
          ],
        ),
      );
    }

    final label = selectedDate != null
        ? '${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.year}'
        : 'mm/dd/yyyy';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Deadline',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (picked != null) onDateChanged?.call(picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: selectedDate != null
                            ? AppColors.onSurface
                            : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrictModeToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.gavel, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Strict Mode',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'Cannot be deleted or closed early. High XP rewards.',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isStrict,
            onChanged: onStrictChanged,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
