// ignore_for_file: prefer_initializing_formals
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/milestone_entity.dart';
import '../../domain/repositories/milestone_repository.dart';

/// `ponytail:` Smallest ChangeNotifier that lets MilestoneEditorScreen go
/// create/edit with zero setState. If a third editor appears, extract the
/// shared bits into a base editor controller.
class MilestoneEditorController extends ChangeNotifier {
  final MilestoneRepository _repo;

  final TextEditingController title;
  final TextEditingController description;
  final TextEditingController targetValue;
  DateTime? deadline;
  MilestoneCompletionRule completionRule;
  bool isLoading;

  MilestoneEditorController({
    required MilestoneRepository repo,
    required this.goalId,
    MilestoneEntity? milestoneToEdit,
  })  : _repo = repo,
        title = TextEditingController(text: milestoneToEdit?.title ?? ''),
        description =
            TextEditingController(text: milestoneToEdit?.description ?? ''),
        targetValue = TextEditingController(
          text: milestoneToEdit?.targetValue?.toString() ?? '',
        ),
        deadline = milestoneToEdit?.deadline,
        completionRule = milestoneToEdit?.completionRule ?? MilestoneCompletionRule.allTasks,
        isLoading = false,
        milestoneId = milestoneToEdit?.milestoneId ?? const Uuid().v4(),
        isEditing = milestoneToEdit != null,
        original = milestoneToEdit;

  final String goalId;
  final String milestoneId;
  final bool isEditing;

  /// The milestone being edited (null in create mode). All the read-only
  /// linkage/progress data lives on this instance and is preserved on save.
  final MilestoneEntity? original;

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    targetValue.dispose();
    super.dispose();
  }

  void setDeadline(DateTime? d) {
    deadline = d;
    notifyListeners();
  }

  void setLoading(bool v) {
    isLoading = v;
    notifyListeners();
  }

  void setCompletionRule(MilestoneCompletionRule rule) {
    completionRule = rule;
    notifyListeners();
  }

  Future<void> save(String uid) async {
    final ms = MilestoneEntity(
      milestoneId: milestoneId,
      goalId: goalId,
      title: title.text.trim(),
      description: description.text.trim(),
      progress: original?.progress ?? 0.0,
      completed: original?.completed ?? false,
      // Preserve link data on edit
      linkedTasks: original?.linkedTasks ?? const [],
      linkedTasksMeta: original?.linkedTasksMeta ?? const {},
      completionRule: completionRule,
      targetValue: int.tryParse(targetValue.text.trim()),
      currentValue: original?.currentValue ?? 0,
      deadline: deadline,
      completedAt: original?.completedAt,
      createdAt: original?.createdAt ?? DateTime.now(),
    );

    if (isEditing) {
      await _repo.updateMilestone(uid, ms);
    } else {
      await _repo.addMilestone(uid, ms);
    }
  }
}
