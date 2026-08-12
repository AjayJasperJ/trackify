import 'package:flutter/material.dart';

class MoodAnalysisCard extends StatelessWidget {
  final double averageMood;
  final String trendText;

  const MoodAnalysisCard({
    super.key,
    required this.averageMood,
    required this.trendText,
  });

  @override
  Widget build(BuildContext context) {
    IconData moodIcon;
    Color moodColor;
    String moodLabel;

    if (averageMood >= 4.5) {
      moodIcon = Icons.sentiment_very_satisfied;
      moodColor = Colors.green;
      moodLabel = 'Excellent';
    } else if (averageMood >= 3.5) {
      moodIcon = Icons.sentiment_satisfied;
      moodColor = Colors.lightGreen;
      moodLabel = 'Good';
    } else if (averageMood >= 2.5) {
      moodIcon = Icons.sentiment_neutral;
      moodColor = Colors.orange;
      moodLabel = 'Normal';
    } else if (averageMood >= 1.5) {
      moodIcon = Icons.sentiment_dissatisfied;
      moodColor = Colors.deepOrange;
      moodLabel = 'Low';
    } else {
      moodIcon = Icons.sentiment_very_dissatisfied;
      moodColor = Colors.red;
      moodLabel = 'Very Low';
    }

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
            'Mood Analysis',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: moodColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(moodIcon, color: moodColor, size: 48),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      moodLabel,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: moodColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Avg Score: \${averageMood.toStringAsFixed(1)} / 5.0',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.insights, color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    trendText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
