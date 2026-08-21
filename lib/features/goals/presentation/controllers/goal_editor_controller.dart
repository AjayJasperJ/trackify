// ignore_for_file: prefer_initializing_formals
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import '../../../task/domain/repositories/task_repository.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/entities/goal_enums.dart';
import '../../domain/entities/milestone_entity.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../domain/repositories/milestone_repository.dart';

/// The Goal Type enum used to be declared inside create_goal_screen.dart and
/// imported by child widgets. It now lives with the editor controller so the
/// screen and its cards share one definition.
enum GoalType { open, date, duration }

/// `ponytail:` Not a full editor framework — this is the smallest controller
/// that makes the create-goal flow testable and removes setState churn. If the
/// app grows more editors, promote shared bits (dirty tracking, snackbars)
/// into a common base controller.
class GoalEditorController extends ChangeNotifier {
  final GoalRepository _goalRepo;
  final MilestoneRepository _milestoneRepo;
  final TaskRepository _taskRepo;

  // ── Immutable form inputs (drive all widgets directly) ─────────────────
  final TextEditingController name = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController category = TextEditingController();
  DateTime startDate;
  DateTime? targetDate;
  int? durationDays;
  bool isStrict;
  GoalType goalType;
  GoalPriority priority;
  String icon;
  List<MilestoneEntity> milestones;
  Set<String> selectedTaskIds;
  bool isLoading;

  GoalEditorController({
    required GoalRepository goalRepo,
    required MilestoneRepository milestoneRepo,
    required TaskRepository taskRepo,
    GoalEntity? goalToEdit,
  })  : _goalRepo = goalRepo,
        _milestoneRepo = milestoneRepo,
        _taskRepo = taskRepo,
        goalId = goalToEdit?.goalId ?? const Uuid().v4(),
        startDate = goalToEdit?.startDate ?? DateTime.now(),
        targetDate = goalToEdit?.targetDate,
        durationDays = goalToEdit?.durationDays,
        isStrict = goalToEdit?.isStrict ?? false,
        goalType = goalToEdit?.durationDays != null
            ? GoalType.duration
            : goalToEdit?.targetDate != null
                ? GoalType.date
                : GoalType.open,
        priority = goalToEdit?.priority ?? GoalPriority.medium,
        icon = (goalToEdit?.icon.isNotEmpty ?? false)
            ? goalToEdit!.icon
            : 'work',
        milestones = goalToEdit == null
            ? []
            : // Live stream instances, not the cached copy: the detail screen
              // owns edits to existing milestones; this screen only adds new
              // ones while creating, and edits fields on the goal itself.
              const [],
        selectedTaskIds = goalToEdit == null
            ? <String>{}
            : goalToEdit.linkedTasks.toSet(),
        isLoading = false,
        isEditing = goalToEdit != null,
        _originalCreatedAt = goalToEdit?.createdAt ?? DateTime.now(),
        _originalStatus = goalToEdit?.status ?? GoalStatus.notStarted,
        _originalProgress = goalToEdit?.progress ?? 0.0,
        _originalArchived = goalToEdit?.archived ?? false {
    if (goalToEdit != null) {
      name.text = goalToEdit.title;
      description.text = goalToEdit.description;
      category.text = goalToEdit.category;
    }
  }

  final String goalId;
  final bool isEditing;

  /// Lifecycle fields preserved across edits (never overwritten by the form).
  final DateTime _originalCreatedAt;
  final GoalStatus _originalStatus;
  final double _originalProgress;
  final bool _originalArchived;

  @override
  void dispose() {
    name.dispose();
    description.dispose();
    category.dispose();
    super.dispose();
  }

  // ── Mutators (each notifies once; widgets stay dumb) ───────────────────
  void setStartDate(DateTime d) {
    startDate = d;
    notifyListeners();
  }

  void setTargetDate(DateTime? d) {
    targetDate = d;
    goalType = d != null ? GoalType.date : goalType;
    notifyListeners();
  }

  void setGoalType(GoalType t) {
    goalType = t;
    if (t != GoalType.date) targetDate = null;
    if (t != GoalType.duration) durationDays = null;
    notifyListeners();
  }

  void setDurationDays(int? days) {
    durationDays = days;
    goalType = days != null ? GoalType.duration : goalType;
    notifyListeners();
  }

  void setStrict(bool strict) {
    isStrict = strict;
    notifyListeners();
  }

