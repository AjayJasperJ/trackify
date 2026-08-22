import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:trackify/features/task/domain/entities/task_entity.dart';
import 'package:trackify/features/task/domain/entities/schedule_entity.dart';
import 'package:trackify/features/task/domain/entities/task_size.dart';
import 'package:trackify/features/task/domain/entities/streak_entity.dart';
import 'package:trackify/features/goals/domain/entities/goal_enums.dart';
import 'package:trackify/features/goals/domain/entities/goal_entity.dart';
import 'package:trackify/features/goals/domain/entities/milestone_entity.dart';
import 'package:trackify/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:trackify/features/goals/data/repositories/milestone_repository_impl.dart';
import 'package:trackify/features/task/data/repositories/task_record_repository_impl.dart';
import 'package:trackify/features/progression/domain/services/progression_service.dart';
import 'package:trackify/features/progression/data/repositories/progression_repository_impl.dart';

void main() {
  group('1. Schedule Entity Unit Tests', () {
    test('DailyScheduleEntity creation & mapping', () {
      final schedule = DailyScheduleEntity();
      expect(schedule.type, ScheduleType.daily);
      expect(schedule.toMap()['type'], 'daily');
    });

    test('WeekdayScheduleEntity weekdays serialization', () {
      final schedule = WeekdayScheduleEntity(weekdays: [1, 3, 5]);
      expect(schedule.type, ScheduleType.weekday);
      expect(schedule.weekdays, [1, 3, 5]);
      expect(schedule.toMap()['weekdays'], [1, 3, 5]);
    });

    test('MonthlyScheduleEntity serialization', () {
      final schedule = MonthlyScheduleEntity(days: [1, 15, 30]);
      expect(schedule.type, ScheduleType.monthly);
      expect(schedule.days, [1, 15, 30]);
      expect(schedule.toMap()['days'], [1, 15, 30]);
    });

    test('IntervalScheduleEntity serialization', () {
      final schedule = IntervalScheduleEntity(intervalDays: 4);
      expect(schedule.type, ScheduleType.interval);
      expect(schedule.intervalDays, 4);
      expect(schedule.toMap()['intervalDays'], 4);
    });

    test('OneTimeScheduleEntity serialization', () {
      const schedule = OneTimeScheduleEntity();
      expect(schedule.type, ScheduleType.oneTime);
      expect(schedule.toMap()['type'], 'oneTime');
    });
  });

  group('2. Task Entity & Linkages / Expiry Tests', () {
    test('TaskEntity deadline cascade precedence (effectiveEndDate)', () {
      final task = TaskEntity(
        taskId: 't1',
        title: 'Task 1',
        schedule: DailyScheduleEntity(),
        startDate: DateTime.now(),
        endDate: DateTime(2026, 8, 30),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Default fallback: task's own endDate
      expect(task.effectiveEndDate, DateTime(2026, 8, 30));

      // With storedEffectiveEndDate
      final taskWithStored = task.copyWith(storedEffectiveEndDate: DateTime(2026, 8, 29));
      expect(taskWithStored.effectiveEndDate, DateTime(2026, 8, 29));

      // With goal target date set
      task.linkedGoalTargetDate = DateTime(2026, 8, 25);
      expect(task.effectiveEndDate, DateTime(2026, 8, 25));

      // With milestone deadline set (milestone deadline should win over goal target date)
      task.linkedMilestoneDeadline = DateTime(2026, 8, 20);
      expect(task.effectiveEndDate, DateTime(2026, 8, 20));
    });

    test('isExpired is true if parent Goal/Milestone is completed', () {
      final task = TaskEntity(
        taskId: 't2',
        title: 'Task 2',
        schedule: DailyScheduleEntity(),
        startDate: DateTime.now(),
        endDate: DateTime(2026, 9, 30),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(task.isExpired, isFalse);

      task.linkedGoalCompleted = true;
      expect(task.isExpired, isTrue);

      task.linkedGoalCompleted = false;
      task.linkedMilestoneCompleted = true;
      expect(task.isExpired, isTrue);
    });

    test('isExpired is true if deadline has passed', () {
      final task = TaskEntity(
        taskId: 't3',
        title: 'Task 3',
        schedule: DailyScheduleEntity(),
        startDate: DateTime.now(),
        endDate: DateTime(2026, 8, 10), // Passed date relative to current time 2026-08-22
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(task.isExpired, isTrue);
    });
  });

  group('3. Progression Service Calculations', () {
    late ProgressionService service;
    late ProgressionRepositoryImpl repo;
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repo = ProgressionRepositoryImpl(firestore: firestore);
      service = ProgressionService(repository: repo);
    });

    test('Base XP scaling per task size', () {
      expect(service.getBaseXP(TaskSize.tiny), 5);
      expect(service.getBaseXP(TaskSize.small), 10);
      expect(service.getBaseXP(TaskSize.medium), 20);
      expect(service.getBaseXP(TaskSize.large), 40);
      expect(service.getBaseXP(TaskSize.huge), 75);
    });

    test('Streak multiplier rewards', () {
      expect(service.getStreakMultiplier(0), 0.0);
      expect(service.getStreakMultiplier(5), 0.0);
      expect(service.getStreakMultiplier(7), 0.05);
      expect(service.getStreakMultiplier(15), 0.10);
      expect(service.getStreakMultiplier(30), 0.15);
      expect(service.getStreakMultiplier(60), 0.20);
      expect(service.getStreakMultiplier(100), 0.30);
      expect(service.getStreakMultiplier(365), 0.50);
    });

    test('Focus Score calculation logic', () {
      final task = TaskEntity(
        taskId: 't4',
        title: 'Task 4',
        schedule: DailyScheduleEntity(),
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        priority: TaskPriority.high, // +15
        trackingMode: TaskTrackingMode.timer, // +20
      );

      // Base: 50. Priority High: +15. Tracking timer: +20. No subtasks: +15. Streak: 0. Mood: null (+7.5)
      // Total score = 50 + 15 + 20 + 15 + 0 + 7.5 = 107.5, clamped to 100
      double score = service.calculateTaskFocusScore(task, 0, 0, null);
      expect(score, 100.0);

      // Lower priority and mood reflection
      final task2 = TaskEntity(
        taskId: 't5',
        title: 'Task 5',
        schedule: DailyScheduleEntity(),
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        priority: TaskPriority.low, // +5
        trackingMode: TaskTrackingMode.none, // +0
      );
      // Base: 50. Priority Low: +5. Tracking: +0. No subtasks: +15. Streak 4: +2. Mood 2.0 (Low): +4
      // Total score = 50 + 5 + 0 + 15 + 2 + 4 = 76.0
      double score2 = service.calculateTaskFocusScore(task2, 0, 4, 2.0);
      expect(score2, 76.0);
    });
  });

  group('4. Database & Repository Integration Tests (Non-Cheating)', () {
    late FakeFirebaseFirestore firestore;
    late GoalRepositoryImpl goalRepo;
    late MilestoneRepositoryImpl milestoneRepo;
    late TaskRecordRepositoryImpl taskRecordRepo;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      goalRepo = GoalRepositoryImpl(firestore: firestore);
      milestoneRepo = MilestoneRepositoryImpl(firestore: firestore);
      taskRecordRepo = TaskRecordRepositoryImpl(firestore);
    });

    test('Goal completion archives all active linked tasks', () async {
      const uid = 'user1';
      final goal = GoalEntity(
        goalId: 'g1',
        title: 'Learn Flutter',
        description: 'Master Flutter framework',
        category: 'work',
        icon: 'code',
        status: GoalStatus.active,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final task1 = TaskEntity(
        taskId: 't1',
        title: 'Watch widget tutorial',
        schedule: DailyScheduleEntity(),
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        goalId: 'g1',
        isArchived: false,
      );

      final task2 = TaskEntity(
        taskId: 't2',
        title: 'Build counter app',
        schedule: DailyScheduleEntity(),
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        goalId: 'g1',
        isArchived: false,
      );

      // Add goal and tasks to fake store
      await firestore.collection('users').doc(uid).collection('goals').doc('g1').set(goal.toMap());
      await firestore.collection('users').doc(uid).collection('tasks').doc('t1').set(task1.toMap());
      await firestore.collection('users').doc(uid).collection('tasks').doc('t2').set(task2.toMap());

      // Update goal status to completed
      final completedGoal = goal.copyWith(status: GoalStatus.completed);
      await goalRepo.updateGoal(uid, completedGoal);

      // Verify that tasks are archived
      final snap1 = await firestore.collection('users').doc(uid).collection('tasks').doc('t1').get();
      final snap2 = await firestore.collection('users').doc(uid).collection('tasks').doc('t2').get();

      expect(snap1.data()!['isArchived'], true);
      expect(snap2.data()!['isArchived'], true);
    });

    test('Milestone completion archives all active linked tasks', () async {
      const uid = 'user2';
      final milestone = MilestoneEntity(
        milestoneId: 'm1',
        goalId: 'g1',
        title: 'Milestone 1',
        description: 'First stage',
        completed: false,
        createdAt: DateTime.now(),
      );

      // Add goal, milestone and link a task to it
      await firestore.collection('users').doc(uid).collection('goals').doc('g1').set({
        'goalId': 'g1',
        'targetDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      });
      await firestore.collection('users').doc(uid).collection('goals').doc('g1').collection('milestones').doc('m1').set(milestone.toMap());
      await milestoneRepo.linkTaskToMilestone(uid, 'g1', 'm1', 't3');

      final task = TaskEntity(
        taskId: 't3',
        title: 'Linked task',
        schedule: DailyScheduleEntity(),
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        goalId: 'g1',
        milestoneId: 'm1',
        isArchived: false,
      );
      await firestore.collection('users').doc(uid).collection('tasks').doc('t3').set(task.toMap());

      // Complete the milestone manually
      final completedMs = milestone.copyWith(completed: true);
      await milestoneRepo.updateMilestone(uid, completedMs);

      // Verify that the task is archived
      final snap = await firestore.collection('users').doc(uid).collection('tasks').doc('t3').get();
      expect(snap.data()!['isArchived'], true);
    });

    test('updateTaskContribution completion rule (allTasks) archives tasks on milestone completion', () async {
      const uid = 'user3';
      final milestone = MilestoneEntity(
        milestoneId: 'm2',
        goalId: 'g1',
        title: 'Milestone 2',
        description: 'Second stage',
        completed: false,
        completionRule: MilestoneCompletionRule.allTasks,
        createdAt: DateTime.now(),
      );

      await firestore.collection('users').doc(uid).collection('goals').doc('g1').set({
        'goalId': 'g1',
        'targetDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      });
      await firestore.collection('users').doc(uid).collection('goals').doc('g1').collection('milestones').doc('m2').set(milestone.toMap());
      await milestoneRepo.linkTaskToMilestone(uid, 'g1', 'm2', 't4');
      await milestoneRepo.linkTaskToMilestone(uid, 'g1', 'm2', 't5');

      final task4 = TaskEntity(
        taskId: 't4',
        title: 'Task 4',
        schedule: DailyScheduleEntity(),
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        goalId: 'g1',
        milestoneId: 'm2',
      );
      final task5 = TaskEntity(
        taskId: 't5',
        title: 'Task 5',
        schedule: DailyScheduleEntity(),
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        goalId: 'g1',
        milestoneId: 'm2',
      );

      await firestore.collection('users').doc(uid).collection('tasks').doc('t4').set(task4.toMap());
      await firestore.collection('users').doc(uid).collection('tasks').doc('t5').set(task5.toMap());

      // Update contribution for t4 (contribution = weight when completed)
      await milestoneRepo.updateTaskContribution(uid, 'g1', 'm2', 't4', 1);

      // Milestone should still be incomplete
      var msSnap = await firestore.collection('users').doc(uid).collection('goals').doc('g1').collection('milestones').doc('m2').get();
      expect(msSnap.data()!['completed'], false);

      // Complete task 5 (the final task)
      await milestoneRepo.updateTaskContribution(uid, 'g1', 'm2', 't5', 1);

      // Milestone should now be completed and all tasks archived
      msSnap = await firestore.collection('users').doc(uid).collection('goals').doc('g1').collection('milestones').doc('m2').get();
      expect(msSnap.data()!['completed'], true);

      final t4Snap = await firestore.collection('users').doc(uid).collection('tasks').doc('t4').get();
      final t5Snap = await firestore.collection('users').doc(uid).collection('tasks').doc('t5').get();
      expect(t4Snap.data()!['isArchived'], true);
      expect(t5Snap.data()!['isArchived'], true);
    });

    test('Task completion streak increments and reverts safely', () async {
      const uid = 'user4';
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      
      final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final yesterdayStr = "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";

      // Mock streak data and yesterday record completed to keep streak going
      await firestore.collection('users').doc(uid).collection('streak').doc('current').set(
        StreakEntity(
          currentStreak: 4,
          longestStreak: 4,
          lastCompletedDate: yesterdayStr,
          totalCompletedDays: 4,
          updatedAt: yesterday,
        ).toMap()
      );

      await firestore.collection('users').doc(uid).collection('task_records').doc(yesterdayStr).set({
        'completedTasks': {
          'task_yesterday': {
            'taskId': 'task_yesterday',
            'completed': true,
          }
        }
      });

      final task = TaskEntity(
        taskId: 't_today',
        title: 'Today Task',
        schedule: DailyScheduleEntity(),
        startDate: now,
        createdAt: now,
        updatedAt: now,
      );

      // Complete the task today. Streak should become 5.
      await taskRecordRepo.toggleTaskCompletion(uid, todayStr, task, true);

      var streakSnap = await firestore.collection('users').doc(uid).collection('streak').doc('current').get();
      expect(streakSnap.data()!['currentStreak'], 5);

      // Revert the task today. Streak should rollback to yesterday's value (4).
      await taskRecordRepo.toggleTaskCompletion(uid, todayStr, task, false);

      streakSnap = await firestore.collection('users').doc(uid).collection('streak').doc('current').get();
      expect(streakSnap.data()!['currentStreak'], 4);
    });

    test('Private tasks are not recorded in public activity feed', () async {
      const uid = 'user_private';
      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final privateTask = TaskEntity(
        taskId: 't_private',
        title: 'Secret Task',
        schedule: DailyScheduleEntity(),
        startDate: now,
        createdAt: now,
        updatedAt: now,
        isPrivate: true,
      );

      // Complete the private task
      await taskRecordRepo.toggleTaskCompletion(uid, todayStr, privateTask, true);

      // Verify that the task is recorded in the private task_records collection
      final recordSnap = await firestore.collection('users').doc(uid).collection('task_records').doc(todayStr).get();
      expect(recordSnap.exists, true);
      expect(recordSnap.data()!['completedTasks']['t_private']['completed'], true);

      // Verify that it is NOT recorded in the public_activity collection!
      final publicSnap = await firestore.collection('users').doc(uid).collection('public_activity').doc(todayStr).get();
      expect(publicSnap.exists, false);
    });

    test('Tasks linked to a private goal are not recorded in public activity feed', () async {
      const uid = 'user_private_goal';
      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      // Create a private goal in firestore
      final privateGoal = GoalEntity(
        goalId: 'g_private',
        title: 'Secret Goal',
        description: 'Classified',
        category: 'Personal',
        icon: 'lock',
        startDate: now,
        createdAt: now,
        updatedAt: now,
        isPrivate: true,
      );
      await firestore.collection('users').doc(uid).collection('goals').doc('g_private').set(privateGoal.toMap());

      final publicTaskLinkedToPrivateGoal = TaskEntity(
        taskId: 't_linked_private',
        title: 'Sub Task',
        schedule: DailyScheduleEntity(),
        startDate: now,
        createdAt: now,
        updatedAt: now,
        goalId: 'g_private',
        isPrivate: false, // Task itself is public, but goal is private!
      );

      // Complete the task
      await taskRecordRepo.toggleTaskCompletion(uid, todayStr, publicTaskLinkedToPrivateGoal, true);

      // Verify that it is NOT recorded in the public_activity collection!
      final publicSnap = await firestore.collection('users').doc(uid).collection('public_activity').doc(todayStr).get();
      expect(publicSnap.exists, false);
    });

    test('Task completion updates Milestone progress which cascades to Goal progress', () async {
      const uid = 'user_cascade_goal';
      final now = DateTime.now();

      // Create goal, milestone, task
      final goal = GoalEntity(
        goalId: 'g_cascade',
        title: 'Cascade Goal',
        description: 'Test goal cascade',
        category: 'Personal',
        icon: 'star',
        status: GoalStatus.notStarted,
        progress: 0.0,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      );
      await firestore.collection('users').doc(uid).collection('goals').doc('g_cascade').set(goal.toMap());

      final milestone = MilestoneEntity(
        milestoneId: 'm_cascade',
        goalId: 'g_cascade',
        title: 'Cascade Milestone',
        description: 'Test milestone cascade',
        completed: false,
        progress: 0.0,
        createdAt: now,
      );
      await firestore.collection('users').doc(uid).collection('goals').doc('g_cascade').collection('milestones').doc('m_cascade').set(milestone.toMap());
      await milestoneRepo.linkTaskToMilestone(uid, 'g_cascade', 'm_cascade', 't_cascade');

      final task = TaskEntity(
        taskId: 't_cascade',
        title: 'Cascade Task',
        schedule: DailyScheduleEntity(),
        startDate: now,
        createdAt: now,
        updatedAt: now,
        goalId: 'g_cascade',
        milestoneId: 'm_cascade',
      );
      await firestore.collection('users').doc(uid).collection('tasks').doc('t_cascade').set(task.toMap());

      // Update task contribution (i.e. complete the task)
      await milestoneRepo.updateTaskContribution(uid, 'g_cascade', 'm_cascade', 't_cascade', 1);

      // Verify milestone progress is 1.0 (completed)
      final msSnap = await firestore.collection('users').doc(uid).collection('goals').doc('g_cascade').collection('milestones').doc('m_cascade').get();
      expect(msSnap.data()!['completed'], true);
      expect(msSnap.data()!['progress'], 1.0);

      // Verify goal progress is updated to 1.0 and status is completed!
      final goalSnap = await firestore.collection('users').doc(uid).collection('goals').doc('g_cascade').get();
      expect(goalSnap.data()!['progress'], 1.0);
      expect(goalSnap.data()!['status'], 'completed');
    });
  });
}
