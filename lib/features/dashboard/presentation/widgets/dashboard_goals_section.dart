import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../goals/providers/goal_providers.dart';

class DashboardGoalsSection extends ConsumerWidget {
  const DashboardGoalsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsState = ref.watch(goalsStreamProvider);
    final goals = goalsState.value ?? [];

    final displayGoals = goals.take(2).toList();
    final onSurface = const Color(0xFF1B1C1C);
    final secondary = const Color(0xFF5E5E5E);
    final primary = const Color(0xFF005396);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Active Goals",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: onSurface,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                "View All",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (displayGoals.isEmpty)
          Text('No active goals.', style: TextStyle(color: secondary)),
        if (displayGoals.isNotEmpty)
          Row(
            children: [
              Expanded(
                child: displayGoals.isNotEmpty
                    ? InteractiveGoalCard(
                        title: displayGoals[0].title,
                        progressText:
                            '${displayGoals[0].currentAmount.toInt()}/${displayGoals[0].targetAmount.toInt()} ${displayGoals[0].unit}',
                        percentage: (displayGoals[0].progress * 100).toInt(),
                        progressValue: displayGoals[0].progress,
                      )
                    : const SizedBox(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: displayGoals.length > 1
                    ? InteractiveGoalCard(
                        title: displayGoals[1].title,
                        progressText:
                            '${displayGoals[1].currentAmount.toInt()}/${displayGoals[1].targetAmount.toInt()} ${displayGoals[1].unit}',
                        percentage: (displayGoals[1].progress * 100).toInt(),
                        progressValue: displayGoals[1].progress,
                      )
                    : const SizedBox(),
              ),
            ],
          ),
      ],
    );
  }
}

class InteractiveGoalCard extends StatefulWidget {
  final String title, progressText;
  final int percentage;
  final double progressValue;
  const InteractiveGoalCard({
    super.key,
    required this.title,
    required this.progressText,
    required this.percentage,
    required this.progressValue,
  });
  @override
  State<InteractiveGoalCard> createState() => _InteractiveGoalCardState();
}

class _InteractiveGoalCardState extends State<InteractiveGoalCard> {
  bool isPressed = false;
  final Color surface = const Color(0xFFFCF9F8);
  final Color outlineVariant = const Color(0xFFC1C7D3);
  final Color onSurface = const Color(0xFF1B1C1C);
  final Color secondary = const Color(0xFF5E5E5E);
  final Color secondaryContainer = const Color(0xFFE1DFDF);
  final Color primary = const Color(0xFF005396);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      child: AnimatedScale(
        scale: isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: outlineVariant.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 6,
                      color: secondaryContainer,
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0.0,
                        end: widget.progressValue,
                      ),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return CircularProgressIndicator(
                          value: value,
                          strokeWidth: 6,
                          color: primary,
                          backgroundColor: Colors.transparent,
                        );
                      },
                    ),
                    Center(
                      child: Text(
                        '${widget.percentage}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.24,
                  color: onSurface,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.progressText,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
