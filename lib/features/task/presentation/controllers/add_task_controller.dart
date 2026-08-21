// ignore_for_file: prefer_initializing_formals
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../goals/domain/entities/goal_entity.dart';
import '../../../goals/domain/entities/milestone_entity.dart';
import '../../../goals/domain/repositories/goal_repository.dart';
import '../../../goals/domain/repositories/milestone_repository.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/entities/subtask_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_size.dart';
import '../../domain/repositories/task_repository.dart';

/// `ponytail:` Plain ChangeNotifier, not Riverpod state — one instance per
/// screen visit, disposed with the screen. Mirrors the old StatefulWidget
/// fields 1:1 so the widget layer becomes a dumb projection of this state.
class AddTaskController extends ChangeNotifier {
  final TaskRepository _taskRepo;
  final GoalRepository _goalRepo;
  final MilestoneRepository _milestoneRepo;

  // ── Immutable form inputs (drive all widgets directly) ─────────────────
  final TextEditingController title;
  final TextEditingController description;
  String? selectedCategory;
  ScheduleType scheduleType;
  List<int> selectedWeekdays;
  List<int> selectedDaysOfMonth;
  List<String> selectedYearlyDates;
  int intervalDays;
  DateTime startDate;
  DateTime? endDate;
  List<SubtaskEntity> subtasks;
  GoalEntity? selectedGoal;
  MilestoneEntity? selectedMilestone;
  String? currentGoalId;
  String? currentMilestoneId;
  TaskTrackingMode trackingMode;
  int? expectedDurationMinutes;
  TimeOfDay? startTimeOfDay;
  TimeOfDay? endTimeOfDay;
  TaskPriority priority;
  double? numericTarget;
  String? numericUnit;
  bool isLoading;

  AddTaskController({
    required TaskRepository taskRepo,
    required GoalRepository goalRepo,
    required MilestoneRepository milestoneRepo,
    TaskEntity? taskToEdit,
    GoalEntity? initialGoal,
  })  : _taskRepo = taskRepo,
        _goalRepo = goalRepo,
        _milestoneRepo = milestoneRepo,
        title = TextEditingController(text: taskToEdit?.title ?? ''),
        description =
            TextEditingController(text: taskToEdit?.description ?? ''),
        selectedCategory = taskToEdit?.category,
        scheduleType = taskToEdit?.schedule.type ?? ScheduleType.daily,
        selectedWeekdays = taskToEdit?.schedule is WeekdayScheduleEntity
            ? List.from(
                (taskToEdit!.schedule as WeekdayScheduleEntity).weekdays,
              )
            : [],
        selectedDaysOfMonth = taskToEdit?.schedule is MonthlyScheduleEntity
            ? List.from(
                (taskToEdit!.schedule as MonthlyScheduleEntity).days,
              )
            : [],
        selectedYearlyDates = taskToEdit?.schedule is YearlyScheduleEntity
            ? List.from(
                (taskToEdit!.schedule as YearlyScheduleEntity).dates,
              )
            : [],
        intervalDays = taskToEdit?.schedule is IntervalScheduleEntity
            ? (taskToEdit!.schedule as IntervalScheduleEntity).intervalDays
            : 1,
        startDate = taskToEdit?.startDate ?? DateTime.now(),
        endDate = taskToEdit?.endDate,
        subtasks = taskToEdit?.subtasks.toList() ?? [],
        selectedGoal = initialGoal,
        currentGoalId = initialGoal?.goalId,
        trackingMode = taskToEdit?.trackingMode ?? TaskTrackingMode.none,
        expectedDurationMinutes = taskToEdit?.expectedDurationMinutes,
        startTimeOfDay = _parseTimeOfDay(taskToEdit?.startTimeOfDay),
        endTimeOfDay = _parseTimeOfDay(taskToEdit?.endTimeOfDay),
        priority = taskToEdit?.priority ?? TaskPriority.medium,
        numericTarget = taskToEdit?.numericTarget,
        numericUnit = taskToEdit?.numericUnit,
        isLoading = false,
        taskId = taskToEdit?.taskId ??
            FirebaseFirestore.instance.collection('tasks').doc().id,
        isEditing = taskToEdit != null,
        _originalCreatedAt = taskToEdit?.createdAt ?? DateTime.now();

