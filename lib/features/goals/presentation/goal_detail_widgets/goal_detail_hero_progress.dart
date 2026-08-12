import 'package:flutter/material.dart';
import '../../domain/entities/goal_entity.dart';

class GoalDetailHeroProgress extends StatelessWidget {
  final GoalEntity goal;
  final Color surfaceContainerHigh;
  final Color primary;
  final Color onSurface;
  final Color secondary;
  final Color onSurfaceVariant;

  const GoalDetailHeroProgress({
    super.key,
    required this.goal,
    required this.surfaceContainerHigh,
    required this.primary,
    required this.onSurface,
    required this.secondary,
    required this.onSurfaceVariant,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 192,
            height: 192,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 8,
                  color: surfaceContainerHigh,
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: goal.progress),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOut,
                  builder: (context, value, _) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 8,
                      color: primary,
                      backgroundColor: Colors.transparent,
                      strokeCap: StrokeCap.round,
                    );
                  }
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(goal.progress * 100).toInt()}%',
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -0.8, color: onSurface, height: 1.2),
                    ),
                    Text(
                      'COMPLETE',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.6, color: secondary),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            goal.title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: onSurface),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              goal.description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
