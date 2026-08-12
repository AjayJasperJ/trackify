import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/badge_card.dart';
import '../../providers/achievement_providers.dart';
import '../../../authentication/providers/auth_provider.dart';

class BadgeCollectionScreen extends ConsumerWidget {
  const BadgeCollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) {
      return const Center(child: Text('Not logged in'));
    }

    final badgesAsync = ref.watch(userBadgesStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Badge Collection'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: badgesAsync.when(
        data: (badges) {
          if (badges.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('No badges earned yet. Unlock achievements to earn badges!'),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.8,
            ),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              return BadgeCard(badge: badges[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
