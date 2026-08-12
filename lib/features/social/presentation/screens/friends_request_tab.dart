import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../../domain/entities/friend_request_entity.dart';
import '../../providers/friend_state_providers.dart';
import '../../providers/public_profile_providers.dart';
import '../../providers/social_providers.dart';

class RequestsTabView extends ConsumerWidget {
  const RequestsTabView({super.key});

  final Color onSurface = const Color(0xFF1B1C1C);
  final Color primaryFixed = const Color(0xFFD3E3FF);
  final Color onPrimaryFixed = const Color(0xFF001C39);
  final Color onSurfaceVariant = const Color(0xFF414751);
  final Color primary = const Color(0xFF005396);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingRequestsProvider);
    final sentAsync = ref.watch(sentRequestsProvider);
    final currentUser = ref.watch(currentUserProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- INCOMING REQUESTS SECTION ---
          pendingAsync.when(
            data: (pendingRequests) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Incoming Requests',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                      ),
                      if (pendingRequests.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryFixed,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${pendingRequests.length} New',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: onPrimaryFixed,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (pendingRequests.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F3F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.mark_email_read_outlined,
                            size: 36,
                            color: onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No pending friend requests',
                            style: TextStyle(
                              fontSize: 13,
                              color: onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pendingRequests.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final request = pendingRequests[index];
                        return _IncomingRequestItem(
                          request: request,
                          currentUid: currentUser?.uid ?? '',
                        );
                      },
                    ),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Text('Error loading incoming requests: $e'),
          ),

          const SizedBox(height: 32),

          // --- OUTGOING (SENT) REQUESTS SECTION ---
          sentAsync.when(
            data: (sentRequests) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sent Requests',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (sentRequests.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F3F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'No sent requests pending response',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sentRequests.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final request = sentRequests[index];
                        return _SentRequestItem(
                          request: request,
                          currentUid: currentUser?.uid ?? '',
                        );
                      },
                    ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Text('Error loading sent requests: $e'),
          ),

          const SizedBox(height: 32),

          // Empty State / Suggestion Banner
          Center(
            child: Opacity(
              opacity: 0.7,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE4E2E1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_search,
                      size: 28,
                      color: Color(0xFF414751),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Looking for more goal partners?',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF414751),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _IncomingRequestItem extends ConsumerStatefulWidget {
  final FriendRequestEntity request;
  final String currentUid;

  const _IncomingRequestItem({
    required this.request,
    required this.currentUid,
  });

  @override
  ConsumerState<_IncomingRequestItem> createState() => _IncomingRequestItemState();
}

class _IncomingRequestItemState extends ConsumerState<_IncomingRequestItem> {
  bool _isProcessing = false;

  final Color surfaceContainerLow = const Color(0xFFF6F3F2);
  final Color primary = const Color(0xFF005396);
  final Color onSurfaceVariant = const Color(0xFF414751);

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return 'Requested ${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return 'Requested ${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Requested yesterday';
    } else {
      return 'Requested ${diff.inDays} days ago';
    }
  }

  Future<void> _respond(bool accept) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final repo = ref.read(friendRequestRepositoryProvider);
      await repo.respondToRequest(
        widget.request.requestId,
        widget.currentUid,
        widget.request.senderUid,
        accept ? FriendRequestStatus.accepted : FriendRequestStatus.rejected,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              accept ? 'Friend request accepted!' : 'Request declined',
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
            ),
            backgroundColor: accept ? primary : const Color(0xFF515353),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            margin: const EdgeInsets.only(bottom: 80, left: 24, right: 24),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to respond: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(publicProfileStreamProvider(widget.request.senderUid));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2),
        ],
      ),
      child: profileAsync.when(
        data: (profile) {
          final displayName = profile?.displayName ?? 'User';
          final photoUrl = profile?.photoUrl ?? '';

          return Row(
            children: [
              GestureDetector(
                onTap: () => context.push('/friend-profile/${widget.request.senderUid}'),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFE4E2E1),
                  backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  child: photoUrl.isEmpty
                      ? Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                          style: TextStyle(fontWeight: FontWeight.bold, color: primary),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => context.push('/friend-profile/${widget.request.senderUid}'),
                      child: Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B1C1C),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatTime(widget.request.sentAt),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isProcessing)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF515353), size: 20),
                      tooltip: 'Decline',
                      onPressed: () => _respond(false),
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      onPressed: () => _respond(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Accept', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
            ],
          );
        },
        loading: () => const SizedBox(
          height: 48,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (e, _) => Text('Error loading profile: $e'),
      ),
    );
  }
}

class _SentRequestItem extends ConsumerWidget {
  final FriendRequestEntity request;
  final String currentUid;

  const _SentRequestItem({
    required this.request,
    required this.currentUid,
  });

  final Color surfaceContainerLow = const Color(0xFFF6F3F2);
  final Color primary = const Color(0xFF005396);
  final Color onSurfaceVariant = const Color(0xFF414751);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(publicProfileStreamProvider(request.receiverUid));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: profileAsync.when(
        data: (profile) {
          final displayName = profile?.displayName ?? 'User';
          final photoUrl = profile?.photoUrl ?? '';

          return Row(
            children: [
              GestureDetector(
                onTap: () => context.push('/friend-profile/${request.receiverUid}'),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFE4E2E1),
                  backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  child: photoUrl.isEmpty
                      ? Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                          style: TextStyle(fontWeight: FontWeight.bold, color: primary),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B1C1C),
                      ),
                    ),
                    Text(
                      'Pending response...',
                      style: TextStyle(fontSize: 11, color: onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4E2E1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF414751)),
                ),
              ),
            ],
          );
        },
        loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
        error: (e, _) => Text('Error: $e'),
      ),
    );
  }
}
