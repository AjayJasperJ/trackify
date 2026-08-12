import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  AuthRemoteDataSource({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<UserCredential> login(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> register(String email, String password) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> updateProfile(String name, {String? phone, String? image}) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final photoUrl = (image != null && image.isNotEmpty)
          ? image
          : 'https://api.dicebear.com/7.x/adventurer/png?seed=${user.uid}';
      
      await user.updateDisplayName(name);
      await user.updatePhotoURL(photoUrl);
      
      final Map<String, dynamic> userData = {
        'displayName': name,
        'photoUrl': photoUrl,
        'searchKeywords': _generateSearchKeywords(name),
      };
      if (phone != null && phone.isNotEmpty) {
        userData['phoneNumber'] = phone;
      }
      
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        userData, 
        SetOptions(merge: true)
      );
      
      // Initialize public profile
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('public_profile')
          .doc('profile')
          .set({
        'uid': user.uid,
        'displayName': name,
        'photoUrl': photoUrl,
        'bio': null,
      }, SetOptions(merge: true));
    }
  }

  Future<void> forgotPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> updatePassword(String newPassword) async {
    await _firebaseAuth.currentUser?.updatePassword(newPassword);
  }

  Future<void> reauthenticate(String email, String password) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await _firebaseAuth.currentUser?.reauthenticateWithCredential(credential);
  }

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  
  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> logout() async {
    await _firebaseAuth.signOut();
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
}
