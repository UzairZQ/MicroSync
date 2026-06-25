import 'dart:async';
import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
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
import 'package:micro_pharma/components/theme.dart';
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
  DartPluginRegistrant.ensureInitialized();

  Workmanager().executeTask((taskName, inputData) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    final preferences = await SharedPreferences.getInstance();
    final String? userId =
        inputData?['uid']?.toString() ?? preferences.getString('userId');
    if (userId != null && userId.isNotEmpty) {
      await LocationServices().getBackgroundLocation(userId);
    }

    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
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
          create: (_) => OrderDataProvider()),
      ChangeNotifierProvider<LocationServices>(
        create: (_) => LocationServices(),
      ),
    ],
    child: const MicroPharma(),
  ));
  await Workmanager().initialize(callBackDispatcher);
}

class MicroPharma extends StatelessWidget {
  const MicroPharma({super.key});
  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      onThemeChanged: (oldTheme, newTheme) {},
      themes: [
        AppTheme(
          id: "light_theme",
          description: "Light Theme",
          data: AppThemes.lightTheme,
        ),
        AppTheme(
          id: "dark_theme",
          description: "Dark Theme",
          data: AppThemes.darkTheme,
        ),
      ],
      saveThemesOnChange: true,
      child: ThemeConsumer(
        child: Builder(
          builder: (themeContext) => MaterialApp(
            theme: ThemeProvider.themeOf(themeContext).data,
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            routes: {
              LoginPage.id: (context) => const LoginPage(),
              HomePage.id: (context) => const HomePage(),
              Dashboard.id: (context) => const Dashboard(),
              AdminPage.id: (context) => const AdminPage(),
              DayPlansScreen.id: (context) => const DayPlansScreen(),
              CallPlansForAdmin.id: (context) => const CallPlansForAdmin(),
              AddProduct.id: (context) => const AddProduct(),
              CallPlanner.id: (context) => const CallPlanner(),
              AdminPanel.id: (context) => const AdminPanel(),
              DailyCallReportScreen.id: (context) =>
                  const DailyCallReportScreen(),
              UserProfilePage.id: (context) => const UserProfilePage(),
              AdminProfilePage.id: (context) => const AdminProfilePage(),
              LocationScreen.id: (context) => const LocationScreen(),
              AddEmployees.id: (context) => const AddEmployees(),
              SubmittedOrders.id: (context) => const SubmittedOrders(),
              ViewDCRScreen.id: (context) => const ViewDCRScreen(),
            },
            home: const SplashPage(),
          ),
        ),
      ),
    );
  }
}
