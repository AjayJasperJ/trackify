import 'package:flutter_test/flutter_test.dart';

import 'package:trackify/features/goals/domain/entities/milestone_entity.dart';
import 'package:trackify/features/task/domain/entities/schedule_entity.dart';
import 'package:trackify/features/task/domain/entities/subtask_entity.dart';
import 'package:trackify/features/task/domain/entities/task_entity.dart';

/// Mirrors the reorder logic in AddTaskSubtasksCard.onReorderItem:
/// onReorderItem already adjusts newIndex for the removed item (no -= 1),
/// and every subtask's order is re-indexed after the move.
List<SubtaskEntity> _reorder(List<SubtaskEntity> list, int oldIndex, int newIndex) {
  final newList = List<SubtaskEntity>.from(list);
  final item = newList.removeAt(oldIndex);
  newList.insert(newIndex, item);
  for (int i = 0; i < newList.length; i++) {
    newList[i] = newList[i].copyWith(order: i);
  }
  return newList;
}

/// Mirrors AddTaskController.save milestone diff: unlink when a previously
/// linked milestone was removed or swapped, link when a new one is chosen.
({bool unlink, bool link}) _milestoneDiff(
  MilestoneEntity? original,
  MilestoneEntity? selected,
) {
  final unlink = original != null &&
      (selected == null || original.milestoneId != selected.milestoneId);
  final link = selected != null &&
      (original == null || original.milestoneId != selected.milestoneId);
  return (unlink: unlink, link: link);
}

SubtaskEntity _sub(String id, {String title = '', int order = 0}) =>
    SubtaskEntity(subtaskId: id, title: title, order: order);

MilestoneEntity _ms(String id) => MilestoneEntity(
      milestoneId: id,
      goalId: 'g',
      title: id,
      description: '',
      createdAt: DateTime.now(),
    );

void main() {
  group('subtask reorder', () {
    test('moves item down and re-indexes order', () {
      final list = [_sub('a', order: 0), _sub('b', order: 1), _sub('c', order: 2)];
      // Drag index 0 to after index 2: the framework already adjusted the
      // index (3 → 2) before onReorderItem fires.
      final result = _reorder(list, 0, 2);
      expect(result.map((s) => s.subtaskId).toList(), ['b', 'c', 'a']);
      expect(result.map((s) => s.order).toList(), [0, 1, 2]);
    });

    test('moves item up', () {
      final list = [_sub('a', order: 0), _sub('b', order: 1), _sub('c', order: 2)];
      // Drag index 2 to before index 0 → onReorderItem gives (2, 0).
      final result = _reorder(list, 2, 0);
      expect(result.map((s) => s.subtaskId).toList(), ['c', 'a', 'b']);
      expect(result.map((s) => s.order).toList(), [0, 1, 2]);
    });

    test('no-op move keeps identity', () {
      final list = [_sub('a'), _sub('b'), _sub('c')];
      final result = _reorder(list, 1, 1);
      expect(result.map((s) => s.subtaskId).toList(), ['a', 'b', 'c']);
    });
  });

  group('milestone link diff', () {
    test('new task with milestone → link only', () {
      final d = _milestoneDiff(null, _ms('m1'));
      expect(d.unlink, isFalse);
      expect(d.link, isTrue);
    });

    test('unchanged milestone → no op', () {
      final m = _ms('m1');
      final d = _milestoneDiff(m, m);
      expect(d.unlink, isFalse);
      expect(d.link, isFalse);
    });

    test('milestone removed → unlink only', () {
      final d = _milestoneDiff(_ms('m1'), null);
      expect(d.unlink, isTrue);
      expect(d.link, isFalse);
    });

    test('milestone swapped → unlink + link', () {
      final d = _milestoneDiff(_ms('m1'), _ms('m2'));
      expect(d.unlink, isTrue);
      expect(d.link, isTrue);
    });
  });

  group('linked task expiry (effectiveEndDate / isExpired)', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final future = today.add(const Duration(days: 10));
    final past = today.subtract(const Duration(days: 10));

    TaskEntity task({DateTime? endDate}) => TaskEntity(
          taskId: 't',
          title: 'T',
          schedule: const DailyScheduleEntity(),
          startDate: today,
          endDate: endDate,
          createdAt: now,
          updatedAt: now,
        );

    test('no link → task keeps its own endDate', () {
      final t = task(endDate: future);
      expect(t.effectiveEndDate, future);
      expect(t.isExpired, isFalse);
    });

    test('linked goal targetDate overrides task endDate', () {
      final t = task(endDate: future)..linkedGoalTargetDate = past;
      expect(t.effectiveEndDate, past);
      expect(t.isExpired, isTrue);
    });

    test('linked milestone deadline wins over goal targetDate', () {
      final t = task(endDate: future)
        ..linkedGoalTargetDate = future
        ..linkedMilestoneDeadline = past;
      expect(t.effectiveEndDate, past);
      expect(t.isExpired, isTrue);
    });

    test('completed goal expires the task regardless of dates', () {
      final t = task(endDate: future)..linkedGoalCompleted = true;
      expect(t.isExpired, isTrue);
    });

    test('completed milestone expires the task regardless of dates', () {
      final t = task(endDate: future)..linkedMilestoneCompleted = true;
      expect(t.isExpired, isTrue);
    });

    test('linked future date does NOT expire the task', () {
      final t = task(endDate: past)..linkedGoalTargetDate = future;
      expect(t.effectiveEndDate, future);
      expect(t.isExpired, isFalse);
    });
  });
}
