// Firebase service helper (simple wrapper)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;

  static Future<void> init() async {
    // Assumes Firebase.initializeApp() already called in main
    // Additional initialization logic (emulators, settings) can be added here.
  }

  static Future<UserCredential> signInWithEmail(String email, String password) async {
    return await auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    await auth.signOut();
  }

  static Future<void> saveCharacterToCloud(String id, Map<String, dynamic> data) async {
    await firestore.collection('characters').doc(id).set(data);
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> fetchCharacter(String id) async {
    return await firestore.collection('characters').doc(id).get();
  }

  /// Fetch all characters from Firebase for the current user
  static Future<List<Map<String, dynamic>>> fetchAllUserCharacters() async {
    try {
      final user = auth.currentUser;
      if (user == null) return [];
      
      final snapshot = await firestore
          .collection('characters')
          .where('userId', isEqualTo: user.uid)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching characters from Firebase: $e');
      return [];
    }
  }
}
