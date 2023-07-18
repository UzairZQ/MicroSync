import 'dart:async';

import 'package:flutter/material.dart';
import 'package:micro_pharma/View/userScreens/User%20Home%20Page/home_page.dart';
import 'package:micro_pharma/View/userScreens/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'View/adminScreens/admin_homepage.dart';

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




/// Code for the session expiration after 10 minutes
// import 'dart:async';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:micro_pharma/userScreens/home_page.dart';
// import 'package:micro_pharma/userScreens/login_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'adminScreens/admin_page.dart';

// class SplashPage extends StatefulWidget {
//   const SplashPage({Key? key}) : super(key: key);

//   @override
//   State<SplashPage> createState() => SplashPageState();
// }

// class SplashPageState extends State<SplashPage> {
//   static const String loginKey = 'Login';
//   static const String userKey = 'User';
//   static const int sessionTimeout = 10 * 60; // 10 minutes in seconds

//   Timer? _sessionTimer;

//   @override
//   void initState() {
//     super.initState();
//     whereToGo();
//   }

//   @override
//   void dispose() {
//     _sessionTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Hero(
//           tag: 'micro-logo',
//           child: Image.asset('assets/images/micro_trans.png'),
//         ),
//       ),
//     );
//   }

//   void whereToGo() async {
//     // Function to handle session expiration
//     void handleSessionExpiration() {
//       FirebaseAuth.instance.signOut(); // Perform logout actions here
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const LoginPage(),
//         ),
//       );
//     }

//     var sharedLogin = await SharedPreferences.getInstance();
//     var sharedUser = await SharedPreferences.getInstance();

//     var isLoggedIn = sharedLogin.getBool(loginKey);
//     var isUser = sharedUser.getBool(userKey);
//     var lastActiveTimestamp = sharedLogin.getInt('lastActiveTimestamp');

//     if (isLoggedIn == null || isUser == null || lastActiveTimestamp == null) {
//       // If any required values are not set, redirect to the login page
//       handleSessionExpiration();
//       return;
//     }

//     final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//     final sessionDuration = currentTimestamp - lastActiveTimestamp;

//     if (sessionDuration >= sessionTimeout) {
//       // Session has expired
//       handleSessionExpiration();
//       return;
//     }

//     sharedLogin.setInt('lastActiveTimestamp',
//         currentTimestamp); // Update the last active timestamp

//     _sessionTimer = Timer(
//       const Duration(seconds: 1),
//       whereToGo,
//     );

//     if (isLoggedIn && isUser) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const HomePage(),
//         ),
//       );
//     } else if (isLoggedIn && !isUser) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const AdminPage(),
//         ),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const LoginPage(),
//         ),
//       );
//     }
//   }
// }
