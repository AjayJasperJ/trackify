import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/goal_entity.dart';
import '../../providers/goal_providers.dart';
import '../../../authentication/providers/auth_provider.dart';

import '../../../../widgets/dashboard_app_bar.dart';
import '../goal_detail_widgets/goal_detail_hero_progress.dart';
import '../goal_detail_widgets/goal_detail_metrics_grid.dart';
import '../goal_detail_widgets/goal_detail_milestones.dart';
import '../goal_detail_widgets/goal_detail_linked_tasks.dart';
import '../goal_detail_widgets/goal_detail_activity_history.dart';

class GoalDetailScreen extends ConsumerWidget {
  /// Optional fast-path instance passed via `state.extra`; when null (deep
  /// link / restart), the screen resolves the goal from `goalProvider`.
  final GoalEntity? goal;
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId, this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalProvider(goalId));

    return goalAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => _GoalDetailFallback(
        icon: Icons.error_outline,
        message: 'Something went wrong loading this goal.',
        detail: '$e',
        onBack: () => context.go('/goals'),
      ),
      data: (goal) {
        if (goal == null) {
          return const _GoalDetailFallback(
            icon: Icons.flag_outlined,
            message: 'Goal not found',
            detail: 'It may have been deleted.',
          );
        }
        return _GoalDetailBody(goal: goal);
      },
    );
  }
}

/// The data-driven detail view. Rebuilt whenever the goal doc changes, so
/// edits made elsewhere (or by another device) show up here automatically.
class _GoalDetailBody extends ConsumerWidget {
  final GoalEntity goal;

  const _GoalDetailBody({required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsStreamProvider);
    final currentGoal =
        goalsAsync.value?.firstWhere(
          (g) => g.goalId == goal.goalId,
          orElse: () => goal,
        ) ??
        goal;

    final milestonesAsync = ref.watch(
      milestonesStreamProvider(currentGoal.goalId),
    );

    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final Color background = const Color(0xFFFCF9F8);
    final Color surface = const Color(0xFFFCF9F8);
    final Color surfaceContainerLowest = const Color(0xFFFFFFFF);
    final Color surfaceContainerLow = const Color(0xFFF6F3F2);
    final Color surfaceContainerHighest = const Color(0xFFE4E2E1);
    final Color surfaceContainerHigh = const Color(0xFFEAE7E7);
    final Color primaryContainer = const Color(0xFF0F6CBD);
    final Color onPrimaryContainer = const Color(0xFFE3ECFF);
    final Color primary = const Color(0xFF005396);
    final Color onSurface = const Color(0xFF1B1C1C);
    final Color onSurfaceVariant = const Color(0xFF414751);
    final Color secondary = const Color(0xFF5E5E5E);
    final Color outline = const Color(0xFF717783);
    final Color outlineVariant = const Color(0xFFC1C7D3);
    final Color secondaryContainer = const Color(0xFFE1DFDF);
    final Color onSecondaryContainer = const Color(0xFF626262);

    return Scaffold(
      backgroundColor: background,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 64.0 + bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              heroTag: 'add_task_fab',
              onPressed: () {
                context.push('/add-task', extra: currentGoal);
              },
              backgroundColor: surfaceContainerHighest,
              elevation: 2,
              icon: Icon(Icons.add_task, color: primary),
              label: Text(
                'Add Task',
                style: TextStyle(color: primary, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'edit_goal_fab',
              onPressed: () {
                context.push(
                  '/edit-goal/${currentGoal.goalId}',
                  extra: currentGoal,
                );
              },
              backgroundColor: primary,
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(Icons.edit, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: topPadding + 64, // pt-16
              bottom: bottomPadding + 64 + 96, // pb-24
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GoalDetailHeroProgress(
                  goal: currentGoal,
                  surfaceContainerHigh: surfaceContainerHigh,
                  primary: primary,
                  onSurface: onSurface,
                  secondary: secondary,
                  onSurfaceVariant: onSurfaceVariant,
                ),
                GoalDetailMetricsGrid(
                  goal: currentGoal,
                  surfaceContainerLow: surfaceContainerLow,
                  primary: primary,
                  onSurface: onSurface,
                  secondary: secondary,
                  primaryContainer: primaryContainer,
                  onPrimaryContainer: onPrimaryContainer,
                ),
                const SizedBox(height: 32),
                GoalDetailMilestones(
                  currentGoal: currentGoal,
                  milestonesAsync: milestonesAsync,
                  onSurface: onSurface,
                  primary: primary,
                  surface: surface,
                  surfaceContainerHighest: surfaceContainerHighest,
                  secondary: secondary,
                  onSurfaceVariant: onSurfaceVariant,
                ),
                const SizedBox(height: 24),
                GoalDetailLinkedTasks(
                  goalId: currentGoal.goalId,
                  onSurface: onSurface,
                  primary: primary,
                  onSurfaceVariant: onSurfaceVariant,
                  outline: outline,
                  surface: surface,
                  outlineVariant: outlineVariant,
                ),
                const SizedBox(height: 32),
                GoalDetailActivityHistory(
                  surfaceContainerLowest: surfaceContainerLowest,
                  onSurface: onSurface,
                  onSurfaceVariant: onSurfaceVariant,
                  secondaryContainer: secondaryContainer,
                  onSecondaryContainer: onSecondaryContainer,
                  primary: primary,
                ),
              ],
            ),
          ),
            DashboardAppBar(
              topPadding: topPadding,
              title: 'Goal Details',
              isInnerScreen: true,
              showAvatar: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    if (currentGoal.isStrict) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Strict goals cannot be deleted'),
                        ),
                      );
                      return;
                    }
                    final user = ref.read(currentUserProvider);
                    if (user != null) {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Goal?'),
                          content: const Text(
                            'Are you sure you want to delete this goal and all its milestones?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => context.pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => context.pop(true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        try {
                          await ref
                              .read(goalRepositoryProvider)
                              .deleteGoal(user.uid, currentGoal.goalId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Goal deleted successfully'),
                              ),
                            );
                            context.go('/goals');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to delete goal: $e'),
                              ),
                            );
                          }
                        }
                      }
                    }
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Friendly fallback for loading failure / deleted entity, with a way back.
class _GoalDetailFallback extends StatelessWidget {
  final IconData icon;
  final String message;
  final String detail;
  final VoidCallback? onBack;

  const _GoalDetailFallback({
    required this.icon,
    required this.message,
    required this.detail,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 56, color: const Color(0xFF414751)),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B1C1C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    detail,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF414751),
                    ),
                  ),
                  if (onBack != null) ...[const SizedBox(height: 24), FilledButton(onPressed: onBack, child: const Text('Back to Goals'))],
                ],
              ),
            ),
          ),
          DashboardAppBar(
            topPadding: topPadding,
            title: 'Goal Details',
            isInnerScreen: true,
            showAvatar: false,
          ),
        ],
      ),
    );
  }
}
