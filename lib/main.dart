import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';

import 'package:micro_pharma/adminScreens/add_employees.dart';
import 'package:micro_pharma/adminScreens/admin_page.dart';
import 'package:micro_pharma/adminScreens/doctors_areas_page.dart';
import 'package:micro_pharma/adminScreens/location_screen.dart';
import 'package:micro_pharma/providers/user_data_provider.dart';
import 'package:micro_pharma/services/location_services.dart';
import 'package:micro_pharma/userScreens/call_planner.dart';
import 'package:micro_pharma/userScreens/daily_call_report.dart';
import 'package:micro_pharma/userScreens/user_dashboard.dart';
import 'package:micro_pharma/userScreens/day_plan.dart';

import 'package:micro_pharma/userScreens/product_order.dart';
import 'package:micro_pharma/userScreens/user_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'userScreens/login_page.dart';
import 'userScreens/home_page.dart';
import 'package:micro_pharma/adminScreens/admin_settings.dart';
import 'package:workmanager/workmanager.dart';
import 'package:provider/provider.dart';

@pragma('vm:entry-point')
void callBackDispatcher() async {
  //This function is for getting the user location in the background
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized;

  Workmanager().executeTask((taskName, inputData) async {
    await Firebase.initializeApp();

    SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? userId = preferences.getString('userId');
    await LocationServices().getLocation(userId!);

    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<UserDataProvider>(
          create: (_) => UserDataProvider())
    ],
    child: const MicroPharma(),
  ));
  await Workmanager().initialize(callBackDispatcher);
}

class MicroPharma extends StatelessWidget {
  const MicroPharma({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      routes: {
        'login': (context) => const LoginPage(),
        'home': (context) => const HomePage(),
        'user_dashboard': (context) => const Dashboard(),
        'admin': (context) => const AdminPage(),
        'dayplan': (context) => const DayPlan(),
        'productorder': (context) => const ProductOrder(),
        'callplanner': (context) => const CallPlanner(),
        'dailycallreport': (context) => const DailyCallReport(),
        'usersettings': (context) => const UserSettings(),
        'adminsettings': (context) => const AdminSettings(),
        // 'map_page': (context) => GoogleMapPage(),
        'location_screen': (context) => const LocationScreen(),
        'add_employees': (context) => const AddEmployees(),
        'doctors_areas': (context) => const DoctorsAreas(),
      },
      home: const SplashPage(),
    );
  }
}

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
