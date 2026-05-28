import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<UserModel> signIn({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id', userCredential.user!.uid);

      DocumentSnapshot doc = await _firestore.collection('Users').doc(userCredential.user!.uid).get();
      if (!doc.exists) {
        return UserModel(id: userCredential.user!.uid, name: 'User', email: email);
      }
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<UserModel> signUp({required String email, required String password, required String name}) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      UserModel newUser = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
      );

      await _firestore.collection('Users').doc(newUser.id).set(newUser.toMap());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id', newUser.id);

      return newUser;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }
  
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id');
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send reset email: $e');
    }
  }
}
