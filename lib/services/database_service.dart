import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../components/constants.dart';
import '../firebase_options.dart';

class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Stream<QuerySnapshot> streamUser() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'user')
        .snapshots();
  }

  static Future<String> createUser(String email, String password, String name,
      String role, String phone) async {
    try {
      final secondaryApp = await _repCreationApp();
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      UserCredential userCredential = await secondaryAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'displayName': name,
        'email': email,
        'longitude': null,
        'latitude': null,
        'role': role,
        'uid': userCredential.user!.uid,
        'phone': phone,
        'locationTrackingActive': false,
        'workDayStatus': 'not_started',
      });
      await secondaryAuth.signOut();
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An unknown error occurred.";
    } catch (e) {
      return "An unknown error occurred.";
    }
  }

  static Future<String> deleteRepRecord(String uid) async {
    try {
      if (uid.isEmpty) {
        return 'Rep id is missing.';
      }
      await _firestore.collection('employee_locations').doc(uid).delete();
      await _deleteCollection(
        _firestore
            .collection('employee_location_history')
            .doc(uid)
            .collection('points'),
      );
      await _deleteCollection(
        _firestore.collection('users').doc(uid).collection('work_sessions'),
      );
      await _firestore.collection('users').doc(uid).delete();
      return 'Success';
    } catch (_) {
      return 'Could not delete rep record.';
    }
  }

  static Future<FirebaseApp> _repCreationApp() async {
    const appName = 'repCreation';
    try {
      return Firebase.app(appName);
    } on FirebaseException {
      return Firebase.initializeApp(
        name: appName,
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }

  static Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    const pageSize = 100;
    while (true) {
      final snapshot = await collection.limit(pageSize).get();
      if (snapshot.docs.isEmpty) {
        return;
      }
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  static Future<dynamic> userCreatedDialog() {
    return showDialog(
        context: navigatorKey.currentContext!,
        builder: ((context) {
          return Builder(builder: (context) {
            return Center(
                child: AlertDialog(
              title: const Text('Success'),
              content: const Text('New User Created Successfully!'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'))
              ],
            ));
          });
        }));
  }
}
