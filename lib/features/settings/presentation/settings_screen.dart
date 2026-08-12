import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trackify/features/authentication/providers/auth_provider.dart';
import 'package:trackify/features/progression/providers/progression_providers.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final Color background = const Color(0xFFFCF9F8);
  final Color surface = const Color(0xFFFCF9F8);
  final Color surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color surfaceContainerLow = const Color(0xFFF6F3F2);
  final Color surfaceContainerHighest = const Color(0xFFE4E2E1);
  final Color primaryContainer = const Color(0xFF0F6CBD);
  final Color onPrimaryContainer = const Color(0xFFE3ECFF);
  final Color primary = const Color(0xFF005396);
  final Color onSurface = const Color(0xFF1B1C1C);
  final Color onSurfaceVariant = const Color(0xFF414751);
  final Color outline = const Color(0xFF717783);
  final Color outlineVariant = const Color(0xFFC1C7D3);
  final Color secondary = const Color(0xFF5E5E5E);
  final Color secondaryContainer = const Color(0xFFE1DFDF);

  double _hapticValue = 75.0;
  bool _taskReminders = true;
  bool _offlineMode = false;
  bool _highContrast = false;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          // Main Scrollable Content
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: topPadding + 64 + 16,
              bottom: bottomPadding + 64 + 96,
              left: 16.0,
              right: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchAndSubtitle(),
                const SizedBox(height: 24),
                _buildAppearanceSection(),
                const SizedBox(height: 24),
                _buildNotificationsSection(),
                const SizedBox(height: 24),
                _buildHapticsSection(),
                const SizedBox(height: 24),
                _buildProductivitySection(),
                const SizedBox(height: 24),
                _buildFriendsSection(),
                const SizedBox(height: 24),
                _buildAnalyticsSection(),
                const SizedBox(height: 24),
                _buildAccountSection(),
                const SizedBox(height: 24),
                _buildDataSection(),
                const SizedBox(height: 24),
                _buildAccessibilitySection(),
                const SizedBox(height: 24),
                _buildAboutSection(),
              ],
            ),
          ),
          // Fixed Header
          _buildHeader(topPadding),
        ],
      ),
    );
  }

  Widget _buildHeader(double topPadding) {
    final user = ref.watch(currentUserProvider);
    final photoUrl = user?.photoURL;

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
                  color: Colors.black.withValues(alpha: 0.04),
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
                    Icon(
                      Icons.settings_outlined,
                      size: 28,
                      color: primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                        color: onSurface,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryContainer,
                    border: Border.all(color: outlineVariant),
                  ),
                  child: photoUrl != null
                      ? ClipOval(
                          child: Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Center(
                              child: Text(
                                (user?.displayName?.isNotEmpty == true
                                        ? user!.displayName![0]
                                        : 'U')
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            (user?.displayName?.isNotEmpty == true
                                    ? user!.displayName![0]
                                    : 'U')
                                .toUpperCase(),
                            style: TextStyle(
                              color: onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personalize your productivity experience',
          style: TextStyle(fontSize: 14, color: onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border(bottom: BorderSide(color: outlineVariant, width: 2)),
          ),
          child: TextField(
            style: TextStyle(fontSize: 14, color: onSurface),
            decoration: InputDecoration(
              hintText: 'Search settings...',
              hintStyle: TextStyle(color: onSurfaceVariant.withValues(alpha: 0.5)),
              prefixIcon: Icon(Icons.search, color: onSurfaceVariant),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return _SectionCard(
      title: 'Appearance',
      icon: Icons.palette,
      primary: primary,
      surfaceContainerLowest: surfaceContainerLowest,
      outlineVariant: outlineVariant,
      children: [
        _buildListTile(
          title: 'Theme',
          subtitle: 'System Default',
          trailing: Icon(Icons.chevron_right, color: outline),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: outlineVariant.withValues(alpha: 0.1),
        ),
        _buildListTile(
          title: 'Accent Color',
          subtitle: 'Corporate Blue',
          trailing: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: surfaceContainerLowest,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.1),
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return _SectionCard(
      title: 'Notifications',
      icon: Icons.notifications_active,
      primary: primary,
      surfaceContainerLowest: surfaceContainerLowest,
      outlineVariant: outlineVariant,
      children: [
        _buildListTile(
          title: 'Task Reminders',
          subtitle: 'Alerts for upcoming deadlines',
          trailing: _CustomSwitch(
            value: _taskReminders,
            onChanged: (val) => setState(() => _taskReminders = val),
            activeColor: primary,
            inactiveColor: surfaceContainerHighest,
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: outlineVariant.withValues(alpha: 0.1),
        ),
        _buildListTile(
          title: 'Quiet Hours',
          subtitle: '22:00 - 07:00',
          trailing: Icon(Icons.schedule, color: outline),
        ),
      ],
    );
  }

  Widget _buildHapticsSection() {
    return _SectionCard(
      title: 'Haptics & Feedback',
      icon: Icons.vibration,
      primary: primary,
      surfaceContainerLowest: surfaceContainerLowest,
      outlineVariant: outlineVariant,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vibration Intensity',
                    style: TextStyle(fontSize: 16, color: onSurface),
                  ),
                  Text(
                    '${_hapticValue.toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  activeTrackColor: primary,
                  inactiveTrackColor: surfaceContainerHighest,
                  thumbColor: primary,
                  overlayColor: primary.withValues(alpha: 0.1),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8.0,
                  ),
                ),
                child: Slider(
                  value: _hapticValue,
                  min: 0,
                  max: 100,
                  onChanged: (val) => setState(() => _hapticValue = val),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductivitySection() {
    return _SectionCard(
      title: 'Productivity',
      icon: Icons.rocket_launch,
      primary: primary,
      surfaceContainerLowest: surfaceContainerLowest,
      outlineVariant: outlineVariant,
      children: [
        _buildListTile(
          title: 'Focus Mode',
          subtitle: 'Auto-enable during scheduled tasks',
          trailing: Icon(Icons.bolt, color: primary),
        ),
      ],
    );
  }

  Widget _buildFriendsSection() {
    return _SectionCard(
      title: 'Friends & Social',
      icon: Icons.group,
      primary: primary,
      surfaceContainerLowest: surfaceContainerLowest,
      outlineVariant: outlineVariant,
      children: [
        InkWell(
          onTap: () => context.go('/friends'),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 56,
                      height: 32,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                border: Border.all(color: surface, width: 2),
                              ),
                              child: const Center(
                                child: Text(
                                  'JD',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: secondaryContainer,
                                shape: BoxShape.circle,
                                border: Border.all(color: surface, width: 2),
                              ),
                              child: const Center(
                                child: Text(
                                  'AS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Manage Friends & Invites',
                      style: TextStyle(fontSize: 16, color: onSurface),
                    ),
                  ],
                ),
                Icon(Icons.chevron_right, color: outline),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection() {
    return _SectionCard(
      title: 'Analytics',
      icon: Icons.insights,
      primary: primary,
      surfaceContainerLowest: surfaceContainerLowest,
      outlineVariant: outlineVariant,
      children: [
        InkWell(
          onTap: () => context.push('/analytics'),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'PRO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'View Detailed Analytics',
                      style: TextStyle(fontSize: 16, color: onSurface),
                    ),
                  ],
                ),
                Icon(Icons.chevron_right, color: outline),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    final user = ref.watch(currentUserProvider);
    final photoUrl = user?.photoURL;
    final name = user?.displayName ?? user?.email?.split('@').first ?? 'User';
    final email = user?.email ?? 'No email available';

    return _SectionCard(
      title: 'Account',
      icon: Icons.account_circle,
      primary: primary,
      surfaceContainerLowest: surfaceContainerLowest,
      outlineVariant: outlineVariant,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryContainer,
                      border: Border.all(color: outlineVariant, width: 2),
                    ),
                    child: photoUrl != null
                        ? ClipOval(
                            child: Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Center(
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'U',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: onPrimaryContainer,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: onSurface,
                          ),
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/update-password'),
                  icon: Icon(Icons.lock_reset, color: primary),
                  label: Text(
                    'Update Password',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primary.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(authRepositoryProvider).logout();
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return _SectionCard(
      title: 'Data',
      icon: Icons.storage,
      primary: primary,
      surfaceContainerLowest: surfaceContainerLowest,
      outlineVariant: outlineVariant,
      children: [
        _buildListTile(
          title: 'Offline Mode',
          subtitle: 'Store local copies of tasks',
          trailing: _CustomSwitch(
            value: _offlineMode,
            onChanged: (val) => setState(() => _offlineMode = val),
            activeColor: primary,
            inactiveColor: surfaceContainerHighest,
          ),
        ),
      ],
    );
  }

  Widget _buildAccessibilitySection() {
    return _SectionCard(
      title: 'Accessibility',
      icon: Icons.accessibility_new,
      primary: primary,
      surfaceContainerLowest: surfaceContainerLowest,
      outlineVariant: outlineVariant,
      children: [
        InkWell(
          onTap: () => setState(() => _highContrast = !_highContrast),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'High Contrast Mode',
                  style: TextStyle(fontSize: 16, color: onSurface),
                ),
                Icon(
                  _highContrast ? Icons.toggle_on : Icons.toggle_off,
                  color: _highContrast ? primary : outline,
                  size: 32,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _SectionCard(
      title: 'About',
      icon: Icons.info,
      primary: primary,
      surfaceContainerLowest: surfaceContainerLowest,
      outlineVariant: outlineVariant,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Version',
                    style: TextStyle(fontSize: 16, color: onSurface),
                  ),
                  Text(
                    '2.4.0 (Stable)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lifetime XP',
                    style: TextStyle(fontSize: 16, color: onSurface),
                  ),
                  Builder(
                    builder: (context) {
                      final progression = ref.watch(currentProgressionProvider).value;
                      final lifetimeXP = progression?.lifetimeXP ?? 0;
                      final formatted = NumberFormat.decimalPattern().format(lifetimeXP);
                      return Text(
                        '$formatted XP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'View Policies',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.open_in_new, size: 16, color: primary),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, color: onSurface)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color primary;
  final Color surfaceContainerLowest;
  final Color outlineVariant;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.primary,
    required this.surfaceContainerLowest,
    required this.outlineVariant,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: outlineVariant.withValues(alpha: 0.3),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveColor;

  const _CustomSwitch({
    required this.value,
    required this.onChanged,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: value ? activeColor : inactiveColor,
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              top: 2,
              left: value ? 22 : 2,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

