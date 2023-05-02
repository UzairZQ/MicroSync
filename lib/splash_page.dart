



import 'dart:async';

import 'package:flutter/material.dart';
import 'package:micro_pharma/userScreens/home_page.dart';
import 'package:micro_pharma/userScreens/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'adminScreens/admin_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  static const String loginKey = 'Login';
  static const String userKey = 'User';

  @override
  void initState() {
    super.initState();
    whereToGo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Hero(
          tag: 'micro-logo',
          child: Image.asset('assets/images/micro_trans.png'),
        ),
      ),
    );
  }

  void whereToGo() async {
    //this function is for navigating either the user or admin without have to login again when the app starts up.
    var sharedLogin = await SharedPreferences.getInstance();
    var sharedUser = await SharedPreferences.getInstance();

    var isLoggedIn = sharedLogin.getBool(loginKey);
    var isUser = sharedUser.getBool(userKey);

    Timer(const Duration(seconds: 1), () {
      if (isLoggedIn != null && isUser != null) {
        if (isLoggedIn && isUser) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        } else if (isLoggedIn && isUser == false) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminPage(),
              ));
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ));
        }
      } else if (isLoggedIn == null && isUser == null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ));
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ));
      }
    });
  }
}
