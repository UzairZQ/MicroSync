import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/screens/admin_page.dart';
import 'package:micro_pharma/screens/dashboard.dart';
import 'screens/login_page.dart';
import 'screens/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './screens/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MicroPharma());
}

class MicroPharma extends StatelessWidget {
  
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(routes: {
      'login': (context) => LoginPage(),
      'home': (context) => HomePage(),
      'user_dashboard': (context) => Dashboard(),
      'admin': (context) => AdminPage()
    }, home: LoginPage());
  }
}

// StreamBuilder<User?>(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Container(
//               alignment: Alignment.center,
//               child: const CircularProgressIndicator(
//                   backgroundColor: Colors.white, color: Colors.blue),
//             );
//           } else if (snapshot.hasError) {
//             return Text('Something went wrong');
//           } else if (snapshot.hasData && snapshot.data != null) {
//             return StreamBuilder(
//               stream: FirebaseFirestore.instance
//                   .collection("users")
//                   .doc(user!.uid)
//                   .snapshots(),
//               builder: ((BuildContext context,
//                   AsyncSnapshot<DocumentSnapshot> snapshot) {
//                 if (snapshot.hasData && snapshot.data != null) {
//                   final role = snapshot.data;
//                   if (role!['role'] == "admin") {
//                     return AdminPage();
//                   } else if (role['role'] == "user") {
//                     return HomePage();
//                   }
//                 }
//                 return Material(
//                   child: Center(
//                     child: CircularProgressIndicator(),
//                   ),
//                 );
//               }),
//             );
//           } else {
          
//             return LoginPage();
//           }
//         },
//       ),