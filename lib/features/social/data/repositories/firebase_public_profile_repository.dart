import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/public_profile_entity.dart';
import '../../domain/repositories/public_profile_repository.dart';

class FirebasePublicProfileRepository implements PublicProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<PublicProfileEntity?> getProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).collection('public_profile').doc('profile').get();
    if (!doc.exists || doc.data() == null) {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        final displayName = userDoc.data()!['displayName'] ?? 'Unknown User';
        final profile = PublicProfileEntity(
          displayName: displayName,
          currentStreak: 0,
          longestStreak: 0,
          todayCompletion: 0.0,
          weeklyCompletion: 0.0,
          monthlyCompletion: 0.0,
          overallCompletion: 0.0,
          totalCompletedTasks: 0,
          updatedAt: DateTime.now(),
        );
        await updateProfile(uid, profile);
        return profile;
      }
      return null;
    }
    return PublicProfileEntity.fromMap(doc.data()!);
  }

  @override
  Stream<PublicProfileEntity?> streamProfile(String uid) {
    return _firestore.collection('users').doc(uid).collection('public_profile').doc('profile').snapshots().asyncMap((doc) async {
      if (!doc.exists || doc.data() == null) {
        // Try to backfill from main user doc
        final userDoc = await _firestore.collection('users').doc(uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          final displayName = userDoc.data()!['displayName'] ?? 'Unknown User';
          final profile = PublicProfileEntity(
            displayName: displayName,
            currentStreak: 0,
            longestStreak: 0,
            todayCompletion: 0.0,
            weeklyCompletion: 0.0,
            monthlyCompletion: 0.0,
            overallCompletion: 0.0,
            totalCompletedTasks: 0,
            updatedAt: DateTime.now(),
          );
          // Save it so future reads work
          await updateProfile(uid, profile);
          return profile;
        }
        return null;
      }
      return PublicProfileEntity.fromMap(doc.data()!);
    });
  }

  @override
  Future<void> updateProfile(String uid, PublicProfileEntity profile) async {
    await _firestore.collection('users').doc(uid).collection('public_profile').doc('profile').set(profile.toMap(), SetOptions(merge: true));
    
    // Update simple user doc for search
    await _firestore.collection('users').doc(uid).set({
      'displayName': profile.displayName,
      'photoUrl': profile.photoUrl,
      'searchKeywords': _generateSearchKeywords(profile.displayName),
    }, SetOptions(merge: true));
  }
  
  List<String> _generateSearchKeywords(String name) {
    final keywords = <String>[];
    String current = '';
    for (int i = 0; i < name.length; i++) {
      current += name[i].toLowerCase();
      keywords.add(current);
    }
    return keywords;
  }

  @override
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    
    final snapshot = await _firestore
        .collection('users')
        .where('searchKeywords', arrayContains: query.toLowerCase())
        .limit(20)
        .get();
        
    return snapshot.docs.map((doc) => {
      'uid': doc.id,
      ...doc.data(),
    }).toList();
  }
}
