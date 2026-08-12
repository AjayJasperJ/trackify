import 'package:flutter/material.dart';

class TaskComparisonCard extends StatelessWidget {
  /// 0.0 to 1.0 — today's task completion rate from analytics summary.
  final double completionRate;

  const TaskComparisonCard({super.key, required this.completionRate});

  @override
  Widget build(BuildContext context) {
    final pct = (completionRate * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _stat(context, '$pct%', 'Completed', Colors.green),
              _stat(context, '${100 - pct}%', 'Remaining',
                  Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: completionRate.clamp(0.0, 1.0),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            color: Colors.green,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
