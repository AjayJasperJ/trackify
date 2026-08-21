import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../task/providers/task_state_providers.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../../providers/dashboard_providers.dart';
import 'package:trackify/features/progression/application/task_completion_handler.dart';
import 'package:trackify/features/task/domain/entities/task_entity.dart';

class DashboardTasksSection extends ConsumerWidget {
  const DashboardTasksSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(todayTasksProvider);
    final todayRecordState = ref.watch(todayRecordStreamProvider);
    final userState = ref.watch(authStateProvider);

    final tasks = tasksState.value ?? [];
    final todayRecord = todayRecordState.value;
    final uid = userState.value?.uid;

    final displayTasks = tasks.take(3).toList();
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
              "Today's Tasks",
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
        if (displayTasks.isEmpty)
          Text('No tasks for today.', style: TextStyle(color: secondary)),
        ...displayTasks.map((task) {
          final isCompleted =
              todayRecord?.completedTasks[task.taskId]?.completed ?? false;
          final timeText =
              "${task.startDate.hour.toString().padLeft(2, '0')}:${task.startDate.minute.toString().padLeft(2, '0')}";
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InteractiveDashboardTaskItem(
              task: task,
              title: task.title,
              tagLabel: task.category ?? 'TASK',
              tagColor: primary.withValues(alpha: 0.1),
              tagTextColor: primary,
              timeText: timeText,
              initialCompleted: isCompleted,
              onToggle: (completed) async {
                if (uid != null) {
                  final dateString = ref.read(currentDateStringProvider);
                  await ref
                      .read(taskRecordRepositoryProvider)
                      .toggleTaskCompletion(uid, dateString, task, completed);
                  if (!context.mounted) return;
                  await handleTaskCompletion(
                    ref: ref,
                    uid: uid,
                    task: task,
                    isCompleted: completed,
                    completedSubtaskCount: task.subtasks.where((s) => s.isCompleted).length,
                    context: context,
                  );
                }
              },
            ),
          );
        }),
      ],
    );
  }
}

class InteractiveDashboardTaskItem extends StatefulWidget {
  final TaskEntity task;
  final String title, tagLabel, timeText;
  final Color tagColor, tagTextColor;
  final bool initialCompleted;
  final ValueChanged<bool> onToggle;

  const InteractiveDashboardTaskItem({
    super.key,
    required this.task,
    required this.title,
    required this.tagLabel,
    required this.tagColor,
    required this.tagTextColor,
    required this.timeText,
    required this.initialCompleted,
    required this.onToggle,
  });
  @override
  State<InteractiveDashboardTaskItem> createState() =>
      _InteractiveDashboardTaskItemState();
}

class _InteractiveDashboardTaskItemState
    extends State<InteractiveDashboardTaskItem> {
  late bool isCompleted;
  bool isHovered = false;
  final Color primary = const Color(0xFF005396);
  final Color outlineVariant = const Color(0xFFC1C7D3);
  final Color onSurface = const Color(0xFF1B1C1C);
  final Color secondary = const Color(0xFF5E5E5E);
  final Color surface = const Color(0xFFFCF9F8);

  @override
  void initState() {
    super.initState();
    isCompleted = widget.initialCompleted;
  }

  @override
  void didUpdateWidget(InteractiveDashboardTaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCompleted != widget.initialCompleted) {
      isCompleted = widget.initialCompleted;
    }
  }

  void _toggleTask() {
    setState(() => isCompleted = !isCompleted);
    widget.onToggle(isCompleted);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      onTapDown: (_) => setState(() => isHovered = true),
      onTapUp: (_) => setState(() => isHovered = false),
      onTapCancel: () => setState(() => isHovered = false),
      child: AnimatedScale(
        scale: isCompleted ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: isCompleted ? 0.6 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: outlineVariant.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isHovered ? 0.1 : 0.05),
                  blurRadius: isHovered ? 6 : 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _toggleTask,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isCompleted
                            ? primary
                            : (isHovered ? primary : outlineVariant),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: isCompleted ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.check, size: 18, color: primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: widget.tagColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.tagLabel.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: widget.tagTextColor,
                              ),
                            ),
                          ),
                          if (widget.task.priority != TaskPriority.none) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(widget.task.priority).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.task.priority.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getPriorityColor(widget.task.priority),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(width: 4),
                          Text(
                            '• ${widget.timeText}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.drag_indicator,
                  color: secondary.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.blue;
      case TaskPriority.none:
        return Colors.grey;
    }
  }
}
