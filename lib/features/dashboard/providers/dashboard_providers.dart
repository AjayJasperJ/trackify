import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../progression/providers/progression_providers.dart';

import '../data/repositories/streak_repository_impl.dart';
import '../../task/data/repositories/task_record_repository_impl.dart';
import '../../task/data/repositories/task_repository_impl.dart';
import '../../task/domain/repositories/streak_repository.dart';
import '../../task/domain/repositories/task_record_repository.dart';
import '../../task/domain/repositories/task_repository.dart';


final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(
    ref.watch(firestoreProvider),
    progressionService: ref.watch(progressionServiceProvider),
  );
});

final taskRecordRepositoryProvider = Provider<TaskRecordRepository>((ref) {
  return TaskRecordRepositoryImpl(
    ref.watch(firestoreProvider),
  );
});

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return StreakRepositoryImpl(ref.watch(firestoreProvider));
});

// Current Date String Provider for filtering
final currentDateStringProvider = StateProvider<String>((ref) {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
});
