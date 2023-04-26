import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/userScreens/login_page.dart';

import '../components/constants.dart';

class DatabaseService {
  DatabaseService();
  late String currentUser;

  static Stream<QuerySnapshot> streamUser() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'user')
        .snapshots();
  }

  String setUser(String id) {
    currentUser = id;
    return currentUser;
  }

  static Future<void> addProduct({
    required String name,
    required String code,
    required double mrp,
    required double trp,
    required String packing,
  }) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState;
      try {
        showDialog(
            context: navigatorKey.currentContext!,
            builder: ((context) {
              return Builder(builder: (context) {
                return const Center(child: CircularProgressIndicator());
              });
            }));
        await FirebaseFirestore.instance.collection('products').add({
          'name': name,
          'code': code,
          'mrp': mrp,
          'trp': trp,
          'packing': packing,
        });
        Navigator.pop(navigatorKey.currentContext!);

        showCustomDialog(
            context: navigatorKey.currentContext!,
            title: const MyTextwidget(fontSize: 17.5, text: 'Success'),
            content:
                const MyTextwidget(fontSize: 14, text: 'Product added successfully'));
        print('product added to database');
      } on FirebaseException catch (e) {
        print('Error in the add product function $e');
        showCustomDialog(
            context: navigatorKey.currentContext!,
            title: const MyTextwidget(fontSize: 17.5, text: 'Failure'),
            content: const MyTextwidget(
                fontSize: 14, text: 'An Error Occurred, Please Try again'));
      }
    }
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
        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
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

  static Future<void> addAreatoDatabase(String areaName, String code) async {
    int areaCode = int.parse(code);
    try {
      await FirebaseFirestore.instance
          .collection('areas')
          .add({'id': areaCode, 'name': areaName});
      print('Added to database');
    } catch (e) {
      print('This is the error $e');
    }
  }

  static Future<void> addDoctor(
      String docname, String docarea, String address, String special) async {
    try {
      await FirebaseFirestore.instance.collection('doctors').add({
        'address': address,
        'area': docarea,
        'name': docname,
        'speciality': special,
      });
      print('Added to database');
      showCustomDialog(
          context: navigatorKey.currentContext!,
          title: const MyTextwidget(fontSize: 17.5, text: 'Success'),
          content:const MyTextwidget(fontSize: 14, text: 'Doctor Added to Database'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(navigatorKey.currentContext!);
                },
                child: const Text('Okay'))
          ]);
    } catch (a) {
      showCustomDialog(
          context: navigatorKey.currentContext!,
          title:const MyTextwidget(fontSize: 17.5, text: 'Failure'),
          content:const MyTextwidget(fontSize: 14, text: 'An error occured'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(navigatorKey.currentContext!);
                },
                child: const Text('Okay'))
          ]);
      print('This is the error $a');
    }
  }
}
