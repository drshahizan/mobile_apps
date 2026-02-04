import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> userProfileStream(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  /// Create a new user document in Firestore after authentication.
  /// Syncs user data with Firebase Authentication.
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
  }) async {
    try {
      await _db.collection('users').doc(uid).set(
        {
          'uid': uid,
          'email': email,
          'displayName': displayName,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'isActive': true,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Firestore error creating user profile: $e');
      rethrow;
    }
  }

  /// Update the last login timestamp for a user.
  Future<void> updateLastLogin(String uid) async {
    try {
      await _db.collection('users').doc(uid).update(
        {'lastLogin': FieldValue.serverTimestamp()},
      );
    } catch (e) {
      // Silent fail for last login update
    }
  }

  /// Update user role to Admin (A)
  Future<void> updateUserToAdmin(String uid) async {
    try {
      await _db.collection('users').doc(uid).update({
        'userGroup': 'A',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✓ User $uid updated to Admin role');
    } catch (e) {
      print('✗ Error updating user role: $e');
      rethrow;
    }
  }

  /// Update user role (userGroup: S/T/A)
  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _db.collection('users').doc(uid).update({
        'userGroup': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✓ User $uid role updated to $role');
    } catch (e) {
      print('✗ Error updating user role: $e');
      rethrow;
    }
  }
}


