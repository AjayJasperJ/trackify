import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/achievement_card.dart';
import '../widgets/badge_card.dart';
import '../../providers/achievement_providers.dart';
import '../../../authentication/providers/auth_provider.dart';

class AchievementsDashboardScreen extends ConsumerWidget {
  const AchievementsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) {
      return const Center(child: Text('Not logged in'));
    }

    final achievementsAsync = ref.watch(userAchievementsStreamProvider);
    final badgesAsync = ref.watch(userBadgesStreamProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Achievements & Badges'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => context.push('/leaderboard'),
                  icon: const Icon(Icons.emoji_events_outlined, size: 18),
                  label: const Text('Leaderboard'),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Badges',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/badge-collection'),
                    child: const Text('View all'),
                  ),
                ],
              ),
            ),
          ),
          badgesAsync.when(
            data: (badges) {
              if (badges.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No badges earned yet. Keep going!'),
                  ),
                );
              }
              final featured = badges.where((b) => b.featured).toList();
              return SliverToBoxAdapter(
                child: SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: featured.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: BadgeCard(badge: featured[index]),
                      );
                    },
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (e, st) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Recent Achievements',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          achievementsAsync.when(
            data: (achievements) {
              if (achievements.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No achievements unlocked. Start completing tasks!'),
                  ),
                );
              }
              final completed = achievements.where((a) => a.completed).toList()
                ..sort((a, b) => (b.completedAt ?? DateTime.now()).compareTo(a.completedAt ?? DateTime.now()));

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: AchievementCard(achievement: completed[index]),
                    );
                  },
                  childCount: completed.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (e, st) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
          ),
        ],
      ),
    );
  }
}
