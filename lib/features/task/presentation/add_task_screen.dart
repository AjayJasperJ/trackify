import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trackify/features/authentication/providers/auth_provider.dart';
import 'package:trackify/widgets/dashboard_app_bar.dart';
import 'package:trackify/features/task/domain/entities/task_entity.dart';
import 'package:trackify/features/dashboard/providers/dashboard_providers.dart';
import 'package:trackify/theme/app_colors.dart';
import 'package:trackify/widgets/form_primary_button.dart';
import 'package:trackify/widgets/form_section_card.dart';

import 'add_task_widgets/add_task_header.dart';
import 'add_task_widgets/add_task_info_card.dart';
import 'add_task_widgets/add_task_schedule_card.dart';
import 'add_task_widgets/add_task_tracking_card.dart';
import 'add_task_widgets/add_task_subtasks_card.dart';
import 'add_task_widgets/add_task_link_goal_card.dart';
import 'package:trackify/features/goals/domain/entities/milestone_entity.dart';
import 'package:trackify/features/goals/domain/entities/goal_entity.dart';
import 'package:trackify/features/goals/providers/goal_providers.dart';
import 'controllers/add_task_controller.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  final TaskEntity? taskToEdit;
  final GoalEntity? initialGoal;
  const AddTaskScreen({super.key, this.taskToEdit, this.initialGoal});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AddTaskController _controller;

  final List<String> _categories = [
    'Personal',
    'Professional',
    'School',
    'Gym',
    'Other',
  ];

  final List<String> _weekdayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    _controller = AddTaskController(
      taskRepo: ref.read(taskRepositoryProvider),
      goalRepo: ref.read(goalRepositoryProvider),
      milestoneRepo: ref.read(milestoneRepositoryProvider),
      taskToEdit: task,
      initialGoal: widget.initialGoal,
    );

    final category = _controller.selectedCategory;
    if (category != null && !_categories.contains(category)) {
      _categories.add(category);
    }

    if (task != null) {
      _controller.loadLinkedGoalAndMilestone(
        ref.read(currentUserProvider)?.uid ?? '',
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart
        ? _controller.startDate
        : (_controller.endDate ?? _controller.startDate);
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      if (isStart) {
        _controller.setStartDate(selectedDate);
      } else {
        _controller.setEndDate(selectedDate);
      }
    }
  }

  Future<DateTime?> _addYearlyDate() async {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final scheduleError = _controller.scheduleError;
    if (scheduleError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(scheduleError)));
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('You must be logged in')));
      return;
    }

    _controller.setLoading(true);
    try {
      await _controller.save(user.uid);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save task: $e')));
      }
    } finally {
      if (mounted) _controller.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => _controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  // Main Scrollable Content
                  SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: topPadding + 56 + 24, // Top nav + padding
                      bottom:
                          bottomPadding + 64 + 80, // Bottom nav + Sticky button
                      left: 16.0,
                      right: 16.0,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AddTaskHeader(isEditing: _controller.isEditing),
                          if (widget.initialGoal != null) ...[
                            const SizedBox(height: 16),
                            FormSectionCard(
                              icon: Icons.link,
                              title: 'LINKED GOAL',
                              children: [
                                Text(
                                  widget.initialGoal!.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 24),
                          AddTaskInfoCard(
                            titleController: _controller.title,
                            descriptionController: _controller.description,
                            selectedCategory: _controller.selectedCategory,
                            priority: _controller.priority,
                            categories: _categories,
                            onCategoryChanged: _controller.setCategory,
                            onPriorityChanged: _controller.setPriority,
                          ),
                          const SizedBox(height: 24),
                          AddTaskScheduleCard(
                            scheduleType: _controller.scheduleType,
                            onScheduleTypeChanged: _controller.setScheduleType,
                            selectedWeekdays: _controller.selectedWeekdays,
                            onWeekdaysChanged: _controller.setWeekdays,
                            weekdayNames: _weekdayNames,
                            selectedDaysOfMonth:
                                _controller.selectedDaysOfMonth,
                            onDaysOfMonthChanged: _controller.setDaysOfMonth,
                            selectedYearlyDates:
                                _controller.selectedYearlyDates,
                            onYearlyDatesChanged: _controller.setYearlyDates,
                            intervalDays: _controller.intervalDays,
                            onIntervalDaysChanged: _controller.setIntervalDays,
                            startDate: _controller.startDate,
                            endDate: _controller.endDate,
                            onSelectStartDate: () => _selectDate(context, true),
                            onSelectEndDate: () => _selectDate(context, false),
                            onAddYearlyDate: _addYearlyDate,
                          ),
                          const SizedBox(height: 24),
                          AddTaskTrackingCard(
                            trackingMode: _controller.trackingMode,
                            expectedDurationMinutes: _controller.expectedDurationMinutes,
                            numericTarget: _controller.numericTarget,
                            numericUnit: _controller.numericUnit,
                            startTimeOfDay: _controller.startTimeOfDay,
                            endTimeOfDay: _controller.endTimeOfDay,
                            onTrackingModeChanged: _controller.setTrackingMode,
                            onExpectedDurationChanged: _controller.setExpectedDurationMinutes,
                            onNumericTargetChanged: _controller.setNumericTarget,
                            onNumericUnitChanged: _controller.setNumericUnit,
                            onStartTimeChanged: _controller.setStartTimeOfDay,
                            onEndTimeChanged: _controller.setEndTimeOfDay,
                          ),
                          const SizedBox(height: 24),
                          Consumer(
                            builder: (context, ref, child) {
                              final goalsAsync = ref.watch(goalsStreamProvider);
                              final goals = goalsAsync.valueOrNull ?? [];

                              final milestonesAsync =
                                  _controller.selectedGoal != null
                                  ? ref.watch(
                                      milestonesStreamProvider(
                                        _controller.selectedGoal!.goalId,
                                      ),
                                    )
                                  : const AsyncValue<
                                      List<MilestoneEntity>
                                    >.data([]);
                              final milestones =
                                  milestonesAsync.valueOrNull ?? [];

                              return AddTaskLinkGoalCard(
                                selectedGoal: _controller.selectedGoal,
                                selectedMilestone:
                                    _controller.selectedMilestone,
                                goals: goals,
                                milestones: milestones,
                                // Select by ID: prefilled entities (from
                                // getGoal/getMilestone) are different
                                // instances than stream ones, so identity
                                // matching fails.
                                selectedGoalId: _controller.currentGoalId,
                                selectedMilestoneId:
                                    _controller.currentMilestoneId,
                                onGoalChanged: _controller.setGoal,
                                onMilestoneChanged: _controller.setMilestone,
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          AddTaskSubtasksCard(
                            subtasks: _controller.subtasks,
                            onSubtasksChanged: _controller.setSubtasks,
                            onAddSubtask: _controller.addSubtask,
                          ),
                          const SizedBox(height: 24),
                          // AddTaskPreviewCard: cosmetic "DASHBOARD PREVIEW"
                          // that only echoes title/size. Commented out instead
                          // of deleted — may be reused once real preview data
                          // exists.
                          // AddTaskPreviewCard(
                          //   title: _titleController.text,
                          //   selectedCategory: _selectedCategory,
                          //   selectedTaskSize: _selectedTaskSize,
                          // ),
                        ],
                      ),
                    ),
                  ),

                  // Top Header (Blurred)
                  DashboardAppBar(
                    title: _controller.isEditing
                        ? 'Edit Task'
                        : 'Create Task',
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
                            text: _controller.isEditing
                                ? 'Save Changes'
                                : 'Create Task',
                            onPressed: _saveTask,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
