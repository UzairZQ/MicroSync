import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../adminScreens/admin_page.dart';
import '../components/constants.dart';
import '../splash_page.dart';
import '../userScreens/home_page.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  void route() {
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        if (documentSnapshot.get('role') == "user") {
          //if successfully loggedIn (Creds are correct)

          var sharedLogin = await SharedPreferences.getInstance();
          var sharedUser = await SharedPreferences.getInstance();

          sharedLogin.setBool(SplashPageState.loginKey, true);
          sharedUser.setBool(SplashPageState.userKey, true);

          Navigator.pushReplacement(
            navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        } else if (documentSnapshot.get('role') == "admin") {
          var sharedLogin = await SharedPreferences.getInstance();
          var sharedUser = await SharedPreferences.getInstance();
          sharedLogin.setBool(SplashPageState.loginKey, true);
          sharedUser.setBool(SplashPageState.userKey, false);
          Navigator.pushReplacement(
            navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (context) => const AdminPage(),
            ),
          );
        }
      } else {
        return;
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Please check your internet connection'),
        ),
      );
      return;
    }

    showDialog(
      context: navigatorKey.currentContext!,
      builder: (_) => const Center(child: CircularProgressIndicator()),
      barrierDismissible: true,
    );

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      route();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          const SnackBar(
            content: Text('No user found for this Email'),
          ),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          const SnackBar(
            content: Text('Please enter correct password'),
          ),
        );
      } else {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          const SnackBar(
            content: Text('Failed to sign in, please try again later'),
          ),
        );
        // print('failed to sign in, error: ${e.code}');
      }
    } on SocketException catch (_) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Please check your internet connection'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Failed to sign in, please try again later'),
        ),
      );
    } finally {
      // Dismiss the dialog if it's still showing
      Navigator.of(navigatorKey.currentContext!).pop();
    }
  }
}
