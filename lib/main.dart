import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/screens/dashboard.dart';
import 'screens/login_page.dart';
import 'screens/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MicroPharma());
}

class MicroPharma extends StatelessWidget {
  const MicroPharma({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        'login': (context) => LoginPage(),
        'home': (context) => HomePage(),
        'dashboard': (context) => Dashboard()
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomePage();
          } else {
            return LoginPage();
          }
        },
      ),
    );
  }
}
