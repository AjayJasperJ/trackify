import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../../domain/entities/goal_entity.dart';
import '../../providers/goal_providers.dart';

class InteractiveGoalCard extends ConsumerStatefulWidget {
  final GoalEntity goal;
  final String title, subtitle, xpText;
  final Color? iconBgColor;
  final double progressValue;
  final Color surfaceContainerLowest,
      surfaceContainerHigh,
      secondaryContainer,
      onSecondaryContainer,
      onSurface,
      onSurfaceVariant;
  final Widget extraContent;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const InteractiveGoalCard({
    super.key,
    required this.goal,
    required this.title,
    required this.subtitle,
    required this.xpText,
    this.iconBgColor,
    required this.progressValue,
    required this.surfaceContainerLowest,
    required this.surfaceContainerHigh,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.extraContent,
    this.onEdit,
    this.onDelete,
  });

  @override
  ConsumerState<InteractiveGoalCard> createState() =>
      _InteractiveGoalCardState();
}

class _InteractiveGoalCardState extends ConsumerState<InteractiveGoalCard> {
  bool isPressed = false;

  Future<void> _confirmAndDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal?'),
        content: Text(
          'Are you sure you want to delete "${widget.goal.title}" and all its milestones?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        try {
          await ref
              .read(goalRepositoryProvider)
              .deleteGoal(user.uid, widget.goal.goalId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Goal deleted successfully')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to delete goal: $e')),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final milestonesAsync = ref.watch(milestonesStreamProvider(widget.goal.goalId));
    final milestones = milestonesAsync.value ?? [];
    final completedCount = milestones.where((m) => m.completed).length;
    final totalCount = milestones.length;
    final milestoneText = '$completedCount';
    final totalMilestoneText = '/ $totalCount milestones';

    IconData goalIcon = Icons.track_changes;
    switch (widget.goal.icon) {
      case 'fitness_center':
        goalIcon = Icons.fitness_center;
        break;
      case 'attach_money':
        goalIcon = Icons.attach_money;
        break;
      case 'star':
        goalIcon = Icons.star;
        break;
      case 'work':
        goalIcon = Icons.work;
        break;
    }
    final Color defaultThemeColor = const Color(0xFF005396);

    return GestureDetector(
      onTap: () {
        context.push('/goal-detail/${widget.goal.goalId}', extra: widget.goal);
      },
      onLongPressStart: (details) async {
        setState(() => isPressed = false);
        final selected = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy,
            details.globalPosition.dx,
            details.globalPosition.dy,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          items: [
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Edit Goal'),
                ],
              ),
            ),
            if (!widget.goal.isStrict)
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text('Delete Goal', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
        );

        if (!context.mounted) return;

        if (selected == 'edit') {
          if (widget.onEdit != null) {
            widget.onEdit!();
          } else {
            context.push('/edit-goal/${widget.goal.goalId}', extra: widget.goal);
          }
        } else if (selected == 'delete') {
          if (widget.onDelete != null) {
            widget.onDelete!();
          } else {
            _confirmAndDelete();
          }
        }
      },
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      child: AnimatedScale(
        scale: isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: widget.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color:
                                    widget.iconBgColor ??
                                    defaultThemeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(goalIcon, color: defaultThemeColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: widget.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              goalIcon == Icons.rocket_launch
                                  ? Icons.calendar_today
                                  : Icons.timer,
                              size: 14,
                              color: widget.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: widget.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.secondaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.xpText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: widget.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  SizedBox(
                    width: 128,
                    height: 128,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 8,
                          color: widget.surfaceContainerHigh,
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: 0.0,
                            end: widget.progressValue,
                          ),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return CircularProgressIndicator(
                              value: value,
                              strokeWidth: 8,
                              color: defaultThemeColor,
                              backgroundColor: Colors.transparent,
                              strokeCap: StrokeCap.round,
                            );
                          },
                        ),
                        Center(
                          child: Text(
                            '${(widget.progressValue * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.48,
                              color: widget.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MILESTONES',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: widget.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              milestoneText,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: widget.onSurface,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Text(
                                totalMilestoneText,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: widget.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0.0,
                              end: widget.progressValue,
                            ),
                            duration: const Duration(milliseconds: 1000),
                            builder: (context, value, _) {
                              return LinearProgressIndicator(
                                value: value,
                                minHeight: 6,
                                backgroundColor: widget.surfaceContainerHigh,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  defaultThemeColor,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              widget.extraContent,
            ],
          ),
        ),
      ),
    );
  }
}
