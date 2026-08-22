import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../authentication/providers/auth_provider.dart';
import '../../../../widgets/dashboard_app_bar.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/entities/goal_enums.dart';
import '../../providers/goal_providers.dart';
import '../controllers/goal_editor_controller.dart';
import '../create_goal_widgets/create_goal_info_card.dart';
import '../create_goal_widgets/create_goal_type_card.dart';
// create_goal_milestones_card.dart: milestone entry removed from the
// create flow — milestones are added from the goal detail screen
// (/add-milestone) instead. File kept for reuse.
import '../create_goal_widgets/create_goal_linked_tasks_card.dart';
// create_goal_rewards_card.dart + create_goal_preview_card.dart imports
// removed — their widgets are commented out (see below) pending real data.
import '../../../task/providers/task_state_providers.dart';
import '../../../dashboard/providers/dashboard_providers.dart';
import '../../../../widgets/form_primary_button.dart';

class CreateGoalScreen extends ConsumerStatefulWidget {
  final GoalEntity? goalToEdit;

  /// Route id — always present on `/edit-goal/:goalId`. When the app is
  /// restarted on this route, `goalToEdit` is null and the screen resolves
  /// the goal from Firestore via [goalProvider]; the resolved goal is
  /// injected into the controller once loaded.
  final String? goalId;

  const CreateGoalScreen({super.key, this.goalToEdit, this.goalId});

  @override
  ConsumerState<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

enum LinkedTaskTab { existing, create }

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  late final GoalEditorController _controller;
  LinkedTaskTab _selectedLinkedTab = LinkedTaskTab.existing;

  /// Deep-link resolution: when the route carries only a goalId (no extra),
  /// fetch the goal from Firestore. Non-null once loaded (or when a fast-path
  /// goal was passed in); null while loading. No-goal (create mode) is
  /// signaled by [widget.goalId] == null.
  GoalEntity? _resolvedGoal;
  bool _loadFailed = false;

  bool get _isEditing =>
      widget.goalToEdit != null ||
      _resolvedGoal != null ||
      widget.goalId != null;

  @override
  void initState() {
    super.initState();
    _controller = GoalEditorController(
      goalRepo: ref.read(goalRepositoryProvider),
      milestoneRepo: ref.read(milestoneRepositoryProvider),
      taskRepo: ref.read(taskRepositoryProvider),
      goalToEdit: widget.goalToEdit,
    );
    _resolveGoal();
  }

