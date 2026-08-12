import 'package:flutter/material.dart';

class ViewTaskHeatmap extends StatelessWidget {
  final List<double> heatmapData;
  final Color onSurface;
  final Color primary;
  final Color surfaceContainerLow;
  final Color surfaceVariant;
  final Color secondary;

  const ViewTaskHeatmap({
    super.key,
    required this.heatmapData,
    required this.onSurface,
    required this.primary,
    required this.surfaceContainerLow,
    required this.surfaceVariant,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Consistency',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: onSurface,
                ),
              ),
              Text(
                'Last 30 Days',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 10,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    final opacity = heatmapData[index];
                    Color cellColor;
                    if (opacity > 0.8) {
                      cellColor = primary;
                    } else if (opacity > 0.5) {
                      cellColor = primary.withValues(alpha: 0.6);
                    } else if (opacity > 0.2) {
                      cellColor = primary.withValues(alpha: 0.2);
                    } else {
                      cellColor = surfaceVariant;
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: cellColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Less consistent',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: secondary,
                      ),
                    ),
                    Text(
                      'More consistent',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
