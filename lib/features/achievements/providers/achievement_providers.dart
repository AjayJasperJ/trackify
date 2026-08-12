import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../progression/providers/progression_providers.dart';
import '../application/achievement_service.dart';
import '../../authentication/providers/auth_provider.dart';
import '../data/repositories/achievement_repository_impl.dart';
import '../domain/repositories/achievement_repository.dart';
import '../domain/entities/achievement_entity.dart';
import '../domain/entities/badge_entity.dart';

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  return AchievementRepositoryImpl(FirebaseFirestore.instance);
});

final achievementServiceProvider = Provider<AchievementService>((ref) {
  final repo = ref.watch(achievementRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    throw Exception('User must be logged in to access AchievementService');
  }
  final progRepo = ref.watch(progressionRepositoryProvider);
  return AchievementService(
    achievementRepository: repo,
    progressionRepository: progRepo,
    uid: user.uid,
  );
});

final userAchievementsStreamProvider = StreamProvider<List<AchievementEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(achievementRepositoryProvider).watchUserAchievements(user.uid);
});

final userBadgesStreamProvider = StreamProvider<List<BadgeEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(achievementRepositoryProvider).watchUserBadges(user.uid);
});
