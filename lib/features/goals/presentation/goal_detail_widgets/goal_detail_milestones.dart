import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/goal_entity.dart';
import '../../domain/entities/goal_enums.dart';
import '../../domain/entities/milestone_entity.dart';
import '../../providers/goal_providers.dart';
import '../../../authentication/providers/auth_provider.dart';

enum MilestoneState { completed, active, upcoming }

class GoalDetailMilestones extends ConsumerWidget {
  final GoalEntity currentGoal;
  final AsyncValue<List<MilestoneEntity>> milestonesAsync;
  final Color onSurface;
  final Color primary;
  final Color surface;
  final Color surfaceContainerHighest;
  final Color secondary;
  final Color onSurfaceVariant;

  const GoalDetailMilestones({
    super.key,
    required this.currentGoal,
    required this.milestonesAsync,
    required this.onSurface,
    required this.primary,
    required this.surface,
    required this.surfaceContainerHighest,
    required this.secondary,
    required this.onSurfaceVariant,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Milestones", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onSurface)),
              GestureDetector(
                onTap: () {
                  context.push(
                    '/add-milestone/${currentGoal.goalId}',
                    extra: currentGoal.goalId,
                  );
                },
                child: Text("Add New", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: primary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          milestonesAsync.when(
            data: (milestones) {
              if (milestones.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'No milestones yet.',
                      style: TextStyle(color: secondary),
                    ),
                  ),
                );
              }

              return Column(
                children: List.generate(milestones.length, (index) {
                  final m = milestones[index];
                  final isLast = index == milestones.length - 1;
                  
                  MilestoneState state = MilestoneState.upcoming;
                  final computedProgress = m.computedProgress;
                  
                  bool isCompleted = m.completed;
                  
                  // Auto-complete duration milestones if time has passed
                  if (!isCompleted && 
                      m.completionRule == MilestoneCompletionRule.duration && 
                      computedProgress >= 1.0) {
                    isCompleted = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      final user = ref.read(currentUserProvider);
                      if (user != null) {
                        final updated = m.copyWith(
                          completed: true,
                          progress: 1.0,
                          completedAt: DateTime.now(),
                        );
                        await ref.read(milestoneRepositoryProvider).updateMilestone(user.uid, updated);
                      }
                    });
                  }

                  if (isCompleted) {
                    state = MilestoneState.completed;
                  } else if (computedProgress > 0) {
                    state = MilestoneState.active;
                  }

                  String subtitle = isCompleted 
                      ? 'Completed on ${m.completedAt != null ? DateFormat('MMM d').format(m.completedAt!) : 'Unknown'}' 
                      : (computedProgress > 0 ? 'In Progress • ${(computedProgress * 100).toInt()}%' : 'Upcoming');

                  return GestureDetector(
                    onTap: () {
                      context.push(
                        '/edit-milestone/${currentGoal.goalId}',
                        extra: m,
                      );
                    },
                    onLongPress: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Milestone?'),
                          content: Text('Delete "${m.title}"?'),
                          actions: [
                            TextButton(onPressed: () => ctx.pop(false), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => ctx.pop(true),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        final user = ref.read(currentUserProvider);
                        if (user != null) {
                          await ref.read(milestoneRepositoryProvider).deleteMilestone(user.uid, currentGoal.goalId, m.milestoneId);
                          // Recalculate goal progress
                          final remaining = milestones.where((x) => x.milestoneId != m.milestoneId).toList();
                          final newProgress = remaining.isEmpty ? 0.0 : remaining.where((x) => x.completed).length / remaining.length;
                          await ref.read(goalRepositoryProvider).updateGoal(user.uid, currentGoal.copyWith(progress: newProgress));
                        }
                      }
                    },

                    child: _buildTimelineItem(
                      title: m.title,
                      subtitle: subtitle,
                      state: state,
                      isLast: isLast,
                      primary: primary,
                      surface: surface,
                      surfaceContainerHighest: surfaceContainerHighest,
                      secondary: secondary,
                      onSurface: onSurface,
                      onSurfaceVariant: onSurfaceVariant,
                      trailing: Checkbox(
                        value: isCompleted,
                        activeColor: primary,
                        onChanged: (val) async {
                          if (val != null && context.mounted) {
                            final user = ref.read(currentUserProvider);
                            if (user != null) {
                              // Manual override only makes sense for the
                              // `manual` and `duration` rule. For allTasks/targetValue the
                              // milestone completes when linked tasks do
                              // (fed via updateTaskContribution on toggle).
                              final rule = m.completionRule;
                              if (rule == MilestoneCompletionRule.manual ||
                                  rule == MilestoneCompletionRule.duration ||
                                  (val == false && !isCompleted)) {
                                final updated = m.copyWith(
                                  completed: val,
                                  progress: val ? 1.0 : (rule == MilestoneCompletionRule.duration ? m.computedProgress : 0.0),
                                  completedAt: val ? DateTime.now() : null,
                                );
                                await ref
                                    .read(milestoneRepositoryProvider)
                                    .updateMilestone(user.uid, updated);
                              }

                              final currentMilestones = milestonesAsync.value ?? [];
                              final completedCount = currentMilestones
                                  .where(
                                    (x) => x.milestoneId == m.milestoneId
                                        ? val
                                        : x.completed,
                                  )
                                  .length;
                              final totalCount = currentMilestones.length;
                              final newProgress = totalCount == 0
                                  ? 0.0
                                  : completedCount / totalCount;

                              GoalStatus newStatus = currentGoal.status;
                              if (newProgress == 1.0) {
                                newStatus = GoalStatus.completed;
                              } else if (newProgress > 0.0) {
                                newStatus = GoalStatus.active;
                              } else {
                                newStatus = GoalStatus.notStarted;
                              }

                              final updatedGoal = currentGoal.copyWith(
                                progress: newProgress,
                                status: newStatus,
                              );
                              await ref
                                  .read(goalRepositoryProvider)
                                  .updateGoal(user.uid, updatedGoal);
                            }
                          }
                        },
                      ),
                    ),
                  );
                }),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error loading milestones: $e')),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required MilestoneState state,
    required bool isLast,
    required Color primary,
    required Color surface,
    required Color surfaceContainerHighest,
    required Color secondary,
    required Color onSurface,
    required Color onSurfaceVariant,
    Widget? trailing,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                if (state == MilestoneState.completed)
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
                    child: const Icon(Icons.check, size: 14, color: Colors.white),
                  )
                else if (state == MilestoneState.active)
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(color: surface, shape: BoxShape.circle, border: Border.all(color: primary, width: 2)),
                    child: Center(
                      child: PulseDot(color: primary),
                    ),
                  )
                else
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(color: surfaceContainerHighest, shape: BoxShape.circle),
                  ),
                
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: state == MilestoneState.completed ? primary : surfaceContainerHighest,
                    ),
                  )
                else
                  const SizedBox(height: 24),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: state == MilestoneState.upcoming ? FontWeight.w400 : FontWeight.w600,
                            color: state == MilestoneState.upcoming ? secondary : onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: state == MilestoneState.active ? primary : onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PulseDot extends StatefulWidget {
  final Color color;
  const PulseDot({super.key, required this.color});

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _opacityAnim = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnim,
      child: Container(
        width: 8, height: 8,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
