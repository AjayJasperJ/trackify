import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/friend_state_providers.dart';
import '../../providers/social_providers.dart';
import '../../providers/search_state_providers.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../../domain/entities/friend_with_profile.dart';
import 'friends_request_tab.dart';
import 'friends_discover_tab.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  int _selectedTabIndex = 0;
  String _activeFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final Color onSurface = const Color(0xFF1B1C1C);
  final Color onSurfaceVariant = const Color(0xFF414751);
  final Color primary = const Color(0xFF005396);
  final Color surfaceContainerLow = const Color(0xFFF6F3F2);
  final Color surfaceContainerHighest = const Color(0xFFE4E2E1);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsWithProfilesStreamProvider);
    final pendingRequestsAsync = ref.watch(pendingRequestsProvider);

    final friendsCount = friendsAsync.valueOrNull?.length ?? 0;
    final requestsCount = pendingRequestsAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Social',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: onSurface,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_outlined, color: primary),
            tooltip: 'Find Friends',
            onPressed: () {
              setState(() {
                _selectedTabIndex = 2; // Switch to Discover tab
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {});
                    if (_selectedTabIndex == 2) {
                      ref.read(searchQueryProvider.notifier).state = val;
                    }
                  },
                  style: TextStyle(fontSize: 14, color: onSurface),
                  decoration: InputDecoration(
                    hintText: _selectedTabIndex == 2
                        ? 'Search users by name...'
                        : 'Search friends...',
                    hintStyle: TextStyle(
                      color: onSurfaceVariant.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(Icons.search, color: onSurfaceVariant, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                              ref.read(searchQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            // Tab Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildTabButton('Friends', 0, badgeCount: friendsCount),
                    _buildTabButton('Requests', 1, badgeCount: requestsCount),
                    _buildTabButton('Discover', 2),
                  ],
                ),
              ),
            ),

            // Main Body Content
            Expanded(
              child: IndexedStack(
                index: _selectedTabIndex,
                children: [
                  // Tab 0: Friends List Tab
                  _buildFriendsTab(friendsAsync),

                  // Tab 1: Requests Tab
                  const RequestsTabView(),

                  // Tab 2: Discover Tab
                  const DiscoverTabView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index, {int badgeCount = 0}) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? primary : onSurfaceVariant,
                ),
              ),
              if (badgeCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? primary : surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : onSurfaceVariant,
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsTab(AsyncValue<List<FriendWithProfile>> friendsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Streaks Section
        friendsAsync.when(
          data: (friends) => _TopStreaksSection(friends: friends),
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox.shrink(),
        ),

        // Filter Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Row(
            children: [
              _buildFilterChip('All'),
              const SizedBox(width: 8),
              _buildFilterChip('Active'),
              const SizedBox(width: 8),
              _buildFilterChip('Favorites'),
            ],
          ),
        ),

        // Friends List
        Expanded(
          child: friendsAsync.when(
            data: (friends) {
              final query = _searchController.text.trim().toLowerCase();

              var filtered = friends;
              if (_activeFilter == 'Favorites') {
                filtered = filtered.where((f) => f.friend.favorite).toList();
              }
              if (query.isNotEmpty) {
                filtered = filtered
                    .where((f) => f.displayName.toLowerCase().contains(query))
                    .toList();
              }

              if (filtered.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: onSurfaceVariant.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        Text(
                          _activeFilter == 'Favorites'
                              ? 'No favorite friends yet'
                              : 'No friends found',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: onSurface),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap Discover to find accountability partners and build habits together.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: onSurfaceVariant),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => setState(() => _selectedTabIndex = 2),
                          icon: const Icon(Icons.search, size: 18),
                          label: const Text('Discover Friends'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final friend = filtered[index];
                  return _InteractiveFriendCard(
                    key: ValueKey(friend.uid),
                    friend: friend,
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error loading friends: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _activeFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _activeFilter = label);
      },
      selectedColor: primary.withValues(alpha: 0.1),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected ? primary : onSurfaceVariant,
      ),
      side: BorderSide(
        color: isSelected ? primary : const Color(0xFFC1C7D3).withValues(alpha: 0.5),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _InteractiveFriendCard extends ConsumerWidget {
  final FriendWithProfile friend;

  const _InteractiveFriendCard({
    super.key,
    required this.friend,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayName = friend.displayName;
    final photoUrl = friend.photoUrl;
    final level = friend.level;
    final streak = friend.streak;
    final bio = friend.bio;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/friend-profile/${friend.uid}'),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Avatar with online status
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFFD3E3FF),
                      backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : null,
                      child: photoUrl == null || photoUrl.isEmpty
                          ? Text(
                              displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF001C39),
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // User Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B1C1C),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD3E3FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Lvl $level',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF005396),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (streak > 0) ...[
                            const Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
                            const SizedBox(width: 2),
                            Text(
                              '${streak}d streak',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              bio,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF414751),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Quick Actions Menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF414751), size: 20),
                  onSelected: (value) async {
                    if (value == 'profile') {
                      context.push('/friend-profile/${friend.uid}');
                    } else if (value == 'remove') {
                      final currentUser = ref.read(currentUserProvider);
                      if (currentUser != null) {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Remove Friend'),
                            content: Text('Are you sure you want to remove $displayName from your friends?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Remove'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref.read(friendRepositoryProvider).removeFriend(currentUser.uid, friend.uid);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$displayName removed from friends')),
                            );
                          }
                        }
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 18),
                          SizedBox(width: 8),
                          Text('View Profile'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.person_remove, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Remove Friend', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopStreaksSection extends StatelessWidget {
  final List<FriendWithProfile> friends;

  const _TopStreaksSection({required this.friends});

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) return const SizedBox.shrink();

    final entries = friends
        .where((f) => f.hasProfile && f.streak > 0)
        .map((f) => f)
        .toList()
      ..sort((a, b) => b.streak.compareTo(a.streak));

    final topStreaks = entries.take(3).toList();
    if (topStreaks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Text(
            'Streak Leaders',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B1C1C),
            ),
          ),
        ),
        SizedBox(
          height: 124,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: topStreaks.length,
            itemBuilder: (context, index) {
              final friend = topStreaks[index];
              final streak = friend.streak;
              final displayName = friend.displayName;
              final photoUrl = friend.photoUrl;

              Color rankColor = Colors.orange;
              if (index == 0) {
                rankColor = Colors.amber.shade700;
              } else if (index == 1) {
                rankColor = Colors.grey.shade500;
              } else if (index == 2) {
                rankColor = Colors.brown.shade400;
              }

              return GestureDetector(
                onTap: () => context.push('/friend-profile/${friend.uid}'),
                child: Container(
                  width: 104,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                    border: Border.all(
                      color: index == 0 ? Colors.amber.withValues(alpha: 0.3) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFFD3E3FF),
                            backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                                ? NetworkImage(photoUrl)
                                : null,
                            child: photoUrl == null || photoUrl.isEmpty
                                ? Text(
                                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF001C39),
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(Icons.local_fire_department, size: 12, color: rankColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${streak}d streak',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: rankColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
