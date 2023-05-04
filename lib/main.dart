import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:micro_pharma/adminScreens/add_product.dart';
import 'package:micro_pharma/adminScreens/add_employees.dart';
import 'package:micro_pharma/adminScreens/admin_page.dart';
import 'package:micro_pharma/adminScreens/admin_panel.dart';
import 'package:micro_pharma/adminScreens/location_screen.dart';
import 'package:micro_pharma/adminScreens/user_call_plans.dart';
import 'package:micro_pharma/providers/area_provider.dart';
import 'package:micro_pharma/providers/daily_call_report_provider.dart';
import 'package:micro_pharma/providers/day_plans_provider.dart';
import 'package:micro_pharma/providers/doctor_provider.dart';
import 'package:micro_pharma/providers/product_data_provider.dart';
import 'package:micro_pharma/providers/user_data_provider.dart';
import 'package:micro_pharma/services/location_services.dart';
import 'package:micro_pharma/splash_page.dart';
import 'package:micro_pharma/userScreens/call_planner.dart';

import 'package:micro_pharma/userScreens/dailycall_report.dart';
import 'package:micro_pharma/userScreens/user_dashboard.dart';
import 'package:micro_pharma/userScreens/day_plans.dart';

import 'package:micro_pharma/userScreens/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/constants.dart';
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

final formKey = GlobalKey<FormState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<UserDataProvider>(
        create: (_) => UserDataProvider(),
      ),
      ChangeNotifierProvider<AreaProvider>(create: (_) => AreaProvider()),
      ChangeNotifierProvider<DoctorDataProvider>(
          create: (_) => DoctorDataProvider()),
      ChangeNotifierProvider<ProductDataProvider>(
          create: (_) => ProductDataProvider()),
      ChangeNotifierProvider<DayPlanProvider>(create: (_) => DayPlanProvider()),
      ChangeNotifierProvider<DailyCallReportProvider>(
          create: (_) => DailyCallReportProvider())
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
        'day_plans': (context) => const DayPlansScreen(),
        'call_plans': (context) => const CallPlansForAdmin(),
        'addproduct': (context) => const AddProduct(),
        'call_planner': (context) => const CallPlanner(),
        'addoctor': (context) => const AdminPanel(),
        'dailycallreport': (context) => DailyCallReportScreen(),
        'user_profile': (context) => const UserProfilePage(),
        'admin_profile': (context) => const AdminProfilePage(),
        'location_screen': (context) => const LocationScreen(),
        'add_employees': (context) => const AddEmployees(),
        'doctors_areas': (context) => const AdminPanel(),
      },
      home: const SplashPage(),
    );
  }
}
