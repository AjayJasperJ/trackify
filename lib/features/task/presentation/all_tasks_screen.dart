import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trackify/features/task/providers/task_state_providers.dart';

import 'all_tasks_widgets/all_tasks_header.dart';
import 'all_tasks_widgets/all_tasks_progress_summary.dart';
import 'all_tasks_widgets/all_tasks_today_section.dart';
import 'all_tasks_widgets/all_tasks_other_section.dart';

class AllTasksScreen extends ConsumerStatefulWidget {
  const AllTasksScreen({super.key});

  @override
  ConsumerState<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends ConsumerState<AllTasksScreen> {
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
  final Color secondaryContainer = const Color(0xFFE1DFDF);

  @override
  Widget build(BuildContext context) {
    final tasksAsyncValue = ref.watch(todayTasksProvider);
    final upcomingTasksAsync = ref.watch(userTasksStreamProvider);
    final dailyRecordAsync = ref.watch(todayRecordStreamProvider);

    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: background,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 64.0 + bottomPadding),
        child: FloatingActionButton(
          onPressed: () {
            context.push('/add-task');
          },
          backgroundColor: primary,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: topPadding + 64 + 16,
              bottom: bottomPadding + 64 + 96,
              left: 16.0,
              right: 16.0,
            ),
            child: tasksAsyncValue.when(
              data: (todayTasks) {
                final record = dailyRecordAsync.valueOrNull;

                int completedTasks = 0;
                for (var task in todayTasks) {
                  if (record != null &&
                      record.completedTasks[task.taskId]?.completed == true) {
                    completedTasks++;
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    AllTasksProgressSummary(
                      totalTasks: todayTasks.length,
                      completedTasks: completedTasks,
                      primaryContainer: primaryContainer,
                      onPrimaryContainer: onPrimaryContainer,
                    ),
                    const SizedBox(height: 32),
                    if (todayTasks.isEmpty && upcomingTasksAsync.valueOrNull?.isEmpty == true)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 48.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 64, color: outlineVariant),
                              const SizedBox(height: 16),
                              Text(
                                "No tasks yet",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Tap the + button to add a new task",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      AllTasksTodaySection(
                        tasks: todayTasks,
                        dailyRecord: record,
                        ref: ref,
                        onSurface: onSurface,
                        primary: primary,
                        secondaryContainer: secondaryContainer,
                        surfaceContainerLowest: surfaceContainerLowest,
                        surfaceContainerLow: surfaceContainerLow,
                        outline: outline,
                        onSurfaceVariant: onSurfaceVariant,
                      ),
                      const SizedBox(height: 32),
                      upcomingTasksAsync.when(
                        data: (allTasks) {
                          final todayIds = todayTasks
                              .map((t) => t.taskId)
                              .toSet();
                          final otherTasks = allTasks
                              .where((t) => !todayIds.contains(t.taskId))
                              .toList();
                          if (otherTasks.isEmpty) return const SizedBox.shrink();
                          return AllTasksOtherSection(
                            tasks: otherTasks,
                            dailyRecord: record,
                            ref: ref,
                            onSurface: onSurface,
                            onSurfaceVariant: onSurfaceVariant,
                            surfaceContainerHighest: surfaceContainerHighest,
                            surfaceContainerLow: surfaceContainerLow,
                            surfaceContainerLowest: surfaceContainerLowest,
                            secondaryContainer: secondaryContainer,
                            outline: outline,
                            outlineVariant: outlineVariant,
                            primary: primary,
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                    ],
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
          AllTasksHeader(topPadding: topPadding),
        ],
      ),
    );
  }
}
