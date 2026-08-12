import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackify/features/goals/domain/entities/goal_entity.dart';
import 'package:trackify/features/goals/domain/entities/goal_enums.dart';
import 'package:trackify/features/goals/domain/repositories/goal_repository.dart';
import 'package:trackify/features/task/domain/entities/schedule_entity.dart';
import 'package:trackify/features/task/domain/entities/task_entity.dart';
import 'package:trackify/features/task/domain/entities/task_size.dart';
import 'package:trackify/features/task/domain/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';

/// Preset starter goals shown on onboarding Step 1.
/// Each preset carries an icon/color plus 2–3 starter tasks with sensible
/// schedules, so the dashboard, streaks and XP light up immediately.
class OnboardingGoalPreset {
  final String title;
  final String description;
  final String icon;
  final String color;
  final GoalPriority priority;
  final int targetXP;
  final List<OnboardingTaskPreset> tasks;

  const OnboardingGoalPreset({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.priority,
    required this.targetXP,
    required this.tasks,
  });
}

class OnboardingTaskPreset {
  final String title;
  final String category;
  final TaskSize taskSize;

  const OnboardingTaskPreset({
    required this.title,
    required this.category,
    required this.taskSize,
  });
}

const List<OnboardingGoalPreset> onboardingGoalPresets = [
  OnboardingGoalPreset(
    title: 'Read more',
    description: 'Build a daily reading habit, one chapter at a time.',
    icon: '📚',
    color: '#0F6CBD',
    priority: GoalPriority.medium,
    targetXP: 500,
    tasks: [
      OnboardingTaskPreset(
        title: 'Read 20 pages',
        category: 'Reading',
        taskSize: TaskSize.medium,
      ),
      OnboardingTaskPreset(
        title: 'Read 10 pages',
        category: 'Reading',
        taskSize: TaskSize.small,
      ),
    ],
  ),
  OnboardingGoalPreset(
    title: 'Get fit',
    description: 'Move your body every day and build strength.',
    icon: '💪',
    color: '#E0432F',
    priority: GoalPriority.high,
    targetXP: 800,
    tasks: [
      OnboardingTaskPreset(
        title: 'Workout 30 min',
        category: 'Fitness',
        taskSize: TaskSize.large,
      ),
      OnboardingTaskPreset(
        title: '10 min stretching',
        category: 'Fitness',
        taskSize: TaskSize.tiny,
      ),
      OnboardingTaskPreset(
        title: '5,000 steps',
        category: 'Fitness',
        taskSize: TaskSize.small,
      ),
    ],
  ),
  OnboardingGoalPreset(
    title: 'Learn something new',
    description: 'Pick a skill and practice a little every day.',
    icon: '🧠',
    color: '#8A5CF6',
    priority: GoalPriority.medium,
    targetXP: 600,
    tasks: [
      OnboardingTaskPreset(
        title: 'Study 25 min',
        category: 'Learning',
        taskSize: TaskSize.medium,
      ),
      OnboardingTaskPreset(
        title: 'Review notes 10 min',
        category: 'Learning',
        taskSize: TaskSize.small,
      ),
    ],
  ),
  OnboardingGoalPreset(
    title: 'Drink more water',
    description: 'Stay hydrated with a simple daily check-in.',
    icon: '💧',
    color: '#0E8FD5',
    priority: GoalPriority.low,
    targetXP: 300,
    tasks: [
      OnboardingTaskPreset(
        title: 'Drink 8 glasses',
        category: 'Health',
        taskSize: TaskSize.tiny,
      ),
    ],
  ),
];

/// Seeds a fresh account with the chosen preset goal + starter tasks.
/// Uses the existing repositories so Firestore shape matches the rest of
/// the app (goals subcollection, tasks subcollection, weekday schedule).
class OnboardingSeeder {
  final GoalRepository goalRepository;
  final TaskRepository taskRepository;
  final FirebaseFirestore _firestore;

  OnboardingSeeder({
    required this.goalRepository,
    required this.taskRepository,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Persists the chosen weekdays so other screens can read the user's
  /// rhythm (e.g. dashboard "today" queries).
  Future<void> saveWeeklyRhythm(
    String uid,
    List<int> weekdays,
    DateTime reminderTime,
  ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .set({
          'weeklyRhythm': {
            'weekdays': weekdays,
            'reminderTime': reminderTime.toIso8601String(),
          },
        }, SetOptions(merge: true))
        .catchError((_) {});
  }

  Future<void> seed(
    String uid,
    OnboardingGoalPreset preset,
    List<int> weekdays,
    DateTime reminderTime,
  ) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day);

    final goal = GoalEntity(
      goalId: _uuid(),
      title: preset.title,
      description: preset.description,
      category: preset.title,
      icon: preset.icon,
      priority: preset.priority,
      status: GoalStatus.active,
      progress: 0,
      targetAmount: 100,
      unit: '%',
      targetXP: preset.targetXP,
      startDate: startDate,
      targetDate: DateTime(startDate.year + 1, startDate.month, startDate.day),
      createdAt: now,
      updatedAt: now,
    );
    await goalRepository.addGoal(uid, goal);

    for (final taskPreset in preset.tasks) {
      final task = TaskEntity(
        taskId: _uuid(),
        title: taskPreset.title,
        category: taskPreset.category,
        schedule: weekdays.isEmpty
            ? const DailyScheduleEntity()
            : WeekdayScheduleEntity(weekdays: weekdays),
        taskSize: taskPreset.taskSize,
        startDate: startDate,
        createdAt: now,
        updatedAt: now,
        goalId: goal.goalId,
      );
      await taskRepository.addTask(uid, task);
    }

    await saveWeeklyRhythm(uid, weekdays, reminderTime);
  }

  String _uuid() => const Uuid().v4();

  /// A fresh account has no goals and no tasks. Checking both collections
  /// makes the gate robust: a user who only ever added tasks (no goals) is
  /// not a new user, and vice versa.
  Future<bool> isFreshAccount(String uid) async {
    try {
      final goals = await _firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .limit(1)
          .get();
      if (goals.docs.isNotEmpty) return false;

      final tasks = await _firestore
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .limit(1)
          .get();
      return tasks.docs.isEmpty;
    } catch (_) {
      // On any read failure, don't trap the user in onboarding — let them
      // through to the dashboard.
      return false;
    }
  }
}
