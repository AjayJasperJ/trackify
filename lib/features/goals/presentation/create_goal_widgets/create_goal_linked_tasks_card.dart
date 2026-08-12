// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:trackify/features/task/domain/entities/task_entity.dart';
import 'package:trackify/features/task/domain/entities/schedule_entity.dart';
import 'package:trackify/features/task/domain/entities/task_size.dart';

import '../screens/create_goal_screen.dart' show LinkedTaskTab;
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_form_styles.dart';
import '../../../../../widgets/form_primary_button.dart';

class CreateGoalLinkedTasksCard extends StatefulWidget {
  final LinkedTaskTab selectedLinkedTab;
  final ValueChanged<LinkedTaskTab> onTabChanged;
  final List<TaskEntity> availableTasks;
  final Set<String> selectedTaskIds;
  final String? goalId;
  final ValueChanged<TaskEntity> onTaskToggled;
  final Future<void> Function(TaskEntity newTask)? onTaskCreated;

  const CreateGoalLinkedTasksCard({
    super.key,
    required this.selectedLinkedTab,
    required this.onTabChanged,
    required this.availableTasks,
    required this.selectedTaskIds,
    required this.goalId,
    required this.onTaskToggled,
    this.onTaskCreated,
  });

  @override
  State<CreateGoalLinkedTasksCard> createState() => _CreateGoalLinkedTasksCardState();
}

