import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trackify/features/authentication/providers/auth_provider.dart';
import 'package:trackify/features/dashboard/providers/dashboard_providers.dart';
import 'package:trackify/features/task/domain/entities/task_entity.dart';
import 'package:trackify/features/progression/application/task_completion_handler.dart';

class AllTasksInteractiveListTaskItem extends StatefulWidget {
  final TaskEntity task;
  final WidgetRef ref;
  final String title, timeText, tag;
  final Color tagColor,
      tagTextColor,
      surfaceContainerLowest,
      surfaceContainerLow,
      outline,
      primary,
      onSurface,
      onSurfaceVariant;
  final bool initialCompleted;
  final bool showCheckbox;
  final IconData iconData;
  final String? middleBadge;
  final IconData? middleIcon;

  const AllTasksInteractiveListTaskItem({
    super.key,
    required this.task,
    required this.ref,
    required this.title,
    required this.timeText,
    required this.tag,
    required this.tagColor,
    required this.tagTextColor,
    required this.initialCompleted,
    required this.iconData,
    this.showCheckbox = true,
    this.middleBadge,
    this.middleIcon,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.outline,
    required this.primary,
    required this.onSurface,
    required this.onSurfaceVariant,
  });

  @override
  State<AllTasksInteractiveListTaskItem> createState() =>
      _AllTasksInteractiveListTaskItemState();
}

class _AllTasksInteractiveListTaskItemState
    extends State<AllTasksInteractiveListTaskItem> {
  late bool isCompleted;
  bool isHovered = false;

  @override
  void initState() {
    super.initState();
    isCompleted = widget.initialCompleted;
  }

  @override
  void didUpdateWidget(covariant AllTasksInteractiveListTaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCompleted != widget.initialCompleted) {
      isCompleted = widget.initialCompleted;
    }
  }

  Future<void> _toggleTask() async {
    setState(() => isCompleted = !isCompleted);
    try {
      final user = widget.ref.read(currentUserProvider);
      if (user != null) {
        final dateString = widget.ref.read(currentDateStringProvider);
        await widget.ref
            .read(taskRecordRepositoryProvider)
            .toggleTaskCompletion(
              user.uid,
              dateString,
              widget.task,
              isCompleted,
            );
        if (!mounted) return;
        await handleTaskCompletion(
          ref: widget.ref,
          uid: user.uid,
          task: widget.task,
          isCompleted: isCompleted,
          completedSubtaskCount: widget.task.subtasks.where((s) => s.isCompleted).length,
          context: context,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isCompleted = !isCompleted); // Revert on failure
      }
    }
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text(
          'Are you sure you want to delete "\${widget.task.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final user = widget.ref.read(currentUserProvider);
      if (user != null) {
        try {
          await widget.ref
              .read(taskRepositoryProvider)
              .deleteTask(user.uid, widget.task.taskId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Task deleted successfully')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to delete task: $e')),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/view-task/\${widget.task.taskId}', extra: widget.task);
      },
      onLongPressStart: (details) {
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy,
            details.globalPosition.dx,
            details.globalPosition.dy,
          ),
          items: [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ).then((value) {
          if (!context.mounted) return;
          if (value == 'edit') {
            context.push('/task/${widget.task.taskId}', extra: widget.task);
          } else if (value == 'delete') {
            _deleteTask();
          }
        });
      },
      onTapDown: (_) => setState(() => isHovered = true),
      onTapUp: (_) => setState(() => isHovered = false),
      onTapCancel: () => setState(() => isHovered = false),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isCompleted
              ? widget.surfaceContainerLow
              : widget.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            bottom: BorderSide(
              color: isHovered ? widget.primary : Colors.transparent,
              width: 2,
            ),
          ),
          boxShadow: [
            if (!isCompleted)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: Row(
          children: [
            if (widget.showCheckbox) ...[
              GestureDetector(
                onTap: _toggleTask,
                child: AnimatedScale(
                  scale: 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isCompleted ? widget.primary : widget.outline,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isCompleted
                          ? FontWeight.w400
                          : FontWeight.w600,
                      color: widget.onSurface.withValues(
                        alpha: isCompleted ? 0.5 : 1.0,
                      ),
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      fontFamily: 'Inter',
                    ),
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        widget.iconData,
                        size: 14,
                        color: widget.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.timeText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: widget.onSurfaceVariant,
                        ),
                      ),
                      if (widget.middleBadge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: widget.outline.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          widget.middleIcon,
                          size: 14,
                          color: widget.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.middleBadge!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: widget.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: widget.outline.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: widget.tagColor,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          widget.tag,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: widget.tagTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
