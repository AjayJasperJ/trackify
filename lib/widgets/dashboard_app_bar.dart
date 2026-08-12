import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/achievements/presentation/screens/profile_achievements_screen.dart';
import '../features/achievements/presentation/screens/achievements_dashboard_screen.dart';
import '../features/authentication/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class DashboardAppBar extends ConsumerWidget {
  final double topPadding;
  final String? photoUrl;
  final String? userId;
  final bool showAvatar;
  final bool isInnerScreen;
  final String title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  const DashboardAppBar({
    super.key,
    required this.topPadding,
    this.photoUrl,
    this.userId,
    this.showAvatar = true,
    this.isInnerScreen = false,
    this.title = 'Dashboard',
    this.onBackPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surface = const Color(0xFFFCF9F8);
    final onSurface = const Color(0xFF1B1C1C);
    final outlineVariant = const Color(0xFFC1C7D3);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 64.0 + topPadding,
            padding: EdgeInsets.only(top: topPadding, left: 16, right: 16),
            decoration: BoxDecoration(
              color: surface.withValues(alpha: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (isInnerScreen)
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: onSurface),
                        onPressed: onBackPressed ?? () => context.pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    else
                      Icon(
                        Icons.track_changes_rounded,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    const SizedBox(width: 16),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        color: onSurface,
                      ),
                    ),
                  ],
                ),
                if (showAvatar)
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'profile') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileAchievementsScreen(
                              userId: userId ?? 'Unknown',
                            ),
                          ),
                        );
                      } else if (value == 'achievements') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AchievementsDashboardScreen(),
                          ),
                        );
                      } else if (value == 'logout') {
                        await ref.read(authRepositoryProvider).logout();
                      }
                    },
                    offset: const Offset(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: outlineVariant),
                        image: DecorationImage(
                          image: NetworkImage(
                            photoUrl ??
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuDJGmMJ_c3_YFJTIm7e7knOtNh0TURbc1AiErDpELkGpiSdRqrWsKM3hvnoQuGhem5Mfx-_PdbSeh7GWrhtBVhhvEAia3HO1tQYaV9Gp3cNdboWtej-TsfUY6pxmpoTtYNPgk_BKWQIhZLgNjSB4T-Lb4qP11WGMX6AmKULaOyYhkIq_w029iFH8qD5ippzDm-HqHDU8lTjqDz85MmS1n_VRJLOgXKKgkmNize3qL8yQdgTkNdIoLlQ',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'profile',
                        child: Row(
                          children: [
                            Icon(Icons.person_outline, size: 20),
                            SizedBox(width: 12),
                            Text('Profile'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'achievements',
                        child: Row(
                          children: [
                            Icon(Icons.emoji_events_outlined, size: 20),
                            SizedBox(width: 12),
                            Text('Achievements'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, size: 20, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Logout', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ...?actions,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
