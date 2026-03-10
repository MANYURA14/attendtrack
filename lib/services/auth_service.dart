import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required String studentId,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _db.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'name': name,
        'email': email.trim(),
        'studentId': studentId,
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> signOut() => _auth.signOut();

  String _handleError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'No account found with this email.';
      case 'wrong-password': return 'Incorrect password.';
      case 'email-already-in-use': return 'Email already registered.';
      case 'weak-password': return 'Password must be at least 6 characters.';
      case 'invalid-email': return 'Invalid email address.';
      default: return 'Error: ${e.message}';
    }
  }
}
