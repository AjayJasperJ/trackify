import 'package:flutter/material.dart';
import 'package:trackify/features/task/domain/entities/schedule_entity.dart';
import 'package:trackify/theme/app_form_styles.dart';
import 'package:trackify/widgets/form_section_card.dart';

class AddTaskScheduleCard extends StatelessWidget {
  final ScheduleType scheduleType;
  final ValueChanged<ScheduleType?> onScheduleTypeChanged;
  final List<int> selectedWeekdays;
  final ValueChanged<List<int>> onWeekdaysChanged;
  final List<String> weekdayNames;
  final List<int> selectedDaysOfMonth;
  final ValueChanged<List<int>> onDaysOfMonthChanged;
  final List<String> selectedYearlyDates;
  final ValueChanged<List<String>> onYearlyDatesChanged;
  final int intervalDays;
  final ValueChanged<int> onIntervalDaysChanged;
  final DateTime startDate;
  final DateTime? endDate;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectEndDate;
  final Future<DateTime?> Function() onAddYearlyDate;

  const AddTaskScheduleCard({
    super.key,
    required this.scheduleType,
    required this.onScheduleTypeChanged,
    required this.selectedWeekdays,
    required this.onWeekdaysChanged,
    required this.weekdayNames,
    required this.selectedDaysOfMonth,
    required this.onDaysOfMonthChanged,
    required this.selectedYearlyDates,
    required this.onYearlyDatesChanged,
    required this.intervalDays,
    required this.onIntervalDaysChanged,
    required this.startDate,
    required this.endDate,
    required this.onSelectStartDate,
    required this.onSelectEndDate,
    required this.onAddYearlyDate,
  });

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      icon: Icons.schedule,
      title: 'SCHEDULE',
      children: [
        DropdownButtonFormField<ScheduleType>(
          initialValue: scheduleType,
          decoration: AppFormStyles.input(label: 'Schedule Type'),
          items: ScheduleType.values.map((type) {
            String label = '';
            switch (type) {
              case ScheduleType.daily:
                label = 'Daily';
                break;
              case ScheduleType.weekday:
                label = 'Weekly (Specific Days)';
                break;
              case ScheduleType.monthly:
                label = 'Monthly (Specific Dates)';
                break;
              case ScheduleType.yearly:
                label = 'Yearly (Specific Dates)';
                break;
              case ScheduleType.interval:
                label = 'Custom Interval (Days)';
                break;
              case ScheduleType.oneTime:
                label = 'One-Time (No Repetition)';
                break;
            }
            return DropdownMenuItem(value: type, child: Text(label));
          }).toList(),
          onChanged: onScheduleTypeChanged,
        ),
        const SizedBox(height: 16),

        // Dynamic Schedule Options
        if (scheduleType == ScheduleType.weekday) ...[
          Wrap(
            spacing: 8,
            children: List.generate(7, (index) {
              final weekday = index + 1;
              final isSelected = selectedWeekdays.contains(weekday);
              return FilterChip(
                label: Text(weekdayNames[index]),
                selected: isSelected,
                selectedColor: AppFormStyles.primary.withValues(alpha: 0.2),
                onSelected: (selected) {
                  final newList = List<int>.from(selectedWeekdays);
                  if (selected) {
                    newList.add(weekday);
                  } else {
                    newList.remove(weekday);
                  }
                  onWeekdaysChanged(newList);
                },
              );
            }),
          ),
          const SizedBox(height: 16),
        ],

        if (scheduleType == ScheduleType.monthly) ...[
          Wrap(
            spacing: 4,
            children: List.generate(31, (index) {
              final day = index + 1;
              final isSelected = selectedDaysOfMonth.contains(day);
              return ChoiceChip(
                label: Text('$day'),
                selected: isSelected,
                selectedColor: AppFormStyles.primary.withValues(alpha: 0.2),
                onSelected: (selected) {
                  final newList = List<int>.from(selectedDaysOfMonth);
                  if (selected) {
                    newList.add(day);
                  } else {
                    newList.remove(day);
                  }
                  onDaysOfMonthChanged(newList);
                },
              );
            }),
          ),
          const SizedBox(height: 16),
        ],

        if (scheduleType == ScheduleType.yearly) ...[
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: selectedYearlyDates
                      .map(
                        (date) => Chip(
                          label: Text(date),
                          onDeleted: () {
                            final newList = List<String>.from(
                              selectedYearlyDates,
                            );
                            newList.remove(date);
                            onYearlyDatesChanged(newList);
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: AppFormStyles.primary),
                onPressed: () async {
                  final selectedDate = await onAddYearlyDate();
                  if (selectedDate != null) {
                    final formatted =
                        '${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                    if (!selectedYearlyDates.contains(formatted)) {
                      final newList = List<String>.from(selectedYearlyDates);
                      newList.add(formatted);
                      onYearlyDatesChanged(newList);
                    }
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        if (scheduleType == ScheduleType.interval) ...[
          TextFormField(
            initialValue: intervalDays.toString(),
            decoration: AppFormStyles.input(label: 'Repeat Interval (Days)'),
            keyboardType: TextInputType.number,
            onChanged: (val) {
              final parsed = int.tryParse(val);
              if (parsed != null && parsed > 0) {
                onIntervalDaysChanged(parsed);
              }
            },
          ),
          const SizedBox(height: 16),
        ],

        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onSelectStartDate,
                borderRadius: BorderRadius.circular(AppFormStyles.inputRadius),
                child: InputDecorator(
                  decoration: AppFormStyles.input(
                    label: scheduleType == ScheduleType.oneTime
                        ? 'Date'
                        : 'Start Date',
                  ),
                  child: Text(
                    '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
            ),
            if (scheduleType != ScheduleType.oneTime) ...[
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: onSelectEndDate,
                  borderRadius: BorderRadius.circular(
                    AppFormStyles.inputRadius,
                  ),
                  child: InputDecorator(
                    decoration: AppFormStyles.input(label: 'End Date (Optional)'),
                    child: Text(
                      endDate != null
                          ? '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}'
                          : 'None',
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