  void setPriority(GoalPriority p) {
    priority = p;
    notifyListeners();
  }

  void setCategory(String v) {
    category.text = v;
    switch (v) {
      case 'Health':
        icon = 'fitness_center';
        break;
      case 'Finance':
        icon = 'attach_money';
        break;
      case 'Personal':
        icon = 'star';
        break;
      case 'Professional':
      default:
        icon = 'work';
        break;
    }
    notifyListeners();
  }

  void setSelectedTasks(Set<String> ids) {
    selectedTaskIds
      ..clear()
      ..addAll(ids);
    notifyListeners();
  }

  void setIcon(String v) {
    icon = v;
    notifyListeners();
  }

  void toggleTask(String taskId) {
    if (!selectedTaskIds.remove(taskId)) selectedTaskIds.add(taskId);
    notifyListeners();
  }

  /// Adds a brand-new milestone to the in-memory list. `goalId` is empty until
  /// save assigns the goal's final id (goal doc may not exist yet when the
  /// user creates the goal and milestone in one pass).
  void addMilestone({required String title, String description = ''}) {
    milestones.add(
      MilestoneEntity(
        milestoneId: const Uuid().v4(),
        goalId: '',
        title: title,
        description: description,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void removeMilestone(int index) {
    if (index >= 0 && index < milestones.length) {
      milestones.removeAt(index);
      notifyListeners();
    }
  }

  void setLoading(bool v) {
    isLoading = v;
    notifyListeners();
  }

  // ── Persistence ─────────────────────────────────────────────────────────

  /// Persists the goal (+ any new milestones) and backfills `goalId` on every
  /// selected task so task.goalId stays the single source of truth for
  /// goal-task links (goal.linkedTasks is only a cache for card checkboxes).
  Future<void> save(String uid) async {
    if (goalType == GoalType.date) {
      if (targetDate == null) {
        throw Exception('Please select a target date');
      }
      final diff = targetDate!.difference(startDate).inDays;
      if (diff < 10) {
        throw Exception('Goal duration must be at least 10 days');
      }
    }
    
    if (goalType == GoalType.duration) {
      if (durationDays == null || durationDays! <= 0) {
        throw Exception('Please enter a valid duration in days');
      }
    }

    final now = DateTime.now();
    // kept status/progress/archived/createdAt from goalToEdit; hardcoding
    // fresh values here would silently wipe progress on every save.
    int calculatedXP = 1000; // Base XP
    
    switch (priority) {
      case GoalPriority.low:
        calculatedXP += 100;
        break;
      case GoalPriority.medium:
        calculatedXP += 250;
        break;
      case GoalPriority.high:
        calculatedXP += 500;
        break;
      case GoalPriority.critical:
        calculatedXP += 1000;
        break;
    }

    if (targetDate != null) calculatedXP += 500;
    if (durationDays != null) calculatedXP += (durationDays! * 10);
    if (isStrict) calculatedXP += 1000;
    
    calculatedXP += milestones.length * 250;
    calculatedXP += selectedTaskIds.length * 50;

    final goal = GoalEntity(
      goalId: goalId,
      title: name.text.trim(),
      description: description.text.trim(),
      category: category.text.trim().isNotEmpty
          ? category.text.trim()
          : 'Professional',
      icon: icon,
      priority: priority,
      targetXP: calculatedXP,
      startDate: startDate,
      targetDate: targetDate,
      durationDays: durationDays,
      createdAt: _originalCreatedAt,
      updatedAt: now,
      isStrict: isStrict,
      status: _originalStatus,
      progress: _originalProgress,
      archived: _originalArchived,
      linkedTasks: selectedTaskIds.toList(),
    );

    if (isEditing) {
      await _goalRepo.updateGoal(uid, goal);
    } else {
      await _goalRepo.addGoal(uid, goal);
    }

    for (final ms in milestones) {
      await _milestoneRepo.addMilestone(uid, ms.copyWith(goalId: goalId));
    }

    // Idempotent backfill: covers legacy rows where goal.linkedTasks existed
    // but task.goalId was never set, and tasks linked mid-creation.
    final tasks = await _taskRepo.getTasks(uid).first;
    for (final t in tasks) {
      if (selectedTaskIds.contains(t.taskId) && t.goalId != goalId) {
        await _taskRepo.updateTask(
          uid,
          t.copyWith(goalId: goalId, updatedAt: DateTime.now()),
        );
      }
    }
  }
}
