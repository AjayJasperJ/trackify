import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'social_providers.dart';
import '../domain/entities/public_profile_entity.dart';
import '../domain/entities/public_activity_entity.dart';

final publicProfileStreamProvider = StreamProvider.family<PublicProfileEntity?, String>((ref, uid) {
  return ref.watch(publicProfileRepositoryProvider).streamProfile(uid);
});

final publicActivityProvider = StreamProvider.family<List<PublicCompletedTask>, String>((ref, uid) {
  return ref.watch(publicActivityRepositoryProvider).streamRecentActivities(uid, 30).map((activities) {
    final allTasks = <PublicCompletedTask>[];
    for (final activity in activities) {
      allTasks.addAll(activity.completedTasks);
    }
    allTasks.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return allTasks;
  });
});