  final String taskId;
  final bool isEditing;

  /// Preserved across edits so task history keeps its original creation time.
  final DateTime _originalCreatedAt;

  /// Milestone the task was linked to when editing started (id-level diffing
  /// on save). Stays null until [loadLinkedGoalAndMilestone] succeeds — if
  /// the load fails, milestone linkage is left untouched on save instead of
  /// being unlinked with a bogus goalId.
  MilestoneEntity? _originalMilestone;

  /// Prefill for edit mode: read goal/milestone straight off the task doc
  /// (source of truth) instead of a collectionGroup query, which needs a
  /// composite index and silently fails when it's missing.
  Future<void> loadLinkedGoalAndMilestone(String uid) async {
    if (uid.isEmpty) return;
    try {
      final doc = await _taskRepo.getTask(uid, taskId);
      if (doc == null) return;

      if (doc.goalId != null) {
        final goal = await _goalRepo.getGoal(uid, doc.goalId!);
        if (goal != null) {
          selectedGoal = goal;
          currentGoalId = goal.goalId;
          notifyListeners();
        }
      }

      if (doc.milestoneId != null && doc.goalId != null) {
        final ms = await _milestoneRepo.getMilestone(
          uid,
          doc.goalId!,
          doc.milestoneId!,
        );
        if (ms != null) {
          selectedMilestone = ms;
          _originalMilestone = ms;
          currentMilestoneId = ms.milestoneId;
          notifyListeners();
        }
      }
    } catch (_) {
      // Prefill is best-effort: a transient read failure must not break the
      // edit screen. The user can still re-select the goal/milestone.
    }
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  // ── Mutators (each notifies once; widgets stay dumb) ───────────────────
  void setCategory(String? v) {
    selectedCategory = v;
    notifyListeners();
  }

  void setScheduleType(ScheduleType? t) {
    if (t == null) return;
    scheduleType = t;
    notifyListeners();
  }

  void setWeekdays(List<int> v) {
    selectedWeekdays = v;
    notifyListeners();
  }

  void setDaysOfMonth(List<int> v) {
    selectedDaysOfMonth = v;
    notifyListeners();
  }

  void setYearlyDates(List<String> v) {
    selectedYearlyDates = v;
    notifyListeners();
  }

  void setIntervalDays(int v) {
    intervalDays = v;
    notifyListeners();
  }

  void setStartDate(DateTime d) {
    startDate = d;
    if (endDate != null && endDate!.isBefore(startDate)) endDate = null;
    notifyListeners();
  }

  void setEndDate(DateTime? d) {
    endDate = d;
    notifyListeners();
  }

  void addSubtask() {
    subtasks.add(
      SubtaskEntity(
        subtaskId: FirebaseFirestore.instance.collection('dummy').doc().id,
        title: '',
        order: subtasks.length,
      ),
    );
    notifyListeners();
  }

  void removeSubtask(int index) {
    if (index >= 0 && index < subtasks.length) {
      subtasks.removeAt(index);
      notifyListeners();
    }
  }

  void updateSubtaskTitle(int index, String value) {
    if (index >= 0 && index < subtasks.length) {
      subtasks[index] = subtasks[index].copyWith(title: value);
      notifyListeners();
    }
  }

  void setSubtasks(List<SubtaskEntity> newList) {
    final normalized = List<SubtaskEntity>.from(newList);
    for (var i = 0; i < normalized.length; i++) {
      normalized[i] = normalized[i].copyWith(order: i);
    }
    subtasks = normalized;
    notifyListeners();
  }

  void setGoal(GoalEntity? g) {
    selectedGoal = g;
    selectedMilestone = null;
    currentGoalId = g?.goalId;
    currentMilestoneId = null;
    notifyListeners();
  }

  void setMilestone(MilestoneEntity? m) {
    selectedMilestone = m;
    currentMilestoneId = m?.milestoneId;
    notifyListeners();
  }

  void setTrackingMode(TaskTrackingMode mode) {
    trackingMode = mode;
    notifyListeners();
  }

  void setExpectedDurationMinutes(int? minutes) {
    expectedDurationMinutes = minutes;
    notifyListeners();
  }

  void setStartTimeOfDay(TimeOfDay? time) {
    startTimeOfDay = time;
    notifyListeners();
  }

  void setEndTimeOfDay(TimeOfDay? time) {
    endTimeOfDay = time;
    notifyListeners();
  }

  void setPriority(TaskPriority p) {
    priority = p;
    notifyListeners();
  }

  void setNumericTarget(double? target) {
    numericTarget = target;
    notifyListeners();
  }

  void setNumericUnit(String? unit) {
    numericUnit = unit;
    notifyListeners();
  }

  void setLoading(bool v) {
    isLoading = v;
    notifyListeners();
  }

  // ── Validation helpers (used by the screen before save) ────────────────
  String? get scheduleError {
    switch (scheduleType) {
      case ScheduleType.weekday:
        return selectedWeekdays.isEmpty ? 'Select at least one weekday' : null;
      case ScheduleType.monthly:
        return selectedDaysOfMonth.isEmpty
            ? 'Select at least one day of the month'
            : null;
      case ScheduleType.yearly:
        return selectedYearlyDates.isEmpty
            ? 'Select at least one yearly date'
            : null;
      default:
        return null;
    }
  }

  // ── Persistence ─────────────────────────────────────────────────────────

  Future<void> save(String uid) async {
    final now = DateTime.now();
    final validSubtasks = subtasks
        .where((s) => s.title.trim().isNotEmpty)
        .toList();

    final task = TaskEntity(
      taskId: taskId,
      title: title.text.trim(),
      description: description.text.trim(),
      category: selectedCategory,
      schedule: _buildSchedule(),
      subtasks: validSubtasks,
      // Task size option removed from the add-task screen (2026-08-06);
      // tasks default to TaskSize.medium like all other create paths.
      taskSize: TaskSize.medium,
      startDate: startDate,
      endDate: endDate,
      createdAt: isEditing ? _originalCreatedAt : now,
      updatedAt: now,
      goalId: selectedGoal?.goalId,
      milestoneId: selectedMilestone?.milestoneId,
      trackingMode: trackingMode,
      expectedDurationMinutes: trackingMode == TaskTrackingMode.timer ? expectedDurationMinutes : null,
      startTimeOfDay: _formatTimeOfDay(startTimeOfDay),
      endTimeOfDay: _formatTimeOfDay(endTimeOfDay),
      priority: priority,
      numericTarget: trackingMode == TaskTrackingMode.numeric ? numericTarget : null,
      numericUnit: trackingMode == TaskTrackingMode.numeric ? numericUnit : null,
    );

    if (isEditing) {
      await _taskRepo.updateTask(uid, task);
    } else {
      await _taskRepo.addTask(uid, task);
    }

    // Milestone linking is diffed by ID — the prefetched entities are
    // different object instances than the stream ones, so identity
    // comparison would always treat them as "changed".
    final orig = _originalMilestone;
    final sel = selectedMilestone;
    if (orig != null &&
        sel == null ||
        orig != null && sel != null && orig.milestoneId != sel.milestoneId) {
      await _milestoneRepo.unlinkTaskFromMilestone(
        uid,
        orig.goalId,
        orig.milestoneId,
        taskId,
      );
    }
    if (sel != null &&
        (orig == null || orig.milestoneId != sel.milestoneId)) {
      await _milestoneRepo.linkTaskToMilestone(
        uid,
        sel.goalId,
        sel.milestoneId,
        taskId,
      );
    }
  }

  ScheduleEntity _buildSchedule() {
    switch (scheduleType) {
      case ScheduleType.daily:
        return DailyScheduleEntity();
      case ScheduleType.weekday:
        return WeekdayScheduleEntity(weekdays: selectedWeekdays);
      case ScheduleType.monthly:
        return MonthlyScheduleEntity(days: selectedDaysOfMonth);
      case ScheduleType.yearly:
        return YearlyScheduleEntity(dates: selectedYearlyDates);
      case ScheduleType.interval:
        return IntervalScheduleEntity(intervalDays: intervalDays);
      case ScheduleType.oneTime:
        return const OneTimeScheduleEntity();
    }
  }

  static TimeOfDay? _parseTimeOfDay(String? val) {
    if (val == null || !val.contains(':')) return null;
    final parts = val.split(':');
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  static String? _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return null;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
