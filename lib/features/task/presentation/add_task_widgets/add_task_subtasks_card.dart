import 'package:flutter/material.dart';
import 'package:trackify/features/task/domain/entities/subtask_entity.dart';
import 'package:trackify/theme/app_form_styles.dart';
import 'package:trackify/widgets/form_section_card.dart';

class AddTaskSubtasksCard extends StatelessWidget {
  final List<SubtaskEntity> subtasks;
  final ValueChanged<List<SubtaskEntity>> onSubtasksChanged;
  final VoidCallback onAddSubtask;

  const AddTaskSubtasksCard({
    super.key,
    required this.subtasks,
    required this.onSubtasksChanged,
    required this.onAddSubtask,
  });

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      icon: Icons.checklist,
      title: 'SUBTASKS',
      action: TextButton.icon(
        onPressed: onAddSubtask,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add'),
        style: TextButton.styleFrom(
          foregroundColor: AppFormStyles.primary,
          visualDensity: VisualDensity.compact,
        ),
      ),
      children: [
        if (subtasks.isEmpty)
          Text(
            'No subtasks yet.',
            style: TextStyle(
              fontSize: 12,
              color: AppFormStyles.onSurfaceVariant,
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: subtasks.length,
            onReorderItem: (oldIndex, newIndex) {
              // onReorderItem already adjusts newIndex for the removed item;
              // re-applying the adjustment would skip a position.
              final newList = List<SubtaskEntity>.from(subtasks);
              final item = newList.removeAt(oldIndex);
              newList.insert(newIndex, item);
              for (int i = 0; i < newList.length; i++) {
                newList[i] = newList[i].copyWith(order: i);
              }
              onSubtasksChanged(newList);
            },
            itemBuilder: (context, index) {
              final subtask = subtasks[index];
              return _SubtaskRow(
                key: ValueKey(subtask.subtaskId),
                subtask: subtask,
                onChanged: (value) {
                  final newList = List<SubtaskEntity>.from(subtasks);
                  newList[index] = newList[index].copyWith(title: value);
                  onSubtasksChanged(newList);
                },
                onDelete: () {
                  final newList = List<SubtaskEntity>.from(subtasks);
                  newList.removeAt(index);
                  onSubtasksChanged(newList);
                },
              );
            },
          ),
      ],
    );
  }
}

/// One editable subtask row. Owns its [TextEditingController] so typing never
/// rebuilds the whole reorderable list (the old `initialValue:`-based row
/// replaced the full list on every keystroke and could diverge from entity
/// state after reorders). The controller is the source of truth while typing;
/// [didUpdateWidget] only syncs when the title changed externally.
class _SubtaskRow extends StatefulWidget {
  final SubtaskEntity subtask;
  final ValueChanged<String> onChanged;
  final VoidCallback onDelete;

  const _SubtaskRow({
    super.key,
    required this.subtask,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_SubtaskRow> createState() => _SubtaskRowState();
}

class _SubtaskRowState extends State<_SubtaskRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.subtask.title);
  }

  @override
  void didUpdateWidget(covariant _SubtaskRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Same row (keyed by subtaskId), title changed outside this field
    // (e.g. future bulk edit) — sync. Typing never lands here because the
    // entity is only updated from this field's own onChanged.
    if (widget.subtask.subtaskId == oldWidget.subtask.subtaskId &&
        widget.subtask.title != _controller.text) {
      _controller.text = widget.subtask.title;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppFormStyles.outlineVariant.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.drag_indicator,
            size: 20,
            color: AppFormStyles.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Subtask title',
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: widget.onChanged,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: AppFormStyles.outline),
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }
}
