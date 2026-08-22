import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../progression/providers/progression_providers.dart';
import '../../../task/providers/task_state_providers.dart';

class DashboardAnalyticsGrid extends ConsumerWidget {
  const DashboardAnalyticsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayRecordState = ref.watch(todayRecordStreamProvider);
    final progressionState = ref.watch(currentProgressionProvider);

    final todayRecord = todayRecordState.value;
    final progression = progressionState.value;

    final tasksDone =
        todayRecord?.completedTasks.values.where((t) => t.completed).length ?? 0;
    final dayStreak = progression?.currentStreak ?? 0;
    final focusScore = progression?.focusScore ?? 0.0;

    return Row(
      spacing: 16,
      children: [
        Expanded(
          child: _DashboardAnalyticsCard(
            icon: Icons.task_alt_rounded,
            label: 'Activity',
            value: '$tasksDone',
            subText: 'Tasks Done',
          ),
        ),
        Expanded(
          child: _DashboardAnalyticsCard(
            icon: Icons.local_fire_department_outlined,
            label: 'Momentum',
            value: '$dayStreak',
            subText: 'Day Streak',
          ),
        ),
        Expanded(
          child: _DashboardAnalyticsCard(
            icon: Icons.psychology_outlined,
            label: 'Focus',
            value: '${focusScore.toInt()}%',
            subText: 'Focus Score',
          ),
        ),
      ],
    );
  }
}

class _DashboardAnalyticsCard extends ConsumerWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subText;

  const _DashboardAnalyticsCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}