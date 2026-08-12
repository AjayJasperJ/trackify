import 'package:flutter/material.dart';

class GoalsDashboardFilterTabs extends StatelessWidget {
  final int selectedTabIndex;
  final ValueChanged<int> onTabSelected;
  final Color primary;
  final Color surfaceContainer;
  final Color onSurfaceVariant;

  const GoalsDashboardFilterTabs({
    super.key,
    required this.selectedTabIndex,
    required this.onTabSelected,
    required this.primary,
    required this.surfaceContainer,
    required this.onSurfaceVariant,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = ['Active Goals', 'Completed', 'On Hold'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedTabIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => onTabSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? primary : surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.24,
                    color: isSelected ? Colors.white : onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
