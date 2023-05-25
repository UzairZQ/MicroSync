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

  

  static Future<void> createUser(String email, String password, String name,
      String role, String phone) async {
    try {
      showDialog(
          context: navigatorKey.currentContext!,
          builder: ((context) {
            return Builder(builder: (context) {
              return const Center(child: CircularProgressIndicator());
            });
          }));

      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((UserCredential userCredential) {
        _firestore.collection('users').doc(userCredential.user!.uid).set({
          'displayName': name,
          'email': email,
          'longitude': 43,
          'latitude': 73,
          'role': role,
          'uid': userCredential.user!.uid,
          'phone': phone
        });
        Navigator.pop(navigatorKey.currentContext!);
        userCreatedDialog();
      });
    } on FirebaseException catch (e) {
      showDialog(
          context: navigatorKey.currentContext!,
          builder: ((context) {
            return Builder(builder: (context) {
              return Center(
                  child: AlertDialog(
                title: const Text('Error'),
                content: Text(
                    'User creation was unsuccessfull, Please try again:::$e'),
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
