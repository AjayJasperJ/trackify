import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/daily_record_entity.dart';
import '../../domain/repositories/task_record_repository.dart';


import '../../domain/entities/reflection_entity.dart';

import '../../domain/entities/task_entity.dart';

class TaskRecordRepositoryImpl implements TaskRecordRepository {
  final FirebaseFirestore _firestore;

  TaskRecordRepositoryImpl(this._firestore);

  @override
  Stream<DailyRecordEntity?> getDailyRecord(String userId, String dateString) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('task_records')
        .doc(dateString)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return DailyRecordEntity.fromMap(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

  @override
  Future<List<DailyRecordEntity>> getRecordsForDateRange(
      String userId, String startDateString, String endDateString) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('task_records')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: startDateString)
        .where(FieldPath.documentId, isLessThanOrEqualTo: endDateString)
        .get();

    return snapshot.docs
        .map((doc) => DailyRecordEntity.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> toggleTaskCompletion(String userId, String dateString, TaskEntity task, bool isCompleted, {ReflectionEntity? reflection, List<String> completedSubtaskIds = const [], double? numericProgress}) async {
    final milestoneId = task.milestoneId;
    final goalId = task.goalId;

    List<DocumentSnapshot> preFetchedMilestones = [];
    if (goalId != null) {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection('goals')
          .doc(goalId)
          .collection('milestones')
          .get();
      preFetchedMilestones = query.docs;
    }

    final parts = dateString.split('-');
    final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    final yesterdayDt = dt.subtract(const Duration(days: 1));
    final yesterdayDateStr = "${yesterdayDt.year}-${yesterdayDt.month.toString().padLeft(2, '0')}-${yesterdayDt.day.toString().padLeft(2, '0')}";

    final streakRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('streak')
        .doc('current');

    final yesterdayRecordRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('task_records')
        .doc(yesterdayDateStr);

    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('task_records')
        .doc(dateString);

    final publicActivityRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('public_activity')
        .doc(dateString);

    final DocumentReference? milestoneRef = (milestoneId != null && goalId != null)
        ? _firestore
            .collection('users')
            .doc(userId)
            .collection('goals')
            .doc(goalId)
            .collection('milestones')
            .doc(milestoneId)
        : null;

    final DocumentReference? goalRef = (goalId != null)
        ? _firestore.collection('users').doc(userId).collection('goals').doc(goalId)
        : null;

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final publicActivitySnapshot = await transaction.get(publicActivityRef);
      final streakSnapshot = await transaction.get(streakRef);
      final yesterdayRecordSnapshot = await transaction.get(yesterdayRecordRef);
      
      DocumentSnapshot? milestoneSnapshot;
      if (milestoneRef != null) {
        milestoneSnapshot = await transaction.get(milestoneRef);
      }

      DocumentSnapshot? goalSnapshot;
      if (goalRef != null) {
        goalSnapshot = await transaction.get(goalRef);
      }

      final taskCompletion = TaskCompletionEntity(
        taskId: task.taskId,
        completed: isCompleted,
        completedAt: isCompleted ? DateTime.now() : null,
        reflection: reflection,
        completedSubtaskIds: completedSubtaskIds,
        numericProgress: numericProgress,
      );

      // 1. Update task_records
      if (!snapshot.exists) {
        transaction.set(docRef, {
          'completedTasks': {task.taskId: (isCompleted || completedSubtaskIds.isNotEmpty || numericProgress != null) ? taskCompletion.toMap() : FieldValue.delete()}
        });
      } else {
        transaction.update(docRef, {
          'completedTasks.${task.taskId}': (isCompleted || completedSubtaskIds.isNotEmpty || numericProgress != null) ? taskCompletion.toMap() : FieldValue.delete()
        });
      }

      // Calculate streak updates
      Map<String, dynamic> completedTasksToday = {};
      if (snapshot.exists && snapshot.data() != null) {
        final rawTasks = snapshot.data()!['completedTasks'];
        if (rawTasks is Map) {
          completedTasksToday = Map<String, dynamic>.from(rawTasks);
        }
      }

      int completedTasksCountBefore = completedTasksToday.values
          .where((t) => (t is Map) && (t['completed'] == true))
          .length;

      bool isTaskCurrentlyCompleted = false;
      final existingTask = completedTasksToday[task.taskId];
      if (existingTask is Map) {
        isTaskCurrentlyCompleted = existingTask['completed'] == true;
      }

      int completedTasksCountAfter = completedTasksCountBefore;
      if (isCompleted && !isTaskCurrentlyCompleted) {
        completedTasksCountAfter++;
      } else if (!isCompleted && isTaskCurrentlyCompleted) {
        completedTasksCountAfter--;
      }

      bool yesterdayHadCompletions = false;
      if (yesterdayRecordSnapshot.exists && yesterdayRecordSnapshot.data() != null) {
        final rawYesterday = yesterdayRecordSnapshot.data()!['completedTasks'];
        if (rawYesterday is Map) {
          final yesterdayCompleted = Map<String, dynamic>.from(rawYesterday);
          yesterdayHadCompletions = yesterdayCompleted.values
              .any((t) => (t is Map) && (t['completed'] == true));
        }
      }

      if (completedTasksCountBefore == 0 && completedTasksCountAfter > 0) {
        // First task completed today
        int currentStreak = 1;
        int longestStreak = 1;
        int totalCompletedDays = 1;

        if (streakSnapshot.exists && streakSnapshot.data() != null) {
          final data = streakSnapshot.data()!;
          final lastCompletedStr = data['lastCompletedDate'] as String?;
          final oldStreak = (data['currentStreak'] ?? 0) as int;
          final oldLongest = (data['longestStreak'] ?? 0) as int;
          final oldTotal = (data['totalCompletedDays'] ?? 0) as int;

          totalCompletedDays = oldTotal + 1;
          
          if (lastCompletedStr == yesterdayDateStr) {
            currentStreak = oldStreak + 1;
          } else if (lastCompletedStr == dateString) {
            currentStreak = oldStreak;
            totalCompletedDays = oldTotal;
          } else {
            currentStreak = 1;
          }
          longestStreak = oldLongest > currentStreak ? oldLongest : currentStreak;
        }

        transaction.set(streakRef, {
          'currentStreak': currentStreak,
          'longestStreak': longestStreak,
          'lastCompletedDate': dateString,
          'totalCompletedDays': totalCompletedDays,
          'updatedAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      } else if (completedTasksCountBefore > 0 && completedTasksCountAfter == 0) {
        // Last completed task reverted
        if (streakSnapshot.exists && streakSnapshot.data() != null) {
          final data = streakSnapshot.data()!;
          final lastCompletedStr = data['lastCompletedDate'] as String?;
          final oldStreak = (data['currentStreak'] ?? 0) as int;
          final oldTotal = (data['totalCompletedDays'] ?? 0) as int;

          if (lastCompletedStr == dateString) {
            int newStreak = 0;
            String? newLastCompleted;
            if (yesterdayHadCompletions) {
              newStreak = oldStreak - 1;
              if (newStreak < 0) newStreak = 0;
              newLastCompleted = yesterdayDateStr;
            } else {
              newStreak = 0;
              newLastCompleted = null;
            }

            transaction.set(streakRef, {
              'currentStreak': newStreak,
              'lastCompletedDate': newLastCompleted,
              'totalCompletedDays': oldTotal - 1 < 0 ? 0 : oldTotal - 1,
              'updatedAt': DateTime.now().toIso8601String(),
            }, SetOptions(merge: true));
          }
        }
      }

      // 2. Update public_activity
      List<dynamic> publicTasks = [];
      if (publicActivitySnapshot.exists && publicActivitySnapshot.data() != null) {
        publicTasks = List.from(publicActivitySnapshot.data()!['completedTasks'] ?? []);
      }
      
      // Remove any existing entry for this task
      publicTasks.removeWhere((t) => t['taskId'] == task.taskId);

      // If fully completed or has completed subtasks, add to public activity (if not private)
      final isGoalPrivate = goalSnapshot != null && goalSnapshot.exists && (goalSnapshot.data() as Map?)?['isPrivate'] == true;
      final isTaskPrivate = task.isPrivate || isGoalPrivate;

      if (!isTaskPrivate && (isCompleted || completedSubtaskIds.isNotEmpty || numericProgress != null)) {
        publicTasks.add({
          'taskId': task.taskId,
          'taskTitle': task.title,
          'completedAt': DateTime.now().toIso8601String(),
          'totalSubtasks': task.subtasks.length,
          'completedSubtasks': completedSubtaskIds.length,
          'subtasks': task.subtasks.map((s) => {
            'title': s.title,
            'isCompleted': completedSubtaskIds.contains(s.subtaskId),
          }).toList(),
          if (reflection != null) 'mood': reflection.level,
        });
      }

      if (publicTasks.isEmpty) {
        if (publicActivitySnapshot.exists) {
          transaction.delete(publicActivityRef);
        }
      } else {
        transaction.set(publicActivityRef, {
          'completedTasks': publicTasks
        }, SetOptions(merge: true));
      }

      // 3. Update milestone progress (if linked)
      bool isMilestoneCompleted = false;
      bool milestoneDocExists = false;

      if (milestoneRef != null && milestoneSnapshot != null && milestoneSnapshot.exists) {
        milestoneDocExists = true;
        final data = milestoneSnapshot.data() as Map<String, dynamic>;
        
        final rawMeta = data['linkedTasksMeta'];
        final Map<String, dynamic> meta = {};
        if (rawMeta is Map) {
          rawMeta.forEach((k, v) {
            if (v is Map) meta[k as String] = Map<String, dynamic>.from(v);
          });
        }
        
        final entry = meta[task.taskId];
        if (entry != null) {
          final weight = (entry['weight'] ?? 1) as int;
          int contribution = 0;
          if (isCompleted) {
            contribution = weight;
          } else if (task.trackingMode == TaskTrackingMode.numeric &&
                     task.numericTarget != null &&
                     task.numericTarget! > 0 &&
                     numericProgress != null) {
            final fraction = (numericProgress / task.numericTarget!).clamp(0.0, 1.0);
            contribution = (fraction * weight).round();
          }

          meta[task.taskId] = {
            'taskId': task.taskId,
            'weight': weight,
            'contribution': contribution,
          };

          final linkedTasks = List<String>.from(data['linkedTasks'] ?? []);
          final currentValue = meta.values.fold<int>(
            0,
            (total, e) => total + (((e as Map)['contribution'] ?? 0) as int),
          );
          final doneCount = meta.values.where(
            (e) => (((e as Map)['contribution'] ?? 0) as int) > 0,
          ).length;

          final rule = data['completionRule'] as String?;
          double newMilestoneProgress = 0.0;
          if (rule == 'targetValue') {
            final target = (data['targetValue'] ?? 0) as int;
            newMilestoneProgress = target == 0 ? 0.0 : (currentValue / target).clamp(0.0, 1.0);
            isMilestoneCompleted = target > 0 && currentValue >= target;
          } else if (rule == 'manual') {
            newMilestoneProgress = (data['progress'] ?? 0.0) as double;
            isMilestoneCompleted = (data['completed'] ?? false) as bool;
          } else {
            // allTasks
            newMilestoneProgress = linkedTasks.isEmpty ? 0.0 : doneCount / linkedTasks.length;
            isMilestoneCompleted = linkedTasks.isNotEmpty && doneCount >= linkedTasks.length;
          }

          transaction.update(milestoneRef, {
            'linkedTasksMeta': meta,
            'currentValue': currentValue,
            'progress': newMilestoneProgress,
            'completed': isMilestoneCompleted,
            'completedAt': isMilestoneCompleted ? DateTime.now().toIso8601String() : null,
          });
        }
      }

      // 4. Update goal progress (if linked to milestone)
      if (goalRef != null && milestoneRef != null) {
        int completedMilestonesCount = 0;
        for (final doc in preFetchedMilestones) {
          bool comp = false;
          if (doc.id == milestoneId && milestoneDocExists) {
            comp = isMilestoneCompleted;
          } else {
            final d = doc.data() as Map<String, dynamic>?;
            comp = (d != null && d['completed'] == true);
          }
          if (comp) {
            completedMilestonesCount++;
          }
        }

        final totalMilestones = preFetchedMilestones.length;
        final newGoalProgress = totalMilestones == 0 ? 0.0 : completedMilestonesCount / totalMilestones;
        
        String newGoalStatus = 'notStarted';
        if (newGoalProgress == 1.0) {
          newGoalStatus = 'completed';
        } else if (newGoalProgress > 0.0) {
          newGoalStatus = 'active';
        }

        transaction.update(goalRef, {
          'progress': newGoalProgress,
          'status': newGoalStatus,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  @override
  Future<void> saveReflection(String userId, String dateString,
      String taskId, ReflectionEntity reflection) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('task_records')
        .doc(dateString);

    final publicActivityRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('public_activity')
        .doc(dateString);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      // If the record doesn't exist yet (task not completed that day) there
      // is nothing to attach a reflection to — no-op.
      if (!snapshot.exists || snapshot.data() == null) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final completedTasks = Map<String, dynamic>.from(data['completedTasks'] as Map? ?? {});

      // ALL READS MUST COME BEFORE WRITES
      final publicActivitySnapshot = await transaction.get(publicActivityRef);

      final taskEntry = completedTasks[taskId];
      if (taskEntry is Map) {
        final updatedEntry = Map<String, dynamic>.from(taskEntry);
        updatedEntry['reflection'] = reflection.toMap();
        completedTasks[taskId] = updatedEntry;
      } else {
        completedTasks[taskId] = {
          'taskId': taskId,
          'completed': taskEntry == true,
          'reflection': reflection.toMap(),
        };
      }

      // WRITES BEGIN HERE
      transaction.update(docRef, {
        'completedTasks': completedTasks,
      });

      // Keep the public activity mood in sync.
      if (publicActivitySnapshot.exists &&
          publicActivitySnapshot.data() != null) {
        final publicData = publicActivitySnapshot.data() as Map<String, dynamic>;
        final publicTasks =
            List.from(publicData['completedTasks'] ?? []);
        final idx = publicTasks.indexWhere((t) => t is Map && t['taskId'] == taskId);
        if (idx != -1) {
          publicTasks[idx] = {
            ...publicTasks[idx] as Map,
            'mood': reflection.level,
          };
          transaction.set(
            publicActivityRef,
            {'completedTasks': publicTasks},
            SetOptions(merge: true),
          );
        }
      }
    });
  }
}
