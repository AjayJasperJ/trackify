// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:trackify/features/goals/domain/entities/goal_entity.dart';
import 'package:trackify/features/goals/domain/entities/milestone_entity.dart';
import 'package:trackify/theme/app_form_styles.dart';
import 'package:trackify/widgets/form_section_card.dart';

class AddTaskLinkGoalCard extends StatelessWidget {
  final GoalEntity? selectedGoal;
  final MilestoneEntity? selectedMilestone;
  final List<GoalEntity> goals;
  final List<MilestoneEntity> milestones;

  /// IDs of the currently selected goal/milestone. Used instead of the
  /// entity values for dropdown matching: in edit mode the selected entities
  /// are prefetched (different object instances than the stream ones), so
  /// identity-based matching would fail to show them as selected.
  final String? selectedGoalId;
  final String? selectedMilestoneId;

  final ValueChanged<GoalEntity?> onGoalChanged;
  final ValueChanged<MilestoneEntity?> onMilestoneChanged;

  const AddTaskLinkGoalCard({
    super.key,
    required this.selectedGoal,
    required this.selectedMilestone,
    required this.goals,
    required this.milestones,
    this.selectedGoalId,
    this.selectedMilestoneId,
    required this.onGoalChanged,
    required this.onMilestoneChanged,
  });

  /// Stream instance matching the selected ID, or null when nothing is
  /// selected / the item isn't in the list yet (stream still loading).
  /// Never throws.
  GoalEntity? _goalValue() {
    if (goals.isEmpty) return null;
    final id = selectedGoalId ?? selectedGoal?.goalId;
    if (id == null) return null;
    for (final g in goals) {
      if (g.goalId == id) return g;
    }
    return null;
  }

  MilestoneEntity? _milestoneValue() {
    if (milestones.isEmpty) return null;
    final id = selectedMilestoneId ?? selectedMilestone?.milestoneId;
    if (id == null) return null;
    for (final m in milestones) {
      if (m.milestoneId == id) return m;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final goalValue = _goalValue();

    return FormSectionCard(
      icon: Icons.flag_outlined,
      title: 'LINK TO GOAL',
      children: [
        // Goal dropdown. `value:` is deprecated in Flutter 3.44 in favor of
        // `initialValue:`, but initialValue only applies on first mount —
        // if the goals stream is still loading when this builds, the value
        // would lock to null and prefill would never appear. Keeping `value:`
        // is the ponytail-correct call: it stays live-updating and matches
        // the milestone dropdown's remount strategy below.
        DropdownButtonFormField<GoalEntity>(
          value: goalValue,
          hint: const Text('Select a Goal'),
          isExpanded: true,
          decoration: AppFormStyles.input(label: 'Goal'),
          items: [
            const DropdownMenuItem<GoalEntity>(
              value: null,
              child: Text('None'),
            ),
            ...goals.map(
              (g) => DropdownMenuItem(value: g, child: Text(g.title)),
            ),
          ],
          onChanged: onGoalChanged,
        ),
        if (selectedGoal != null) ...[
          const SizedBox(height: 16),
          // `value:` (not `initialValue:`) — a live-updating dropdown. The
          // initialValue + remount-key pattern breaks edit-mode prefill: the
          // milestone stream often resolves AFTER this field first mounts,
          // and initialValue locks the stale null forever. `value:` re-applies
          // whenever the stream/list changes, so the prefilled milestone
          // appears the moment its stream data lands. (Deprecation is a
          // cosmetic info lint; correctness wins.)
          DropdownButtonFormField<MilestoneEntity>(
            value: _milestoneValue(),
            hint: const Text('Select a Milestone'),
            isExpanded: true,
            decoration: AppFormStyles.input(label: 'Milestone'),
            items: [
              const DropdownMenuItem<MilestoneEntity>(
                value: null,
                child: Text('None'),
              ),
              ...milestones.map(
                (m) => DropdownMenuItem(value: m, child: Text(m.title)),
              ),
            ],
            onChanged: onMilestoneChanged,
          ),
        ],
      ],
    );
  }
}
