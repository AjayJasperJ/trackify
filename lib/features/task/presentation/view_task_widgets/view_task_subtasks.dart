import 'package:flutter/material.dart';
import '../../domain/entities/task_entity.dart';

class ViewTaskSubtasks extends StatelessWidget {
  final TaskEntity task;
  final Color onSurface;
  final Color secondary;
  final Color surfaceContainerLowest;
  final Color primary;
  final Color outlineVariant;
  final Color surfaceVariant;
  final Function(String, bool)? onToggle;

  const ViewTaskSubtasks({
    super.key,
    required this.task,
    required this.onSurface,
    required this.secondary,
    required this.surfaceContainerLowest,
    required this.primary,
    required this.outlineVariant,
    required this.surfaceVariant,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final subtasks = task.subtasks;
    if (subtasks.isEmpty) {
      return const SizedBox.shrink();
    }
    final completedCount = subtasks.where((s) => s.isCompleted).length;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtasks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: onSurface,
                ),
              ),
              Text(
                '$completedCount/${subtasks.length} Done',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                for (var i = 0; i < subtasks.length; i++) ...[
                  _InteractiveSubtask(
                    subtaskId: subtasks[i].subtaskId,
                    text: subtasks[i].title,
                    initialCompleted: subtasks[i].isCompleted,
                    primary: primary,
                    outlineVariant: outlineVariant,
                    secondary: secondary,
                    onSurface: onSurface,
                    onToggle: onToggle,
                  ),
                  if (i < subtasks.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: surfaceVariant.withValues(alpha: 0.3),
                    ),
                ],
                // Add Subtask Button placeholder (not fully functional yet without provider update)
                InkWell(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: primary.withValues(alpha: 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 20, color: primary),
                        const SizedBox(width: 4),
                        Text(
                          'Add Subtask',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractiveSubtask extends StatefulWidget {
  final String subtaskId;
  final String text;
  final bool initialCompleted;
  final Color primary, outlineVariant, secondary, onSurface;
  final Function(String, bool)? onToggle;

  const _InteractiveSubtask({
    required this.subtaskId,
    required this.text,
    required this.initialCompleted,
    required this.primary,
    required this.outlineVariant,
    required this.secondary,
    required this.onSurface,
    this.onToggle,
  });

  @override
  State<_InteractiveSubtask> createState() => _InteractiveSubtaskState();
}

class _InteractiveSubtaskState extends State<_InteractiveSubtask> {
  late bool isCompleted;

  @override
  void initState() {
    super.initState();
    isCompleted = widget.initialCompleted;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => isCompleted = !isCompleted);
          if (widget.onToggle != null) {
            widget.onToggle!(widget.subtaskId, isCompleted);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isCompleted ? widget.primary : widget.outlineVariant,
                    width: 2,
                  ),
                  color: isCompleted ? widget.primary : Colors.transparent,
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 14,
                    color: isCompleted ? widget.secondary : widget.onSurface,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                  child: Text(widget.text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
