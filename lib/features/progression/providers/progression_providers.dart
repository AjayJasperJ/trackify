import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../authentication/providers/auth_provider.dart';
import '../data/repositories/progression_repository_impl.dart';
import '../domain/entities/progression_entity.dart';
import '../domain/entities/xp_history_entity.dart';
import '../domain/repositories/progression_repository.dart';
import '../domain/services/progression_service.dart';

final progressionRepositoryProvider = Provider<ProgressionRepository>((ref) {
  return ProgressionRepositoryImpl(firestore: FirebaseFirestore.instance);
});

final progressionServiceProvider = Provider<ProgressionService>((ref) {
  final repo = ref.watch(progressionRepositoryProvider);
  return ProgressionService(repository: repo);
});

final currentProgressionProvider = StreamProvider<ProgressionEntity?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value(null);
  }
  final repo = ref.watch(progressionRepositoryProvider);
  return repo.watchProgression(user.uid);
});

final xpHistoryProvider = StreamProvider<List<XPHistoryEntity>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value([]);
  }
  final repo = ref.watch(progressionRepositoryProvider);
  return repo.watchXPHistory(user.uid);
});
