import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../widgets/dashboard_app_bar.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../../../social/domain/entities/friend_entity.dart';
import '../../../social/providers/friend_state_providers.dart';
import '../../../social/providers/public_profile_providers.dart';

/// A single leaderboard row — a friend plus their public stats.
class _LeaderboardEntry {
  final String uid;
  final String displayName;
  final int level;
  final int totalCompletedTasks;
  final int currentStreak;
  final int xp;

  const _LeaderboardEntry({
    required this.uid,
    required this.displayName,
    required this.level,
    required this.totalCompletedTasks,
    required this.currentStreak,
    required this.xp,
  });

  /// Sort key: XP first, then completed tasks, then streak. Higher first.
  int get _sortKey => xp;
}

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    final friendsAsync = ref.watch(userFriendsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      body: Stack(
        children: [
          friendsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error loading friends: $e')),
            data: (friends) => _buildFriendsBoard(context, ref, friends),
          ),
          DashboardAppBar(
            topPadding: MediaQuery.of(context).padding.top,
            title: 'Leaderboard',
            isInnerScreen: true,
            showAvatar: false,
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsBoard(
    BuildContext context,
    WidgetRef ref,
    List<FriendEntity> friends,
  ) {
    if (friends.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_outlined,
                  size: 64, color: Color(0xFF414751)),
              const SizedBox(height: 16),
              const Text(
                'No friends yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add friends to see who is crushing it.',
                style: TextStyle(fontSize: 13, color: Color(0xFF414751)),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go('/friends'),
                icon: const Icon(Icons.person_add_alt),
                label: const Text('Go to Friends'),
              ),
            ],
          ),
        ),
      );
    }

    return _FriendsLeaderboard(friendUids: friends.map((f) => f.friendUid).toList());
  }
}

/// Loads each friend's public profile (and progression, when available) and
/// renders the sorted leaderboard.
class _FriendsLeaderboard extends ConsumerWidget {
  final List<String> friendUids;

  const _FriendsLeaderboard({required this.friendUids});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = friendUids
        .map((uid) => ref.watch(publicProfileStreamProvider(uid)))
        .toList();

    // Loading: any profile still resolving.
    if (profiles.any((p) => p.isLoading)) {
      return const Center(child: CircularProgressIndicator());
    }

    final entries = <_LeaderboardEntry>[];
    for (var i = 0; i < friendUids.length; i++) {
      final profile = profiles[i].valueOrNull;
      if (profile == null) continue; // No public profile yet — skip.
      entries.add(_LeaderboardEntry(
        uid: friendUids[i],
        displayName: profile.displayName,
        level: profile.level,
        totalCompletedTasks: profile.totalCompletedTasks,
        currentStreak: profile.currentStreak,
        xp: profile.totalCompletedTasks * 10,
      ));
    }

    entries.sort((a, b) => b._sortKey.compareTo(a._sortKey));

    if (entries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No leaderboard data yet.\nComplete tasks and check back soon!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF414751)),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    return ListView.builder(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: MediaQuery.of(context).padding.top + 76,
        bottom: 24,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        return _buildTile(theme, entries[index], index + 1);
      },
    );
  }

  Widget _buildTile(ThemeData theme, _LeaderboardEntry entry, int rank) {
    final isTop3 = rank <= 3;
    Color? rankColor;
    if (rank == 1) rankColor = Colors.amber.shade700;
    if (rank == 2) rankColor = Colors.grey.shade500;
    if (rank == 3) rankColor = Colors.brown.shade400;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#$rank',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isTop3 ? rankColor : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(Icons.person,
                color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Level ${entry.level}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.xp} XP',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.local_fire_department,
                      size: 14, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    '${entry.currentStreak}d',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
