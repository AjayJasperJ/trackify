import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackify/features/authentication/providers/auth_provider.dart';
import '../data/repositories/goal_repository_impl.dart';
import '../data/repositories/milestone_repository_impl.dart';
import '../domain/entities/goal_entity.dart';
import '../domain/entities/milestone_entity.dart';
import '../domain/repositories/goal_repository.dart';
import '../domain/repositories/milestone_repository.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepositoryImpl(firestore: FirebaseFirestore.instance);
});

final milestoneRepositoryProvider = Provider<MilestoneRepository>((ref) {
  return MilestoneRepositoryImpl(firestore: FirebaseFirestore.instance);
});

final goalsStreamProvider = StreamProvider<List<GoalEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  return ref.watch(goalRepositoryProvider).watchGoals(user.uid);
});

final milestonesStreamProvider =
    StreamProvider.family<List<MilestoneEntity>, String>((ref, goalId) {
      final user = ref.watch(currentUserProvider);
      if (user == null) return Stream.value([]);

      return ref
          .watch(milestoneRepositoryProvider)
          .watchMilestones(user.uid, goalId);
    });

final goalProvider = FutureProvider.family<GoalEntity?, String>((ref, goalId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(goalRepositoryProvider).getGoal(user.uid, goalId);
});
