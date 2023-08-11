import 'dart:async';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/View/adminScreens/add_employees.dart';
import 'package:micro_pharma/View/adminScreens/admin_homepage.dart';
import 'package:micro_pharma/View/adminScreens/view_dcr.dart';
import 'package:micro_pharma/View/adminScreens/location_screen.dart';
import 'package:micro_pharma/View/adminScreens/submitted_orders.dart';
import 'package:micro_pharma/View/adminScreens/user_call_plans.dart';
import 'package:micro_pharma/viewModel/area_provider.dart';
import 'package:micro_pharma/viewModel/daily_call_report_provider.dart';
import 'package:micro_pharma/viewModel/day_plans_provider.dart';
import 'package:micro_pharma/viewModel/doctor_provider.dart';
import 'package:micro_pharma/viewModel/order_data_provider.dart';
import 'package:micro_pharma/viewModel/product_data_provider.dart';
import 'package:micro_pharma/viewModel/user_data_provider.dart';
import 'package:micro_pharma/services/location_services.dart';
import 'package:micro_pharma/splash_page.dart';
import 'package:micro_pharma/View/userScreens/Call%20Planner%20Page/call_planner.dart';
import 'package:micro_pharma/View/userScreens/user_dashboard.dart';
import 'package:micro_pharma/View/userScreens/day_plans.dart';
import 'package:micro_pharma/View/userScreens/User%20Profile%20Page/user_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_provider/theme_provider.dart';
import 'View/adminScreens/admin_panel/add_product.dart';
import 'View/adminScreens/admin_panel/admin_panel.dart';
import 'View/userScreens/Daily Call Report Page/dailycall_report.dart';
import 'components/constants.dart';
import 'View/LoginPage/login_page.dart';
import 'View/userScreens/User Home Page/home_page.dart';
import 'package:micro_pharma/View/adminScreens/admin_settings.dart';
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
    await LocationServices().getBackgroundLocation(userId!);

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
        create: (_) => UserDataProvider(),
      ),
      ChangeNotifierProvider<AreaProvider>(create: (_) => AreaProvider()),
      ChangeNotifierProvider<DoctorDataProvider>(
          create: (_) => DoctorDataProvider()),
      ChangeNotifierProvider<ProductDataProvider>(
          create: (_) => ProductDataProvider()),
      ChangeNotifierProvider<DayPlanProvider>(create: (_) => DayPlanProvider()),
      ChangeNotifierProvider<DailyCallReportProvider>(
        create: (_) => DailyCallReportProvider(),
      ),
      ChangeNotifierProvider<OrderDataProvider>(
          create: (_) => OrderDataProvider())
    ],
    child: const MicroPharma(),
  ));
  await Workmanager().initialize(callBackDispatcher);
}

class MicroPharma extends StatelessWidget {
  const MicroPharma({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      onThemeChanged: (oldTheme, newTheme) {},
      themes: [
        AppTheme.light(),
        AppTheme.dark(),
      ],
      saveThemesOnChange: true,
      child: ThemeConsumer(
        child: Builder(
          builder: (themeContext) => MaterialApp(
            theme: ThemeProvider.themeOf(themeContext).data,
            debugShowCheckedModeBanner: false,
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
              'dailycallreport': (context) => const DailyCallReportScreen(),
              'user_profile': (context) => const UserProfilePage(),
              'admin_profile': (context) => const AdminProfilePage(),
              'location_screen': (context) => const LocationScreen(),
              'add_employees': (context) => const AddEmployees(),
              'doctors_areas': (context) => const AdminPanel(),
              'submitted_orders': (context) => const SubmittedOrders(),
              'view_dcr': (context) => const ViewDCRScreen(),
            },
            home: const SplashPage(),
          ),
        ),
      ),
    );
  }
}
