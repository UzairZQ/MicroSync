import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/constants.dart';

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
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'displayName': name,
        'email': email,
        'longitude': 43,
        'latitude': 73,
        'role': role,
        'uid': userCredential.user!.uid,
        'phone': phone
      });
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An unknown error occurred.";
    } catch (e) {
      return "An unknown error occurred.";
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
