import 'package:flutter/material.dart';

class AllTasksProgressSummary extends StatelessWidget {
  final int totalTasks;
  final int completedTasks;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  const AllTasksProgressSummary({
    super.key,
    required this.totalTasks,
    required this.completedTasks,
    required this.primaryContainer,
    required this.onPrimaryContainer,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
    final progressInt = (progress * 100).toInt();

    return Container(
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
            bottom: -40,
            child: Opacity(
              opacity: 0.1,
              child: Icon(
                Icons.check_circle,
                size: 120,
                color: onPrimaryContainer,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Momentum",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$completedTasks of $totalTasks tasks completed",
                    style: TextStyle(
                      fontSize: 14,
                      color: onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 4,
                      color: onPrimaryContainer.withValues(alpha: 0.2),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: progress),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOut,
                      builder: (context, value, _) {
                        return CircularProgressIndicator(
                          value: value,
                          strokeWidth: 4,
                          color: onPrimaryContainer,
                          backgroundColor: Colors.transparent,
                        );
                      },
                    ),
                    Center(
                      child: Text(
                        '$progressInt%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: onPrimaryContainer,
                        ),
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
