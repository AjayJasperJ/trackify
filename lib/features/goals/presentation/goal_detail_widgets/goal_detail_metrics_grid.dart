import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/goal_entity.dart';

class GoalDetailMetricsGrid extends StatelessWidget {
  final GoalEntity goal;
  final Color surfaceContainerLow;
  final Color primary;
  final Color onSurface;
  final Color secondary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  const GoalDetailMetricsGrid({
    super.key,
    required this.goal,
    required this.surfaceContainerLow,
    required this.primary,
    required this.onSurface,
    required this.secondary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    int daysLeft = 0;
    if (goal.targetDate != null) {
      daysLeft = goal.targetDate!.difference(DateTime.now()).inDays;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bolt, size: 18, color: primary),
                          const SizedBox(width: 4),
                          const Text('TARGET XP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${goal.targetXP}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onSurface)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 18, color: secondary),
                          const SizedBox(width: 4),
                          const Text('DEADLINE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(goal.targetDate != null ? dateFormat.format(goal.targetDate!) : 'No Date', 
                           style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onSurface)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (goal.targetDate != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: primaryContainer, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ESTIMATED COMPLETION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: onPrimaryContainer.withValues(alpha: 0.8))),
                      const SizedBox(height: 4),
                      Text(daysLeft >= 0 ? 'In $daysLeft Days' : '${daysLeft.abs()} Days Overdue', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onPrimaryContainer)),
                    ],
                  ),
                  Icon(Icons.insights, size: 32, color: onPrimaryContainer.withValues(alpha: 0.2)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
