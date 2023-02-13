import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/adminScreens/GoogleMapPage.dart';
import 'package:micro_pharma/adminScreens/admin_page.dart';
import 'package:micro_pharma/adminScreens/location_screen.dart';
import 'package:micro_pharma/services/database.dart';
import 'package:micro_pharma/services/location_services.dart';
import 'package:micro_pharma/userScreens/call_planner.dart';
import 'package:micro_pharma/userScreens/daily_call_report.dart';
import 'package:micro_pharma/userScreens/user_dashboard.dart';
import 'package:micro_pharma/userScreens/day_plan.dart';
import 'package:micro_pharma/userScreens/master_screen.dart';
import 'package:micro_pharma/userScreens/product_order.dart';
import 'package:micro_pharma/userScreens/userSettings.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'userScreens/login_page.dart';
import 'userScreens/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:micro_pharma/adminScreens/adminSettings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MicroPharma()
    // MultiProvider(
    //   providers: [
    //     StreamProvider<QuerySnapshot>(initialData:,
    //       create: (_) => DataBaseService().streamUser()),
    //     FutureProvider<LocationServices>(initialData: ,
    //       create: (_) async=> LocationServices(),),
    //   ],
    //   child: MicroPharma(),
    
  );

  
}

class MicroPharma extends StatelessWidget {
  MicroPharma({Key? key}) : super(key: key);
  // String user = FirebaseAuth.instance.currentUser!.uid;
  // late var kk = FirebaseFirestore.instance
  //     .collection("users")
  //     .doc(user!.uid)
  //     .get()
  //     .then((DocumentSnapshot snapshot) {
  //   if (snapshot.exists) {
  //     snapshot.get('role') == "user";
  //     return snapshot;
  //   }
  // });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        'login': (context) => LoginPage(),
        'home': (context) => const HomePage(),
        'user_dashboard': (context) => const Dashboard(),
        'admin': (context) => const AdminPage(),
        'dayplan': (context) => const DayPlan(),
        'productorder': (context) => const ProductOrder(),
        'callplanner': (context) => const CallPlanner(),
        'master': (context) => const Master(),
        'dailycallreport': (context) => const DailyCallReport(),
        'usersettings': (context) => const UserSettings(),
        'adminsettings': (context) => const AdminSettings(),
       // 'map_page': (context) => GoogleMapPage(),
        'location_screen': (context) => const LocationScreen(),
      },
      home: SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  static const String KEYLOGIN = 'Login';
  static const String KEYUSER = 'User';

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
          child: Image.asset('assets/images/micro_trans.png'),
          tag: 'micro-logo',
        ),
      ),
    );
  }

  void whereToGo() async {
    var sharedLogin = await SharedPreferences.getInstance();
    var sharedUser = await SharedPreferences.getInstance();

    var isLoggedIn = sharedLogin.getBool(KEYLOGIN);
    var isUser = sharedUser.getBool(KEYUSER);

    Timer(const Duration(seconds: 2), () {
      if (isLoggedIn != null && isUser != null) {
        if (isLoggedIn && isUser) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        } else if (isLoggedIn && isUser == false) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AdminPage(),
              ));
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ));
        }
      } else if (isLoggedIn == null && isUser == null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ));
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ));
      }
    });
  }
}
