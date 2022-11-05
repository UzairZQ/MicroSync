import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/screens/login_page.dart';
import '../components/constants.dart';

class AdminPage extends StatelessWidget {
  static String id = 'admin';
  const AdminPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(
        appBartxt: 'Admin Page',
      ),
      body: Center(
        child: kbuttonstyle(
          color: Colors.purple,
          onPressed: () {
            FirebaseAuth.instance.signOut();
            Navigator.pushNamed(context, LoginPage.id);
          },
          text: 'Logout',
        ),
      ),
    );
  }
}
