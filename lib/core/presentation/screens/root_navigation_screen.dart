import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RootNavigationScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const RootNavigationScreen({
    super.key,
    required this.navigationShell,
  });

  final Color surface = const Color(0xFFFCF9F8);
  final Color primary = const Color(0xFF005396);
  final Color onSurfaceVariant = const Color(0xFF414751);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          navigationShell,
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  height: 64.0 + bottomPadding,
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  decoration: BoxDecoration(
                    color: surface.withValues(alpha: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        icon: Icons.grid_view,
                        label: 'Dashboard',
                        index: 0,
                      ),
                      _buildNavItem(
                        icon: Icons.check_circle_outline,
                        label: 'Tasks',
                        index: 1,
                      ),
                      _buildNavItem(
                        icon: Icons.ads_click,
                        label: 'Goals',
                        index: 2,
                      ),
                      _buildNavItem(
                        icon: Icons.group_outlined,
                        label: 'Friends',
                        index: 3,
                      ),
                      _buildNavItem(
                        icon: Icons.settings,
                        label: 'Settings',
                        index: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = navigationShell.currentIndex == index;
    final color = isSelected ? primary : onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: () {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 10 * 0.05,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
