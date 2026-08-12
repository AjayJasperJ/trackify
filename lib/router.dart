import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackify/core/presentation/screens/root_navigation_screen.dart';
import 'package:trackify/features/settings/presentation/settings_screen.dart';
import 'features/authentication/presentation/login/login_screen.dart';
import 'features/authentication/presentation/register/register_screen.dart';
import 'features/authentication/presentation/forgot_password/forgot_password_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/authentication/providers/auth_provider.dart';
import 'package:trackify/features/task/presentation/all_tasks_screen.dart';
import 'features/social/presentation/screens/friends_screen.dart';
import 'features/goals/presentation/screens/goals_dashboard_screen.dart';
import 'features/goals/presentation/screens/create_goal_screen.dart';
import 'features/goals/presentation/screens/goal_detail_screen.dart';
import 'features/goals/presentation/screens/milestone_editor_screen.dart';
import 'features/goals/domain/entities/goal_entity.dart';
import 'features/goals/domain/entities/milestone_entity.dart';
import 'features/task/presentation/add_task_screen.dart';
import 'features/task/domain/entities/task_entity.dart';
import 'features/social/presentation/screens/friend_profile_screen.dart';
import 'features/task/presentation/view_task_screen.dart';
import 'features/achievements/presentation/screens/leaderboard_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/onboarding/providers/onboarding_providers.dart';
import 'features/analytics/presentation/overview/analytics_dashboard_screen.dart';
import 'features/achievements/presentation/screens/badge_collection_screen.dart';
import 'features/achievements/presentation/screens/achievement_detail_screen.dart';
import 'features/authentication/presentation/update_password/update_password_screen.dart';
import 'features/achievements/domain/entities/achievement_entity.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final needsOnboarding = ref.watch(needsOnboardingProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/';

      if (authState.isLoading) return null;

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/dashboard';
      }

      // Onboarding gate: a logged-in user with no goals and no tasks goes
      // through onboarding (once) before seeing the dashboard.
      final onboardingPending = needsOnboarding.valueOrNull ?? false;
      if (isLoggedIn && onboardingPending &&
          state.matchedLocation != '/onboarding') {
        return '/onboarding';
      }

      if (isLoggedIn && !onboardingPending &&
          state.matchedLocation == '/onboarding') {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/login'),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return RootNavigationScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/all-tasks',
                builder: (context, state) => const AllTasksScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/goals',
                builder: (context, state) => const GoalsDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/friends',
                builder: (context, state) => const FriendsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/create-goal',
        builder: (context, state) => const CreateGoalScreen(),
      ),
      GoRoute(
        path: '/edit-goal/:goalId',
        builder: (context, state) {
          final goalId = state.pathParameters['goalId']!;
          final goal = state.extra is GoalEntity
              ? state.extra as GoalEntity
              : null;
          return CreateGoalScreen(goalToEdit: goal, goalId: goalId);
        },
      ),
      GoRoute(
        path: '/goal-detail/:goalId',
        builder: (context, state) {
          final goalId = state.pathParameters['goalId']!;
          final goal = state.extra is GoalEntity
              ? state.extra as GoalEntity
              : null;
          return GoalDetailScreen(goalId: goalId, goal: goal);
        },
      ),
      GoRoute(
        path: '/add-milestone/:goalId',
        builder: (context, state) {
          final goalId = state.pathParameters['goalId']!;
          return MilestoneEditorScreen(goalId: goalId);
        },
      ),
      GoRoute(
        path: '/edit-milestone/:goalId',
        builder: (context, state) {
          final goalId = state.pathParameters['goalId']!;
          final milestone = state.extra is MilestoneEntity
              ? state.extra as MilestoneEntity
              : null;
          return MilestoneEditorScreen(
            goalId: goalId,
            milestoneToEdit: milestone,
          );
        },
      ),
      GoRoute(
        path: '/add-task',
        builder: (context, state) {
          final extra = state.extra;
          GoalEntity? initialGoal;
          if (extra is GoalEntity) {
            initialGoal = extra;
          }
          return AddTaskScreen(initialGoal: initialGoal);
        },
      ),
      GoRoute(
        path: '/task/:id',
        redirect: (context, state) {
          if (state.extra == null) return '/dashboard';
          return null;
        },
        builder: (context, state) {
          final task = state.extra as TaskEntity;
          return AddTaskScreen(taskToEdit: task);
        },
      ),
      GoRoute(
        path: '/view-task/:taskId',
        builder: (context, state) {
          final taskId = state.pathParameters['taskId']!;
          final task = state.extra is TaskEntity ? state.extra as TaskEntity : null;
          return ViewTaskScreen(taskId: taskId, task: task);
        },
      ),
      GoRoute(
        path: '/friend-profile/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid']!;
          return FriendProfileScreen(uid: uid);
        },
      ),
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsDashboardScreen(),
      ),
      GoRoute(
        path: '/badge-collection',
        builder: (context, state) => const BadgeCollectionScreen(),
      ),
      GoRoute(
        path: '/achievement-detail',
        builder: (context, state) {
          final achievement = state.extra as AchievementEntity;
          return AchievementDetailScreen(achievement: achievement);
        },
      ),
      GoRoute(
        path: '/update-password',
        builder: (context, state) => const UpdatePasswordScreen(),
      ),
    ],
  );
});
