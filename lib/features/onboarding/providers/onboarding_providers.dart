import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackify/features/authentication/providers/auth_provider.dart';
import 'package:trackify/features/dashboard/providers/dashboard_providers.dart';
import 'package:trackify/features/goals/providers/goal_providers.dart';
import '../data/onboarding_seeder.dart';

final onboardingSeederProvider = Provider<OnboardingSeeder>((ref) {
  return OnboardingSeeder(
    goalRepository: ref.watch(goalRepositoryProvider),
    taskRepository: ref.watch(taskRepositoryProvider),
    firestore: FirebaseFirestore.instance,
  );
});

/// True when the current user has no goals AND no tasks — i.e. a brand-new
/// account that should see onboarding. Existing accounts (with any data)
/// are never routed to onboarding, so this is safe for current users.
final needsOnboardingProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;

  final seeder = ref.watch(onboardingSeederProvider);
  return seeder.isFreshAccount(user.uid);
});
