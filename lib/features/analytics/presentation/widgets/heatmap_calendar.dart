import 'package:flutter/material.dart';

class HeatMapCalendar extends StatelessWidget {
  final Map<DateTime, int> data; // mapping day to intensity (0 to 4 usually)
  final String title;

  const HeatMapCalendar({super.key, required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    // A simplified heatmap showing the last 30 days
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
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
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          // We will render a simple grid of 7 rows (days of week) x roughly 4-5 cols
          SizedBox(
            height: 120,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, // 7 days a week
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: 30, // Last 30 days
              itemBuilder: (context, index) {
                // days ago
                final daysAgo = 29 - index;
                final date = today.subtract(Duration(days: daysAgo));
                // normalize date to remove time
                final normalizedDate = DateTime(date.year, date.month, date.day);
                
                final intensity = data[normalizedDate] ?? 0;
                
                Color blockColor;
                if (intensity == 0) {
                  blockColor = Theme.of(context).colorScheme.surfaceContainerHighest;
                } else if (intensity == 1) {
                  blockColor = Colors.green.shade300;
                } else if (intensity == 2) {
                  blockColor = Colors.green.shade500;
                } else if (intensity == 3) {
                  blockColor = Colors.green.shade700;
                } else {
                  blockColor = Colors.green.shade900;
                }
                
                return Tooltip(
                  message: '${date.month}/${date.day}: $intensity completions',
                  child: Container(
                    decoration: BoxDecoration(
                      color: blockColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
