import 'package:flutter/material.dart';

class GoalsDashboardMotivationalSummary extends StatelessWidget {
  final Color primaryContainer;
  final Color onPrimaryContainer;

  const GoalsDashboardMotivationalSummary({
    super.key,
    required this.primaryContainer,
    required this.onPrimaryContainer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: primaryContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -8,
            bottom: -12,
            child: Opacity(
              opacity: 0.2,
              child: Icon(
                Icons.emoji_events,
                size: 84,
                color: onPrimaryContainer,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Crushing it!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.65,
                child: Text(
                  "You've completed 4 milestones today. Keep the momentum going to reach your weekly targets.",
                  style: TextStyle(
                    fontSize: 14,
                    color: onPrimaryContainer.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: onPrimaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 16,
                      color: onPrimaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+12% vs last week',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
