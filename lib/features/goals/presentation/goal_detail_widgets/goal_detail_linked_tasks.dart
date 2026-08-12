import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackify/features/authentication/providers/auth_provider.dart';
import 'package:trackify/features/dashboard/providers/dashboard_providers.dart';
import 'package:trackify/features/task/domain/entities/schedule_entity.dart';
import 'package:trackify/features/task/domain/entities/task_entity.dart';
import 'package:trackify/features/task/providers/task_state_providers.dart';
import 'package:trackify/features/progression/application/task_completion_handler.dart';

class GoalDetailLinkedTasks extends ConsumerWidget {
  final String goalId;
  final Color onSurface;
  final Color primary;
  final Color onSurfaceVariant;
  final Color outline;
  final Color surface;
  final Color outlineVariant;

  const GoalDetailLinkedTasks({
    super.key,
    required this.goalId,
    required this.onSurface,
    required this.primary,
    required this.onSurfaceVariant,
    required this.outline,
    required this.surface,
    required this.outlineVariant,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(userTasksStreamProvider);
    final todayRecordAsync = ref.watch(todayRecordStreamProvider);
    final uid = ref.watch(currentUserProvider)?.uid;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Associated Tasks", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onSurface)),
          const SizedBox(height: 16),
          tasksAsync.when(
            data: (tasks) {
              final goalTasks = tasks.where((t) => t.goalId == goalId).toList();
              if (goalTasks.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No tasks linked to this goal yet.',
                      style: TextStyle(color: onSurfaceVariant),
                    ),
                  ),
                );
              }
              final todayRecord = todayRecordAsync.valueOrNull;
              return Column(
                children: goalTasks.map((task) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InteractiveGoalTaskItem(
                      task: task,
                      completed: todayRecord?.completedTasks[task.taskId]?.completed ?? false,
                      onToggle: uid == null
                          ? null
                          : (completed) async {
                              final dateString = ref.read(currentDateStringProvider);
                              await ref.read(taskRecordRepositoryProvider).toggleTaskCompletion(
                                uid,
                                dateString,
                                task,
                                completed,
                              );
                              if (!context.mounted) return;
                              await handleTaskCompletion(
                                ref: ref,
                                uid: uid,
                                task: task,
                                isCompleted: completed,
                                completedSubtaskCount: task.subtasks.where((s) => s.isCompleted).length,
                                context: context,
                              );
                            },
                      primary: primary,
                      onSurface: onSurface,
                      onSurfaceVariant: onSurfaceVariant,
                      outline: outline,
                      surface: surface,
                      outlineVariant: outlineVariant,
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error: $err'),
          ),
        ],
      ),
    );
  }
}

class InteractiveGoalTaskItem extends StatefulWidget {
  final TaskEntity task;
  final bool completed;
  final Future<void> Function(bool completed)? onToggle;
  final Color primary, onSurface, onSurfaceVariant, outline, surface, outlineVariant;

  const InteractiveGoalTaskItem({
    super.key,
    required this.task,
    required this.completed,
    required this.onToggle,
    required this.primary, required this.onSurface, required this.onSurfaceVariant,
    required this.outline, required this.surface, required this.outlineVariant,
  });

  @override
  State<InteractiveGoalTaskItem> createState() => _InteractiveGoalTaskItemState();
}

class _InteractiveGoalTaskItemState extends State<InteractiveGoalTaskItem> {
  bool _isToggling = false;

  Future<void> _toggle() async {
    if (_isToggling || widget.onToggle == null) return;
    setState(() => _isToggling = true);
    try {
      // Controlled: the stream (task_records) is the source of truth, so no
      // local flip needed — the provider update re-renders us with the new
      // value. Only optimistic UI is the disabled state while writing.
      await widget.onToggle!(!widget.completed);
    } catch (_) {
      // Ignore: record write failure surfaces via the stream staying put.
    } finally {
      if (mounted) setState(() => _isToggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.completed;
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedOpacity(
        opacity: isCompleted ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: widget.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: widget.outlineVariant.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              )
            ],
          ),
          child: Row(
            children: [
              _isToggling
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: widget.primary),
                    )
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                      child: Icon(
                        isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                        key: ValueKey<bool>(isCompleted),
                        color: isCompleted ? widget.primary : widget.outline,
                        size: 24,
                      ),
                    ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: widget.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle(),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: widget.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle() {
    final base = _getScheduleDescription(widget.task.schedule);
    if (widget.task.subtasks.isEmpty) return base;
    final done = widget.task.subtasks.where((s) => s.isCompleted).length;
    return '$base • $done/${widget.task.subtasks.length} subtasks';
  }

  String _getScheduleDescription(ScheduleEntity schedule) {
    switch (schedule.type) {
      case ScheduleType.daily: return 'Daily';
      case ScheduleType.weekday: return 'Specific Weekdays';
      case ScheduleType.monthly: return 'Monthly';
      case ScheduleType.yearly: return 'Yearly';
      case ScheduleType.interval: return 'Interval';
      case ScheduleType.oneTime: return 'One Time';
    }
  }
}

