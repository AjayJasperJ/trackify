import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trackify/features/task/domain/entities/task_entity.dart';
import 'package:trackify/theme/app_form_styles.dart';
import 'package:trackify/widgets/form_section_card.dart';

class AddTaskTrackingCard extends StatefulWidget {
  final TaskTrackingMode trackingMode;
  final int? expectedDurationMinutes;
  final TimeOfDay? startTimeOfDay;
  final TimeOfDay? endTimeOfDay;
  final ValueChanged<TaskTrackingMode> onTrackingModeChanged;
  final ValueChanged<int?> onExpectedDurationChanged;
  final ValueChanged<TimeOfDay?> onStartTimeChanged;
  final ValueChanged<TimeOfDay?> onEndTimeChanged;

  const AddTaskTrackingCard({
    super.key,
    required this.trackingMode,
    required this.expectedDurationMinutes,
    required this.startTimeOfDay,
    required this.endTimeOfDay,
    required this.onTrackingModeChanged,
    required this.onExpectedDurationChanged,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  @override
  State<AddTaskTrackingCard> createState() => _AddTaskTrackingCardState();
}

class _AddTaskTrackingCardState extends State<AddTaskTrackingCard> {
  late TextEditingController _hoursController;
  late TextEditingController _minutesController;

  @override
  void initState() {
    super.initState();
    final totalMinutes = widget.expectedDurationMinutes ?? 0;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    _hoursController = TextEditingController(
      text: hours > 0 ? hours.toString() : '',
    );
    _minutesController = TextEditingController(
      text: minutes > 0 ? minutes.toString() : '',
    );
  }

  @override
  void didUpdateWidget(covariant AddTaskTrackingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expectedDurationMinutes != widget.expectedDurationMinutes) {
      final totalMinutes = widget.expectedDurationMinutes ?? 0;
      final newHours = totalMinutes ~/ 60;
      final newMinutes = totalMinutes % 60;

      final currentHours = int.tryParse(_hoursController.text) ?? 0;
      final currentMinutes = int.tryParse(_minutesController.text) ?? 0;

      if (currentHours != newHours) {
        _hoursController.text = newHours > 0 ? newHours.toString() : '';
      }
      if (currentMinutes != newMinutes) {
        _minutesController.text = newMinutes > 0 ? newMinutes.toString() : '';
      }
    }
  }

  void _updateDuration() {
    final hours = int.tryParse(_hoursController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final total = (hours * 60) + minutes;
    widget.onExpectedDurationChanged(total > 0 ? total : null);
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final initialTime = isStart
        ? (widget.startTimeOfDay ?? TimeOfDay.now())
        : (widget.endTimeOfDay ?? TimeOfDay.now());

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      if (isStart) {
        widget.onStartTimeChanged(picked);
      } else {
        widget.onEndTimeChanged(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      icon: Icons.access_time,
      title: 'TIME & TRACKING',
      children: [
        Row(
          children: [
            Expanded(
              child: _TimeDisplay(
                label: 'Start Time',
                time: widget.startTimeOfDay,
                onTap: () => _selectTime(context, true),
                onClear: () => widget.onStartTimeChanged(null),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _TimeDisplay(
                label: 'End Time',
                time: widget.endTimeOfDay,
                onTap: () => _selectTime(context, false),
                onClear: () => widget.onEndTimeChanged(null),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<TaskTrackingMode>(
          value: widget.trackingMode,
          decoration: AppFormStyles.input(label: 'Tracking Mode'),
          items: const [
            DropdownMenuItem(value: TaskTrackingMode.none, child: Text('None')),
            DropdownMenuItem(
              value: TaskTrackingMode.timer,
              child: Text('Timer (Countdown)'),
            ),
          ],
          onChanged: (val) {
            if (val != null) {
              widget.onTrackingModeChanged(val);
            }
          },
        ),
        if (widget.trackingMode == TaskTrackingMode.timer) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _hoursController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    color: AppFormStyles.textColor,
                    fontSize: 14,
                  ),
                  decoration: AppFormStyles.input(label: 'Hours', hint: '0'),
                  onChanged: (_) => _updateDuration(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _minutesController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    color: AppFormStyles.textColor,
                    fontSize: 14,
                  ),
                  decoration: AppFormStyles.input(label: 'Minutes', hint: '0'),
                  onChanged: (_) => _updateDuration(),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _TimeDisplay extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _TimeDisplay({
    required this.label,
    required this.time,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasTime = time != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppFormStyles.inputRadius),
      child: InputDecorator(
        decoration: AppFormStyles.input(
          label: label,
          suffixIcon: hasTime
              ? IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClear,
                  splashRadius: 20,
                  color: AppFormStyles.onSurfaceVariant,
                )
              : const Icon(
                  Icons.access_time,
                  size: 20,
                  color: AppFormStyles.onSurfaceVariant,
                ),
        ),
        isEmpty: !hasTime,
        child: Text(
          hasTime ? time!.format(context) : 'Not set',
          style: TextStyle(
            color: hasTime
                ? AppFormStyles.textColor
                : AppFormStyles.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
