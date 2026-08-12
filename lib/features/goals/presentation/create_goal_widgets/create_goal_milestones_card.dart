import 'package:flutter/material.dart';
import '../../domain/entities/milestone_entity.dart';

import 'create_goal_section_card.dart';

import '../../../../../theme/app_colors.dart';

class CreateGoalMilestonesCard extends StatelessWidget {
  final List<MilestoneEntity> milestones;
  final VoidCallback onAddMilestone;
  final ValueChanged<int> onRemoveMilestone;

  const CreateGoalMilestonesCard({
    super.key,
    required this.milestones,
    required this.onAddMilestone,
    required this.onRemoveMilestone,
  });

  @override
  Widget build(BuildContext context) {
    return CreateGoalSectionCard(
      icon: Icons.star,
      title: 'Milestones',
      action: GestureDetector(
        onTap: onAddMilestone,
        child: Row(
          children: [
            Icon(Icons.add, size: 18, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              'Add',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
      children: [
        ...List.generate(milestones.length, (idx) {
          final ms = milestones[idx];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${idx + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                ms.title,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                            if (ms.targetValue != null)
                              Text(
                                '${ms.targetValue} XP',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            GestureDetector(
                              onTap: () => onRemoveMilestone(idx),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        if (ms.description.isNotEmpty)
                          Text(
                            ms.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        Opacity(
          opacity: 0.6,
          child: InkWell(
            onTap: onAddMilestone,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${milestones.length + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'New Milestone...',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