  Future<void> _resolveGoal() async {
    final goalId = widget.goalId;
    if (goalId == null || widget.goalToEdit != null) return;

    try {
      final goal = await ref.read(goalProvider(goalId).future);
      if (!mounted) return;
      if (goal != null) {
        // Rebuild the controller with the loaded goal. Cheap: form fields
        // are re-seeded from the same values; keeps deep-link parity with
        // the extra fast-path without duplicating editor logic.
        final old = _controller;
        _controller = GoalEditorController(
          goalRepo: ref.read(goalRepositoryProvider),
          milestoneRepo: ref.read(milestoneRepositoryProvider),
          taskRepo: ref.read(taskRepositoryProvider),
          goalToEdit: goal,
        );
        old.dispose();
        setState(() => _resolvedGoal = goal);
      } else {
        setState(() => _loadFailed = true);
      }
    } catch (e) {
      if (mounted) setState(() => _loadFailed = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveGoal() async {
    if (_controller.name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a goal name')),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in')),
      );
      return;
    }

    _controller.setLoading(true);
    try {
      await _controller.save(user.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            _isEditing ? 'Goal updated' : 'Goal created',
          ),
        ));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save goal: $e')),
        );
      }
    } finally {
      if (mounted) _controller.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    if (_loadFailed) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.flag_outlined,
                    size: 56,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Goal not found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'It may have been deleted.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.go('/goals'),
                    child: const Text('Back to Goals'),
                  ),
                ],
              ),
            ),
            DashboardAppBar(
              title: 'Edit Goal',
              topPadding: topPadding,
              isInnerScreen: true,
              showAvatar: false,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final tasksAsync = ref.watch(userTasksStreamProvider);
          final availableTasks = tasksAsync.value ?? [];
          final isEditing = _isEditing;

          return _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    // Main Scrollable Content
                    SingleChildScrollView(
                      padding: EdgeInsets.only(
                        top: topPadding + 56 + 24, // Top Nav Height + Padding
                        bottom: bottomPadding + 64 + 80, // Sticky Button
                        left: 16.0,
                        right: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CreateGoalInfoCard(
                            goalNameController: _controller.name,
                            descController: _controller.description,
                            categoryController: _controller.category,
                            selectedPriority: _priorityIndex(
                              _controller.priority,
                            ),
                            isPrivate: _controller.isPrivate,
                            onPriorityChanged: (val) =>
                                _controller.setPriority(_priorityFromIndex(val)),
                            onCategoryChanged: (val) {
                              _controller.category.text = val;
                              _controller.setCategory(val);
                            },
                            onPrivateChanged: _controller.setPrivate,
                          ),
                          const SizedBox(height: 24),
                          CreateGoalTypeCard(
                            selectedGoalType: _controller.goalType,
                            onGoalTypeChanged: _controller.setGoalType,
                            selectedDate: _controller.targetDate,
                            onDateChanged: _controller.setTargetDate,
                            durationDays: _controller.durationDays,
                            onDurationDaysChanged: _controller.setDurationDays,
                            isStrict: _controller.isStrict,
                            onStrictChanged: _controller.setStrict,
                          ),
                          const SizedBox(height: 24),
                          // Milestone section removed from the create flow —
                          // milestones are added/edited from the goal detail
                          // screen. The controller still carries existing
                          // milestones through edits (preserved, not wiped).
                          CreateGoalLinkedTasksCard(
                            selectedLinkedTab: _selectedLinkedTab,
                            onTabChanged: (val) =>
                                setState(() => _selectedLinkedTab = val),
                            availableTasks: availableTasks,
                            selectedTaskIds: _controller.selectedTaskIds,
                            goalId: _controller.goalId,
                            onTaskToggled: (task) async {
                              final user = ref.read(currentUserProvider);
                              if (user == null) return;
                              final isSelected = _controller.selectedTaskIds
                                  .contains(task.taskId);
                              _controller.toggleTask(task.taskId);
                              // Persist the link on the task doc itself:
                              // goal detail's Associated Tasks reads
                              // task.goalId, so that is the single source of
                              // truth (goal.linkedTasks is a redundant cache
                              // for the goal card checkboxes).
                              try {
                                await ref
                                    .read(taskRepositoryProvider)
                                    .updateTask(
                                      user.uid,
                                      task.copyWith(
                                        goalId: isSelected ? null : _controller.goalId,
                                        updatedAt: DateTime.now(),
                                      ),
                                    );
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to update task link: $e',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            onTaskCreated: (newTask) async {
                              final user = ref.read(currentUserProvider);
                              if (user != null) {
                                await ref
                                    .read(taskRepositoryProvider)
                                    .addTask(user.uid, newTask);
                              }
                              _controller.selectedTaskIds.add(newTask.taskId);
                              _controller.setSelectedTasks(
                                _controller.selectedTaskIds,
                              );
                              setState(
                                () => _selectedLinkedTab =
                                    LinkedTaskTab.existing,
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          // CreateGoalRewardsCard: decorative static XP
                          // preview; real XP/achievement wiring is not live
                          // yet (bugs #4-9), so it's commented out instead of
                          // deleted — may be reused once progression is wired.
                          // const CreateGoalRewardsCard(),
                          // const SizedBox(height: 24),
                          // CreateGoalPreviewCard: cosmetic "PREVIEW CARD"
                          // that only echoes the goal name. Commented out;
                          // kept for future use.
                          // CreateGoalPreviewCard(
                          //   previewName: _goalNameController.text,
                          // ),
                        ],
                      ),
                    ),

                    // Top Header (Blurred)
                    DashboardAppBar(
                      title: isEditing ? 'Edit Goal' : 'Create Goal',
                      topPadding: topPadding,
                      isInnerScreen: true,
                      showAvatar: false,
                    ),

                    // Sticky Create Button (Above Bottom Nav)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            color: AppColors.surface.withValues(alpha: 0.8),
                            padding: EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              top: 16.0,
                              bottom: 16.0 + bottomPadding,
                            ),
                            child: FormPrimaryButton(
                              text: isEditing
                                  ? 'Save Changes'
                                  : 'Create Goal',
                              onPressed: _saveGoal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }

  int _priorityIndex(GoalPriority p) => switch (p) {
        GoalPriority.low => 0,
        GoalPriority.medium => 1,
        GoalPriority.high => 2,
        GoalPriority.critical => 3,
      };

  GoalPriority _priorityFromIndex(int i) => switch (i) {
        0 => GoalPriority.low,
        1 => GoalPriority.medium,
        2 => GoalPriority.high,
        _ => GoalPriority.critical,
      };
}