class _CreateGoalLinkedTasksCardState extends State<CreateGoalLinkedTasksCard> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _taskTitleController = TextEditingController();

  TaskSize _selectedTaskSize = TaskSize.medium;
  ScheduleType _selectedScheduleType = ScheduleType.daily;
  bool _isCreatingTask = false;
  String _searchQuery = '';
  final Set<String> _hoveredTaskIds = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _taskTitleController.dispose();
    super.dispose();
  }

  void _setHovered(String taskId, bool hovered) {
    if (!mounted) return;
    setState(() {
      if (hovered) {
        _hoveredTaskIds.add(taskId);
      } else {
        _hoveredTaskIds.remove(taskId);
      }
    });
  }

  ScheduleEntity _buildScheduleEntity(ScheduleType type) {
    switch (type) {
      case ScheduleType.daily:
        return const DailyScheduleEntity();
      case ScheduleType.weekday:
        return const WeekdayScheduleEntity(weekdays: [1, 2, 3, 4, 5]);
      case ScheduleType.monthly:
        return const MonthlyScheduleEntity(days: [1, 15]);
      case ScheduleType.yearly:
        return const YearlyScheduleEntity(dates: ['01-01']);
      case ScheduleType.interval:
        return const IntervalScheduleEntity(intervalDays: 2);
      case ScheduleType.oneTime:
        return const OneTimeScheduleEntity();
    }
  }

  Future<void> _handleCreateAndLink() async {
    final title = _taskTitleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task name'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isCreatingTask = true;
    });

    final newTask = TaskEntity(
      taskId: const Uuid().v4(),
      title: title,
      taskSize: _selectedTaskSize,
      schedule: _buildScheduleEntity(_selectedScheduleType),
      startDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      // Link to the goal being created/edited so it shows up in
      // goal detail's Associated Tasks (which filters by task.goalId).
      goalId: widget.goalId,
    );

    try {
      if (widget.onTaskCreated != null) {
        await widget.onTaskCreated!(newTask);
      }
      if (mounted) {
        _taskTitleController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Created task "$title" and linked to goal!'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingTask = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = widget.selectedTaskIds.length;
    return Container(
      decoration: AppFormStyles.card(),
      child: Column(
        children: [
          // Tabs
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppFormStyles.cardRadius),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildLinkedTabBtn(
                      'Existing Tasks${widget.availableTasks.isNotEmpty ? " (${widget.availableTasks.length})" : ""}',
                      LinkedTaskTab.existing,
                    ),
                    const SizedBox(width: 16),
                    _buildLinkedTabBtn('Create Task', LinkedTaskTab.create),
                  ],
                ),
                if (selectedCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$selectedCount Linked',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Tab Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: widget.selectedLinkedTab == LinkedTaskTab.existing
                  ? _buildExistingTasksContent()
                  : _buildCreateTaskContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedTabBtn(String title, LinkedTaskTab tab) {
    final isSelected = widget.selectedLinkedTab == tab;
    return GestureDetector(
      onTap: () => widget.onTabChanged(tab),
      child: Container(
        padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildExistingTasksContent() {
    final filteredTasks = widget.availableTasks.where((task) {
      if (_searchQuery.isEmpty) return true;
      final matchTitle = task.title.toLowerCase().contains(_searchQuery);
      final matchCategory = task.category?.toLowerCase().contains(_searchQuery) ?? false;
      return matchTitle || matchCategory;
    }).toList();

    return Column(
      key: const ValueKey('existing'),
      children: [
        TextField(
          controller: _searchController,
          decoration: AppFormStyles.input(
            hint: 'Search your tasks...',
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, size: 16, color: AppColors.onSurfaceVariant),
                    onPressed: () => _searchController.clear(),
                  )
                : null,
          ).copyWith(prefixIcon: Icon(Icons.search, color: AppColors.onSurfaceVariant, size: 20)),
        ),
        const SizedBox(height: 16),
        if (widget.availableTasks.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No existing tasks found.',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
            ),
          )
        else if (filteredTasks.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No tasks matching "$_searchQuery"',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
            ),
          )
        else
          ...filteredTasks.map((task) => _buildExistingTaskRow(task)),
      ],
    );
  }

  Widget _buildCreateTaskContent(BuildContext context) {
    return Column(
      key: const ValueKey('create'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _taskTitleController,
          decoration: AppFormStyles.input(
            hint: 'New Task Name (e.g. Daily 30m Workout)',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SIZE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<TaskSize>(
                    value: _selectedTaskSize,
                    isExpanded: true,
                    decoration: AppFormStyles.input(label: 'Size'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurface,
                      fontFamily: 'Inter',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: TaskSize.tiny,
                        child: Text('Tiny (<30m)'),
                      ),
                      DropdownMenuItem(
                        value: TaskSize.small,
                        child: Text('Small (1-2h)'),
                      ),
                      DropdownMenuItem(
                        value: TaskSize.medium,
                        child: Text('Medium (4-6h)'),
                      ),
                      DropdownMenuItem(
                        value: TaskSize.large,
                        child: Text('Large (1-2d)'),
                      ),
                      DropdownMenuItem(
                        value: TaskSize.huge,
                        child: Text('Huge (>2d)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedTaskSize = val);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FREQUENCY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<ScheduleType>(
                    value: _selectedScheduleType,
                    isExpanded: true,
                    decoration: AppFormStyles.input(label: 'Frequency'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurface,
                      fontFamily: 'Inter',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: ScheduleType.daily,
                        child: Text('Daily'),
                      ),
                      DropdownMenuItem(
                        value: ScheduleType.weekday,
                        child: Text('Weekdays'),
                      ),
                      DropdownMenuItem(
                        value: ScheduleType.monthly,
                        child: Text('Monthly'),
                      ),
                      DropdownMenuItem(
                        value: ScheduleType.oneTime,
                        child: Text('One Time'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedScheduleType = val);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FormPrimaryButton(
          text: 'Create & Link Task',
          onPressed: _isCreatingTask ? () {} : _handleCreateAndLink,
          onPrimaryColor: Colors.white,
        ),
        if (_isCreatingTask)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: () {
              // GoRouter push (this app is MaterialApp.router — raw
              // Navigator.pushNamed has no route generator and would throw).
              context.push('/add-task');
            },
            icon: Icon(Icons.open_in_new, size: 14, color: AppColors.primary),
            label: Text(
              'Open Full Task Editor for Subtasks & Details',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExistingTaskRow(TaskEntity task) {
    final isChecked = widget.selectedTaskIds.contains(task.taskId);
    final isHovered = _hoveredTaskIds.contains(task.taskId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => widget.onTaskToggled(task),
        onTapDown: (_) => _setHovered(task.taskId, true),
        onTapUp: (_) => _setHovered(task.taskId, false),
        onTapCancel: () => _setHovered(task.taskId, false),
        borderRadius: BorderRadius.circular(AppFormStyles.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: AppFormStyles.card().copyWith(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isHovered ? 0.1 : 0.05,
                ),
                blurRadius: isHovered ? 6 : 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                isChecked ? Icons.check_box : Icons.check_box_outline_blank,
                color: isChecked ? AppColors.primary : AppColors.outlineVariant,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'Due: ${task.startDate.month}/${task.startDate.day}',
                          style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '•',
                          style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.account_tree,
                          size: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${task.subtasks.length}',
                          style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '•',
                          style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(width: 4),
                        // Task size chip removed (2026-08-06): size option no
                        // longer exists on the add-task screen.
                      ],
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
}
