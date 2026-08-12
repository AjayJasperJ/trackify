import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/public_activity_entity.dart';
import '../../domain/entities/public_profile_entity.dart';
import '../../providers/public_profile_providers.dart';

class FriendProfileScreen extends ConsumerWidget {
  final String uid;

  const FriendProfileScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(publicProfileStreamProvider(uid));
    final activityAsync = ref.watch(publicActivityProvider(uid));

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final primaryFixed = theme.colorScheme.primaryContainer;
    final primaryContainer = theme.colorScheme.primaryContainer;
    final onPrimaryContainer = theme.colorScheme.onPrimaryContainer;
    final secondary = theme.colorScheme.secondary;
    final secondaryContainer = theme.colorScheme.secondaryContainer;

    final surface = theme.colorScheme.surface;
    final surfaceContainerLowest = theme.colorScheme.surfaceContainerLow;
    final surfaceContainerHigh = theme.colorScheme.surfaceContainerHigh;

    final onSurface = theme.colorScheme.onSurface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final outlineVariant = theme.colorScheme.outlineVariant;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Friend Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Profile Header & Hero Section
          profileAsync.when(
            data: (profile) {
              if (profile == null) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('Profile not found.')),
                  ),
                );
              }

              final level = (profile.totalCompletedTasks ~/ 10) + 1;

              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroSection(
                      context: context,
                      profile: profile,
                      level: level,
                      primary: primary,
                      primaryFixed: primaryFixed,
                      primaryContainer: primaryContainer,
                      onPrimaryContainer: onPrimaryContainer,
                      surface: surface,
                      surfaceContainerHigh: surfaceContainerHigh,
                      onSurface: onSurface,
                      onSurfaceVariant: onSurfaceVariant,
                      secondary: secondary,
                    ),
                    _buildKeyStats(
                      profile: profile,
                      surfaceContainerLowest: surfaceContainerLowest,
                      onSurface: onSurface,
                      onSurfaceVariant: onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    _buildDailyProgress(
                      profile: profile,
                      primary: primary,
                      surfaceContainerLowest: surfaceContainerLowest,
                      surfaceContainerHigh: surfaceContainerHigh,
                      onSurface: onSurface,
                      onSurfaceVariant: onSurfaceVariant,
                      outlineVariant: outlineVariant,
                    ),
                    _buildConsistencyMetrics(
                      profile: profile,
                      primary: primary,
                      primaryFixed: primaryFixed,
                      secondary: secondary,
                      secondaryContainer: secondaryContainer,
                      surfaceContainerLowest: surfaceContainerLowest,
                      surfaceContainerHigh: surfaceContainerHigh,
                      onSurface: onSurface,
                      onSurfaceVariant: onSurfaceVariant,
                    ),
                  ],
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(48.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, st) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(child: Text('Error loading profile: $e')),
              ),
            ),
          ),

          // Activity Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'PUBLIC',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Activity List
          activityAsync.when(
            data: (activities) {
              if (activities.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 24.0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'No recent completed activity.',
                          style: TextStyle(color: onSurfaceVariant),
                        ),
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final activity = activities[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _InteractiveActivityCard(
                        activity: activity,
                        primary: primary,
                        onSurface: onSurface,
                        onSurfaceVariant: onSurfaceVariant,
                        surfaceContainerLowest: surfaceContainerLowest,
                        primaryContainer: primaryContainer,
                        onPrimaryContainer: onPrimaryContainer,
                        outlineVariant: outlineVariant,
                      ),
                    );
                  }, childCount: activities.length),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, st) => SliverToBoxAdapter(
              child: Center(child: Text('Error loading activity: $e')),
            ),
          ),

          // Privacy Footer
          SliverToBoxAdapter(child: _buildPrivacyFooter(onSurface: onSurface)),
        ],
      ),
    );
  }

  Widget _buildHeroSection({
    required BuildContext context,
    required PublicProfileEntity profile,
    required int level,
    required Color primary,
    required Color primaryFixed,
    required Color primaryContainer,
    required Color onPrimaryContainer,
    required Color surface,
    required Color surfaceContainerHigh,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color secondary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        children: [
          // Avatar with Gradient Ring & Badge
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [primary, primaryFixed],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    border: Border.all(color: surface, width: 3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child:
                          profile.photoUrl != null &&
                              profile.photoUrl!.isNotEmpty
                          ? Image.network(
                              profile.photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  _buildAvatarInitials(
                                    profile.displayName,
                                    primary,
                                  ),
                            )
                          : _buildAvatarInitials(profile.displayName, primary),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: surface, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.verified,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Display Name
          Text(
            profile.displayName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
          ),
          if (profile.bio != null && profile.bio!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                profile.bio!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: onSurfaceVariant,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),

          // Level & Streak Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Level ${profile.level}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    size: 18,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${profile.currentStreak} Day Streak',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _AnimatedButton(
                  text: 'Nudge',
                  icon: Icons.notifications_active,
                  backgroundColor: primary,
                  textColor: Colors.white,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Sent a motivation nudge to ${profile.displayName}!',
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AnimatedButton(
                  text: 'Share Profile',
                  icon: Icons.share,
                  backgroundColor: surfaceContainerHigh,
                  textColor: onSurface,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Profile link copied to clipboard!'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarInitials(String displayName, Color primary) {
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildKeyStats({
    required PublicProfileEntity profile,
    required Color surfaceContainerLowest,
    required Color onSurface,
    required Color onSurfaceVariant,
  }) {
    final totalXp = profile.totalCompletedTasks * 50;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LONGEST STREAK',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${profile.longestStreak}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Days',
                        style: TextStyle(fontSize: 14, color: onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL COMPLETED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${profile.totalCompletedTasks}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tasks ($totalXp XP)',
                        style: TextStyle(fontSize: 12, color: onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyProgress({
    required PublicProfileEntity profile,
    required Color primary,
    required Color surfaceContainerLowest,
    required Color surfaceContainerHigh,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color outlineVariant,
  }) {
    final todayPercent = (profile.todayCompletion * 100).toInt();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Daily Goal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.public, size: 16, color: onSurfaceVariant),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${profile.displayName} completed $todayPercent% of today\'s focus.',
                    style: TextStyle(fontSize: 13, color: onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$todayPercent%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                          Text(
                            'TODAY',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Container(width: 1, height: 24, color: outlineVariant),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${(profile.weeklyCompletion * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: onSurface,
                            ),
                          ),
                          Text(
                            'WEEKLY',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 84,
              height: 84,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 8,
                    color: surfaceContainerHigh,
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0.0,
                      end: profile.todayCompletion.clamp(0.0, 1.0),
                    ),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOut,
                    builder: (context, value, _) {
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 8,
                        color: primary,
                        backgroundColor: Colors.transparent,
                        strokeCap: StrokeCap.round,
                      );
                    },
                  ),
                  Center(
                    child: Text(
                      '$todayPercent%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsistencyMetrics({
    required PublicProfileEntity profile,
    required Color primary,
    required Color primaryFixed,
    required Color secondary,
    required Color secondaryContainer,
    required Color surfaceContainerLowest,
    required Color surfaceContainerHigh,
    required Color onSurface,
    required Color onSurfaceVariant,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Consistency',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
              Icon(Icons.trending_up, size: 20, color: onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 12),
          _buildMetricRow(
            icon: Icons.calendar_view_week,
            iconBg: primaryFixed,
            iconColor: primary,
            title: 'Weekly Completion',
            percentText: '${(profile.weeklyCompletion * 100).toInt()}%',
            percentColor: primary,
            progressValue: profile.weeklyCompletion.clamp(0.0, 1.0),
            progressColor: primary,
            surfaceContainerLowest: surfaceContainerLowest,
            surfaceContainerHigh: surfaceContainerHigh,
            onSurface: onSurface,
          ),
          const SizedBox(height: 8),
          _buildMetricRow(
            icon: Icons.calendar_month,
            iconBg: secondaryContainer,
            iconColor: secondary,
            title: 'Monthly Completion',
            percentText: '${(profile.monthlyCompletion * 100).toInt()}%',
            percentColor: onSurfaceVariant,
            progressValue: profile.monthlyCompletion.clamp(0.0, 1.0),
            progressColor: secondary,
            surfaceContainerLowest: surfaceContainerLowest,
            surfaceContainerHigh: surfaceContainerHigh,
            onSurface: onSurface,
          ),
          const SizedBox(height: 8),
          _buildMetricRow(
            icon: Icons.ads_click,
            iconBg: primary.withValues(alpha: 0.1),
            iconColor: primary,
            title: 'Overall Goal Completion',
            percentText: '${(profile.overallCompletion * 100).toInt()}%',
            percentColor: onSurfaceVariant,
            progressValue: profile.overallCompletion.clamp(0.0, 1.0),
            progressColor: primary.withValues(alpha: 0.7),
            surfaceContainerLowest: surfaceContainerLowest,
            surfaceContainerHigh: surfaceContainerHigh,
            onSurface: onSurface,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String percentText,
    required Color percentColor,
    required double progressValue,
    required Color progressColor,
    required Color surfaceContainerLowest,
    required Color surfaceContainerHigh,
    required Color onSurface,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: onSurface,
                      ),
                    ),
                    Text(
                      percentText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: percentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 6,
                    backgroundColor: surfaceContainerHigh,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyFooter({required Color onSurface}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Opacity(
        opacity: 0.5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_open, size: 14),
            const SizedBox(width: 6),
            Text(
              'PROFILE SET TO PUBLIC WORKSPACE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
                color: onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Interactive Components
// -----------------------------------------------------------------------------

class _AnimatedButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const _AnimatedButton({
    required this.text,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: widget.backgroundColor.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: widget.textColor, size: 18),
              const SizedBox(width: 8),
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InteractiveActivityCard extends StatefulWidget {
  final PublicCompletedTask activity;
  final Color primary;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color surfaceContainerLowest;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color outlineVariant;

  const _InteractiveActivityCard({
    required this.activity,
    required this.primary,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.surfaceContainerLowest,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.outlineVariant,
  });

  @override
  State<_InteractiveActivityCard> createState() =>
      _InteractiveActivityCardState();
}

class _InteractiveActivityCardState extends State<_InteractiveActivityCard> {
  bool _isPressed = false;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;
    final formattedTime = DateFormat(
      'MMM d, yyyy • h:mm a',
    ).format(activity.completedAt);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
          _isExpanded = !_isExpanded;
        });
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isExpanded
                  ? widget.primary.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.taskTitle,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: widget.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (activity.subtasks.isNotEmpty)
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: widget.onSurfaceVariant,
                    ),
                ],
              ),

              // Subtasks summary
              if (activity.totalSubtasks > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value:
                              activity.completedSubtasks /
                              activity.totalSubtasks,
                          minHeight: 5,
                          backgroundColor: widget.outlineVariant.withValues(
                            alpha: 0.3,
                          ),
                          color: widget.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${activity.completedSubtasks}/${activity.totalSubtasks} subtasks',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: widget.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],

              // Expanded Subtask breakdown
              if (_isExpanded && activity.subtasks.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                ...activity.subtasks.map((subtask) {
                  final isCompleted = subtask['isCompleted'] == true;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Row(
                      children: [
                        Icon(
                          isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 16,
                          color: isCompleted
                              ? Colors.green
                              : widget.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            subtask['title'] ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isCompleted
                                  ? widget.onSurfaceVariant
                                  : widget.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              // Mood Tag
              if (activity.mood != null && activity.mood!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Mood: ${activity.mood}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: widget.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
