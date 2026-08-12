import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../goals/domain/entities/goal_entity.dart';
import '../../goals/domain/entities/goal_enums.dart';
import '../../goals/domain/entities/milestone_entity.dart';
import '../../goals/providers/goal_providers.dart';
import '../domain/entities/task_entity.dart';
import '../domain/entities/schedule_entity.dart';
import '../domain/entities/daily_record_entity.dart';
import '../../dashboard/providers/dashboard_providers.dart';

final userTasksStreamProvider = StreamProvider<List<TaskEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  final repository = ref.watch(taskRepositoryProvider);
  // Raw streams (not the AsyncValue wrappers): this provider needs to
  // subscribe directly and merge emissions.
  final goalsRepo = ref.watch(goalRepositoryProvider);
  final goalsStream = goalsRepo.watchGoals(user.uid);

  // Merge pattern without rxdart: whenever tasks OR goals emit, re-resolve
  // the links (e.g. a goal getting completed must expire linked tasks live).
  return Stream<List<TaskEntity>>.multi((controller) {
    StreamSubscription? tasksSub;
    StreamSubscription? goalsSub;
    List<TaskEntity> latestTasks = [];
    List<GoalEntity> latestGoals = [];
    bool tasksReady = false;
    bool goalsReady = false;

    void maybeEmit() {
      if (!tasksReady || !goalsReady) return;
      _resolveTaskLinks(ref, user.uid, latestTasks, latestGoals).then((resolved) {
        if (!controller.isClosed) controller.add(resolved);
      });
    }

    tasksSub = repository.getTasks(user.uid).listen((tasks) {
      latestTasks = tasks;
      tasksReady = true;
      maybeEmit();
    }, onError: (Object e, StackTrace st) {
      if (!controller.isClosed) controller.addError(e, st);
    }, onDone: () {});
    goalsSub = goalsStream.listen((goals) {
      latestGoals = goals;
      goalsReady = true;
      maybeEmit();
    }, onError: (Object e, StackTrace st) {
      if (!controller.isClosed) controller.addError(e, st);
    }, onDone: () {});

    controller.onCancel = () {
      tasksSub?.cancel();
      goalsSub?.cancel();
    };
  });
});

/// Enriches [tasks] with their linked goal/milestone state:
/// - linkedGoalTargetDate / linkedMilestoneDeadline → effectiveEndDate
/// - linkedGoalCompleted / linkedMilestoneCompleted → isExpired
///
/// Falls back to the raw task when a linked entity can't be resolved
/// (e.g. goal deleted → stale link; task keeps its own dates).
Future<List<TaskEntity>> _resolveTaskLinks(
  Ref ref,
  String uid,
  List<TaskEntity> tasks,
  List<GoalEntity> goals,
) async {
  if (tasks.isEmpty) return tasks;

  final goalById = {for (final g in goals) g.goalId: g};

  // Milestones for every referenced goal (only ones actually used by tasks).
  final neededGoalIds = tasks.map((t) => t.goalId).whereType<String>().toSet();
  final milestoneById = <String, MilestoneEntity>{};
  final milestonesRepo = ref.read(milestoneRepositoryProvider);
  for (final goalId in neededGoalIds) {
    final msList = await milestonesRepo
        .getMilestones(uid, goalId)
        .catchError((_) => <MilestoneEntity>[]);
    for (final m in msList) {
      milestoneById['$goalId:${m.milestoneId}'] = m;
    }
  }

  for (final t in tasks) {
    final goal = t.goalId != null ? goalById[t.goalId] : null;
    final milestone = t.goalId != null && t.milestoneId != null
        ? milestoneById['${t.goalId}:${t.milestoneId}']
        : null;
    t.linkedGoalTargetDate = goal?.targetDate;
    t.linkedMilestoneDeadline = milestone?.deadline;
    t.linkedGoalCompleted =
        goal?.status == GoalStatus.completed ||
        goal?.status == GoalStatus.archived;
    t.linkedMilestoneCompleted = milestone?.completed ?? false;
  }
  return tasks;
}

final todayTasksProvider = Provider<AsyncValue<List<TaskEntity>>>((ref) {  final tasksAsync = ref.watch(userTasksStreamProvider);
  
  return tasksAsync.whenData((tasks) {
    final now = DateTime.now();
    final todayWeekday = now.weekday; // 1 = Monday, 7 = Sunday
    
    return tasks.where((task) {
      // Linked goal/milestone completed (or its date passed) → task expires.
      if (task.isExpired) return false;

      // Filter logic based on schedule
      final today = DateTime(now.year, now.month, now.day);
      final start = DateTime(task.startDate.year, task.startDate.month, task.startDate.day);

      // One time tasks or if start date is in the future
      if (task.schedule.type == ScheduleType.oneTime) {
        return start == today;
      }
      
      if (today.isBefore(start)) return false;
      // Use the linked goal/milestone expiry when linked (overrides the
      // task's own endDate — see TaskEntity.effectiveEndDate).
      final effectiveEnd = task.effectiveEndDate;
      if (effectiveEnd != null) {
        final end = DateTime(effectiveEnd.year, effectiveEnd.month, effectiveEnd.day);
        if (today.isAfter(end)) return false;
      }

      switch (task.schedule.type) {
        case ScheduleType.daily:
          return true;
        case ScheduleType.weekday:
          final schedule = task.schedule as WeekdayScheduleEntity;
          return schedule.weekdays.contains(todayWeekday);
        case ScheduleType.monthly:
          final schedule = task.schedule as MonthlyScheduleEntity;
          return schedule.days.contains(now.day);
        case ScheduleType.yearly:
          final schedule = task.schedule as YearlyScheduleEntity;
          final todayStr = '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
          return schedule.dates.contains(todayStr);
        case ScheduleType.interval:
          final schedule = task.schedule as IntervalScheduleEntity;
          final diff = today.difference(start).inDays;
          return diff >= 0 && diff % schedule.intervalDays == 0;
        case ScheduleType.oneTime:
          return false; // Handled above
      }
    }).toList();
  });
});

/// One-shot fetch of a single task by id — used by deep-linkable routes
/// (e.g. `/view-task/:taskId`) that must resolve the entity from data, not
/// from in-memory route state.
final taskProvider = FutureProvider.family<TaskEntity?, String>((ref, taskId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(taskRepositoryProvider).getTask(user.uid, taskId);
});

final todayRecordStreamProvider = StreamProvider<DailyRecordEntity?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);

  final dateString = ref.watch(currentDateStringProvider);
  final repository = ref.watch(taskRecordRepositoryProvider);
  
  return repository.getDailyRecord(user.uid, dateString);
});

final currentStreakStreamProvider = StreamProvider((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  
  final repository = ref.watch(streakRepositoryProvider);
  return repository.getStreak(user.uid);
});
