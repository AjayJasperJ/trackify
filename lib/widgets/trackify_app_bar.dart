import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trackify/theme/app_colors.dart';
import 'package:trackify/widgets/txt_widget.dart';
import '../features/achievements/presentation/screens/achievements_dashboard_screen.dart';
import '../features/achievements/presentation/screens/profile_achievements_screen.dart';
import '../features/authentication/providers/auth_provider.dart';

class TrackifyAppBar extends ConsumerWidget {
  final String title;
  final bool isInnerScreen;
  final bool showProfile;
  final String? photoUrl;
  final String? userId;

  const TrackifyAppBar({
    super.key,
    this.title = 'Dashboard',
    this.isInnerScreen = false,
    this.showProfile = false,
    this.photoUrl,
    this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.of(context).padding.top;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 64.0 + topPadding,
          padding: EdgeInsets.only(top: topPadding, left: 16, right: 16),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.8),
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
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.onSurface,
                      ),
                      onPressed: () => context.pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  else
                    Icon(
                      Icons.track_changes_rounded,
                      size: 25.r,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  SizedBox(width: 16.w),
                  Txt(
                    title,
                    size: 20.sp,
                    weight: Font.semibold,
                    color: AppColors.onSurface,
                    height: 1.4,
                  ),
                ],
              ),
              if (showProfile)
                _AvatarMenu(photoUrl: photoUrl, userId: userId)
              else
                SizedBox(width: 32.w),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private widgets ──────────────────────────────────────────────────────────

class _AvatarMenu extends ConsumerWidget {
  final String? photoUrl;
  final String? userId;

  const _AvatarMenu({this.photoUrl, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          case 'profile':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ProfileAchievementsScreen(userId: userId ?? 'Unknown'),
              ),
            );
          case 'achievements':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AchievementsDashboardScreen(),
              ),
            );
          case 'logout':
            await ref.read(authRepositoryProvider).logout();
        }
      },
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'profile',
          child: _MenuItem(icon: Icons.person_outline, label: 'Profile'),
        ),
        PopupMenuItem(
          value: 'achievements',
          child: _MenuItem(
            icon: Icons.emoji_events_outlined,
            label: 'Achievements',
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: _MenuItem(
            icon: Icons.logout,
            label: 'Logout',
            color: Colors.red,
          ),
        ),
      ],
      child: Container(
        width: 35.r,
        height: 35.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.outlineVariant),
          image: photoUrl != null
              ? DecorationImage(
                  image: NetworkImage(photoUrl!),
                  fit: BoxFit.cover,
                )
              : null,
          color: photoUrl == null ? AppColors.outlineVariant : null,
        ),
        child: photoUrl == null
            ? Icon(Icons.person, size: 18.r, color: Colors.white)
            : null,
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MenuItem({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.r, color: color),
        SizedBox(width: 12.w),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}
