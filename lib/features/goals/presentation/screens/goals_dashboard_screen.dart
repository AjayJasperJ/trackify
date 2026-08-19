import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/goal_providers.dart';
import '../../domain/entities/goal_enums.dart';
import '../../domain/entities/goal_entity.dart';
import '../goals_dashboard_widgets/goals_dashboard_motivational_summary.dart';
import '../goals_dashboard_widgets/goals_dashboard_filter_tabs.dart';
import '../goals_dashboard_widgets/interactive_goal_card.dart';
import '../../../../widgets/dashboard_app_bar.dart';

class GoalsDashboardScreen extends ConsumerStatefulWidget {
  const GoalsDashboardScreen({super.key});

  @override
  ConsumerState<GoalsDashboardScreen> createState() =>
      _GoalsDashboardScreenState();
}

class _GoalsDashboardScreenState extends ConsumerState<GoalsDashboardScreen> {
  final Color background = const Color(0xFFFCF9F8);
  final Color surface = const Color(0xFFFCF9F8);
  final Color surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color surfaceContainerLow = const Color(0xFFF6F3F2);
  final Color surfaceContainer = const Color(0xFFF0EDED);
  final Color surfaceContainerHigh = const Color(0xFFEAE7E7);
  final Color primaryContainer = const Color(0xFF0F6CBD);
  final Color onPrimaryContainer = const Color(0xFFE3ECFF);
  final Color primary = const Color(0xFF005396);
  final Color onSurface = const Color(0xFF1B1C1C);
  final Color onSurfaceVariant = const Color(0xFF414751);
  final Color outlineVariant = const Color(0xFFC1C7D3);
  final Color secondaryContainer = const Color(0xFFE1DFDF);
  final Color onSecondaryContainer = const Color(0xFF626262);
  final Color tertiary = const Color(0xFF515353);
  final Color tertiaryContainer = const Color(0xFF696B6B);

  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final goalsAsync = ref.watch(goalsStreamProvider);

    return Scaffold(
      backgroundColor: background,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 64.0 + bottomPadding),
        child: FloatingActionButton(
          heroTag: null,
          onPressed: () {
            context.push('/create-goal');
          },
          backgroundColor: primary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: topPadding + 64 + 24,
                  bottom: bottomPadding + 64 + 96,
                  left: 16.0,
                  right: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GoalsDashboardMotivationalSummary(
                      primaryContainer: primaryContainer,
                      onPrimaryContainer: onPrimaryContainer,
                    ),
                    const SizedBox(height: 24),
                    GoalsDashboardFilterTabs(
                      selectedTabIndex: _selectedTabIndex,
                      onTabSelected: (index) =>
                          setState(() => _selectedTabIndex = index),
                      primary: primary,
                      surfaceContainer: surfaceContainer,
                      onSurfaceVariant: onSurfaceVariant,
                    ),
                    const SizedBox(height: 24),
                    goalsAsync.when(
                      data: (goals) {
                        // Filter goals based on tab selection
                        final filteredGoals = goals.where((goal) {
                          if (_selectedTabIndex == 0) {
                            // Active
                            return goal.status != GoalStatus.completed &&
                                !goal.archived;
                          } else if (_selectedTabIndex == 1) {
                            // Completed
                            return goal.status == GoalStatus.completed;
                          } else {
                            // On Hold / Archived
                            return goal.archived;
                          }
                        }).toList();

                        return _buildGoalsGrid(filteredGoals);
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                    ),
                  ],
                ),
              ),
              DashboardAppBar(
                title: 'Goals',
                showAvatar: false,
                topPadding: topPadding,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsGrid(List<GoalEntity> goals) {
    if (goals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(
                Icons.flag_outlined,
                size: 64,
                color: onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No goals found.',
                style: TextStyle(color: onSurfaceVariant, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: goals.map((goal) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: InteractiveGoalCard(
            goal: goal,
            title: goal.title,
            subtitle: goal.targetDate != null
                ? 'Due ${goal.targetDate!.toIso8601String().substring(0, 10)}'
                : 'No due date',
            xpText: '+${goal.targetXP} XP',
            progressValue: goal.progress,
            surfaceContainerLowest: surfaceContainerLowest,
            surfaceContainerHigh: surfaceContainerHigh,
            secondaryContainer: secondaryContainer,
            onSecondaryContainer: onSecondaryContainer,
            onSurface: onSurface,
            onSurfaceVariant: onSurfaceVariant,
            extraContent: _buildSparkline(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSparkline() {
    final heights = [0.4, 0.6, 0.3, 0.8, 0.55, 1.0, 0.2];

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEEKLY VELOCITY',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            spacing: 2,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              return Expanded(
                child: Container(
                  height: 32 * heights[index],
                  decoration: BoxDecoration(
                    color: primary.withValues(
                      alpha: heights[index] > 0.5 ? 1.0 : 0.4,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
