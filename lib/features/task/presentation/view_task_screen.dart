import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/entities/task_entity.dart';
import '../../../widgets/dashboard_app_bar.dart';
import 'dart:math' as math;

import '../providers/task_state_providers.dart';
import '../domain/entities/reflection_entity.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import 'view_task_widgets/view_task_header.dart';
import 'view_task_widgets/view_task_bento_stats.dart';
import 'view_task_widgets/view_task_subtasks.dart';
import 'view_task_widgets/view_task_heatmap.dart';
import 'view_task_widgets/view_task_mood_and_notes.dart';

class ViewTaskScreen extends ConsumerStatefulWidget {
  /// Optional fast-path instance passed via `state.extra`; when null (deep
  /// link / restart), the screen resolves the task from [taskProvider].
  final TaskEntity? task;
  final String taskId;

  const ViewTaskScreen({super.key, required this.taskId, this.task});

  @override
  ConsumerState<ViewTaskScreen> createState() => _ViewTaskScreenState();
}

class _ViewTaskScreenState extends ConsumerState<ViewTaskScreen>
    with TickerProviderStateMixin {
  late TaskEntity? _task = widget.task;
  late bool _loadFailed = false;

  static const Color background = Color(0xFFFCF9F8);
  final Color surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color surfaceContainerLow = const Color(0xFFF6F3F2);
  final Color surfaceContainerHigh = const Color(0xFFEAE7E7);
  final Color primary = const Color(0xFF005396);
  final Color onSurface = const Color(0xFF1B1C1C);
  final Color onSurfaceVariant = const Color(0xFF414751);
  final Color outlineVariant = const Color(0xFFC1C7D3);
  final Color secondary = const Color(0xFF5E5E5E);
  final Color surfaceVariant = const Color(0xFFE4E2E1);

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late List<double> _heatmapData;
  bool _savingReflection = false;

  static const List<String> _moodLevels = [
    'Very Low',
    'Low',
    'Normal',
    'Good',
    'Excellent',
  ];

  Future<void> _saveReflection(int moodIndex, String note) async {
    final user = ref.read(currentUserProvider);
    final task = _task;
    if (user == null || task == null) return;
    setState(() => _savingReflection = true);
    try {
      await ref.read(taskRecordRepositoryProvider).saveReflection(
            user.uid,
            ref.read(currentDateStringProvider),
            task.taskId,
            ReflectionEntity(
              level: _moodLevels[moodIndex],
              note: note.isEmpty ? null : note,
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reflection saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingReflection = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    final random = math.Random();
    _heatmapData = List.generate(30, (_) => random.nextDouble());

    if (_task == null) _resolveTask();
  }

  /// Deep-link resolution: fetch the task from Firestore by id.
  Future<void> _resolveTask() async {
    try {
      final task = await ref.read(taskProvider(widget.taskId).future);
      if (!mounted) return;
      if (task != null) {
        setState(() => _task = task);
      } else {
        setState(() => _loadFailed = true);
      }
    } catch (e) {
      if (mounted) setState(() => _loadFailed = true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final task = _task;
    if (task == null) {
      return Scaffold(
        backgroundColor: background,
        body: Stack(
          children: [
            Center(
              child: _loadFailed
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.task_alt,
                          size: 56,
                          color: Color(0xFF414751),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Task not found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'It may have been deleted.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF414751),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: () => context.go('/all-tasks'),
                          child: const Text('Back to Tasks'),
                        ),
                      ],
                    )
                  : const CircularProgressIndicator(),
            ),
            DashboardAppBar(
              topPadding: topPadding,
              showAvatar: false,
              isInnerScreen: true,
              title: 'Task Details',
            ),
          ],
        ),
      );
    }

    // Mood/reflections are only available for today's task, and only after
    // the user completes it.
    final todayTasks = ref.watch(todayTasksProvider).valueOrNull ?? [];
    final todayRecord = ref.watch(todayRecordStreamProvider).valueOrNull;
    final isTodayTask = todayTasks.any((t) => t.taskId == task.taskId);
    final isCompleted =
        todayRecord?.completedTasks[task.taskId]?.completed ?? false;
    final moodEnabled = isTodayTask && isCompleted;

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: topPadding + 64,
              bottom: bottomPadding + 64 + 96,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ViewTaskHeader(
                  task: task,
                  pulseAnimation: _pulseAnimation,
                  primary: primary,
                  onSurface: onSurface,
                  onSurfaceVariant: onSurfaceVariant,
                  surfaceContainerHigh: surfaceContainerHigh,
                ),
                ViewTaskBentoStats(
                  task: task,
                  surfaceContainerLow: surfaceContainerLow,
                  secondary: secondary,
                  onSurface: onSurface,
                  primary: primary,
                  surfaceVariant: surfaceVariant,
                  onSurfaceVariant: onSurfaceVariant,
                ),
                ViewTaskSubtasks(
                  task: task,
                  onSurface: onSurface,
                  secondary: secondary,
                  surfaceContainerLowest: surfaceContainerLowest,
                  primary: primary,
                  outlineVariant: outlineVariant,
                  surfaceVariant: surfaceVariant,
                ),
                ViewTaskHeatmap(
                  heatmapData: _heatmapData,
                  onSurface: onSurface,
                  primary: primary,
                  surfaceContainerLow: surfaceContainerLow,
                  surfaceVariant: surfaceVariant,
                  secondary: secondary,
                ),
                ViewTaskMoodAndNotes(
                  enabled: moodEnabled,
                  saving: _savingReflection,
                  onSave: (moodIndex, note) => _saveReflection(moodIndex, note),
                  onSurface: onSurface,
                  surfaceContainerLow: surfaceContainerLow,
                  primary: primary,
                  onSurfaceVariant: onSurfaceVariant,
                ),
              ],
            ),
          ),
          DashboardAppBar(
            topPadding: topPadding,
            showAvatar: false,
            isInnerScreen: true,
            title: 'Task Details',
          ),
        ],
      ),
    );
  }
}
