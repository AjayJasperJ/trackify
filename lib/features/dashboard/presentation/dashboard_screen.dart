import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/trackify_app_bar.dart';
import 'widgets/dashboard_xp_card.dart';
import 'widgets/dashboard_analytics_grid.dart';
import 'widgets/dashboard_tasks_section.dart';
import 'widgets/dashboard_goals_section.dart';
import 'widgets/dashboard_motivational_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  final Color background = const Color(0xFFFCF9F8);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: topPadding + 64 + 24,
              bottom: bottomPadding + 24,
              left: 16.0,
              right: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardXpCard(),
                const SizedBox(height: 24),
                const DashboardAnalyticsGrid(),
                const SizedBox(height: 24),
                const DashboardTasksSection(),
                const SizedBox(height: 24),
                const DashboardGoalsSection(),
                const SizedBox(height: 24),
                const DashboardMotivationalCard(),
              ],
            ),
          ),
          const TrackifyAppBar(
            title: 'Dashboard',
            showProfile: true,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1976D2),
        unselectedItemColor: Colors.grey.shade600,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.grid_view),
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.check_circle_outline),
            ),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.ads_click),
            ),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.settings_outlined),
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
