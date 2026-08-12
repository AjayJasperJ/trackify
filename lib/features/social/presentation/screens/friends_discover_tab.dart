import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../../providers/friend_state_providers.dart';
import '../../providers/search_state_providers.dart';
import '../../providers/social_providers.dart';

class DiscoverTabView extends ConsumerStatefulWidget {
  const DiscoverTabView({super.key});

  @override
  ConsumerState<DiscoverTabView> createState() => _DiscoverTabViewState();
}

class _DiscoverTabViewState extends ConsumerState<DiscoverTabView> {
  final Color onSurface = const Color(0xFF1B1C1C);
  final Color onSurfaceVariant = const Color(0xFF414751);
  final Color primary = const Color(0xFF005396);
  final Color outlineVariant = const Color(0xFFC1C7D3);
  final Color surfaceContainerLow = const Color(0xFFF6F3F2);

  final Set<String> _sentRequestUids = {};

  Future<void> _sendFriendRequest(String targetUid) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null || _sentRequestUids.contains(targetUid)) return;

    setState(() {
      _sentRequestUids.add(targetUid);
    });

    try {
      final repo = ref.read(friendRequestRepositoryProvider);
      await repo.sendRequest(currentUser.uid, targetUid);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Friend request sent!',
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
            ),
            backgroundColor: primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            margin: const EdgeInsets.only(bottom: 80, left: 24, right: 24),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _sentRequestUids.remove(targetUid);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send request: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final searchResultsAsync = ref.watch(searchUsersProvider);
    final currentUser = ref.watch(currentUserProvider);
    final sentRequestsAsync = ref.watch(sentRequestsProvider);
    final friendsAsync = ref.watch(userFriendsProvider);

    final sentUids = sentRequestsAsync.maybeWhen(
      data: (requests) => requests.map((r) => r.receiverUid).toSet(),
      orElse: () => <String>{},
    );

    final friendUids = friendsAsync.maybeWhen(
      data: (friends) => friends.map((f) => f.friendUid).toSet(),
      orElse: () => <String>{},
    );

    return Stack(
      children: [
        // Decorative background blur elements
        Positioned(
          bottom: 0,
          left: -40,
          child: Opacity(
            opacity: 0.3,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: const SizedBox(),
              ),
            ),
          ),
        ),

        // Main Content
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Query Active State
              if (searchQuery.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Search Results',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: onSurface,
                      ),
                    ),
                    Text(
                      'for "$searchQuery"',
                      style: TextStyle(
                        fontSize: 13,
                        color: onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                searchResultsAsync.when(
                  data: (users) {
                    final filteredUsers = users.where((u) => u['uid'] != currentUser?.uid).toList();

                    if (filteredUsers.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(Icons.search_off, size: 48, color: onSurfaceVariant.withValues(alpha: 0.5)),
                              const SizedBox(height: 12),
                              Text(
                                'No users found matching "$searchQuery"',
                                style: TextStyle(color: onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredUsers.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final userMap = filteredUsers[index];
                        final targetUid = userMap['uid'] as String;
                        final name = userMap['displayName'] ?? 'User';
                        final photoUrl = userMap['photoUrl'] ?? '';

                        final isFriend = friendUids.contains(targetUid);
                        final isSent = sentUids.contains(targetUid) || _sentRequestUids.contains(targetUid);

                        return _UserDiscoverTile(
                          uid: targetUid,
                          name: name,
                          photoUrl: photoUrl,
                          isFriend: isFriend,
                          isSent: isSent,
                          onConnect: () => _sendFriendRequest(targetUid),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Text('Error loading results: $e'),
                ),
                const SizedBox(height: 24),
              ] else ...[
                // Suggested Friends Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Suggested Friends',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: onSurface,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        ref.invalidate(searchUsersProvider);
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          Text(
                            'Refresh',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.sync, size: 16, color: primary),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Default Discover / Suggestions list
                _buildDefaultSuggestions(currentUser?.uid, friendUids, sentUids),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultSuggestions(String? currentUid, Set<String> friendUids, Set<String> sentUids) {
    final searchResultsAsync = ref.watch(searchUsersProvider);

    return searchResultsAsync.when(
      data: (users) {
        final filteredUsers = users.where((u) => u['uid'] != currentUid).toList();

        if (filteredUsers.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredUsers.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final userMap = filteredUsers[index];
            final targetUid = userMap['uid'] as String;
            final name = userMap['displayName'] ?? 'User';
            final photoUrl = userMap['photoUrl'] ?? '';

            final isFriend = friendUids.contains(targetUid);
            final isSent = sentUids.contains(targetUid) || _sentRequestUids.contains(targetUid);

            return _UserDiscoverTile(
              uid: targetUid,
              name: name,
              photoUrl: photoUrl,
              subtitle: 'Suggested Accountability Partner',
              isFriend: isFriend,
              isSent: isSent,
              onConnect: () => _sendFriendRequest(targetUid),
            );
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, _) => _buildEmptyState(),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Icon(
                    Icons.person_search,
                    size: 56,
                    color: primary.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Find your accountability partners',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 240,
              child: Text(
                'Type a name in the search bar above to discover and connect with friends.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserDiscoverTile extends StatelessWidget {
  final String uid;
  final String name;
  final String photoUrl;
  final String? subtitle;
  final bool isFriend;
  final bool isSent;
  final VoidCallback onConnect;

  const _UserDiscoverTile({
    required this.uid,
    required this.name,
    required this.photoUrl,
    this.subtitle,
    required this.isFriend,
    required this.isSent,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF005396);
    const surfaceContainerLow = Color(0xFFF6F3F2);
    const onSurfaceVariant = Color(0xFF414751);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.push('/friend-profile/$uid'),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFE4E2E1),
              backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              child: photoUrl.isEmpty
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: primary),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/friend-profile/$uid'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B1C1C),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle ?? 'Goal Tracker',
                    style: const TextStyle(
                      fontSize: 12,
                      color: onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isFriend)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE4E2E1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check, size: 14, color: Color(0xFF414751)),
                  SizedBox(width: 4),
                  Text('Friends', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF414751))),
                ],
              ),
            )
          else if (isSent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Sent',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primary),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: onConnect,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.person_add, size: 16),
              label: const Text('Connect', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}
