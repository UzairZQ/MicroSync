import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/models/day_plan_model.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:micro_pharma/components/container_Row.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/models/user_model.dart';
import 'package:micro_pharma/providers/user_data_provider.dart';
import 'package:micro_pharma/services/location_services.dart';
import 'package:micro_pharma/userScreens/order_page.dart';
import '../adminScreens/admin_panel/doctors_page.dart';
import '../providers/day_plans_provider.dart';
import '../splash_page.dart';
import 'call_planner.dart';
import 'dailycall_report.dart';
import 'package:micro_pharma/userScreens/user_dashboard.dart';
import 'package:micro_pharma/userScreens/day_plans.dart';
import 'package:micro_pharma/userScreens/login_page.dart';
import 'package:micro_pharma/userScreens/user_profile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class HomePage extends StatefulWidget {
  static String id = 'home';
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  DayPlanModel? currentDayPlan;

  @override
  void initState() {
    super.initState();
    showPrivacyConsentDialog();
    getBackgroundLocation();
    Provider.of<UserDataProvider>(context, listen: false)
        .fetchUserData(currentUser!.uid);
    Provider.of<DayPlanProvider>(context, listen: false).fetchDayPlans();
    currentDayPlan = Provider.of<DayPlanProvider>(context, listen: false)
        .getCurrentDayPlan();
  }

  Future<void> showPrivacyConsentDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasShownConsent = prefs.getBool('hasShownConsent') ?? false;

    if (!hasShownConsent) {
      await showDialog(
        context: navigatorKey.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            title: MyTextwidget(text: 'Privacy Consent'),
            content: MyTextwidget(
              text:
                  'By using this app, you consent to the collection and use of your location data for the purpose of sales force automation and tracking your work activities in the field. Your location data will be securely stored and used in accordance with our privacy policy.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  prefs.setBool('hasShownConsent', true);
                  Navigator.of(context).pop();
                  userLocation();
                },
                child: const Text('I Agree'),
              ),
            ],
          );
        },
      );
    } else {
      userLocation();
    }
  }

  void userLocation() async {
    await LocationServices().requestPermission();
    await LocationServices().getLocation(currentUser!.uid);
    SharedPreferences userId = await SharedPreferences.getInstance();
    userId.setString('userId', currentUser!.uid.toString());
  }

  void getBackgroundLocation() async {
    const task = 'provideBGLoc';
    Map<String, dynamic> uid = {'uid': currentUser!.uid};
    Workmanager().registerPeriodicTask('locationTask', task,
        backoffPolicy: BackoffPolicy.linear,
        frequency: const Duration(minutes: 15),
        initialDelay: const Duration(minutes: 5),
        tag: 'location',
        inputData: uid,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ));
  }

  @override
  Widget build(BuildContext context) {
    userLocation();
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: kappbarColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        onTap: (int index) {
          switch (index) {
            case 0:
              ThemeProvider.controllerOf(context).nextTheme();

              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserProfilePage()),
              );
              break;
            case 2:
              showDialog(
                  context: context,
                  builder: (context) {
                    return Center(
                      child: AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Do you really want to Logout?'),
                        actions: [
                          TextButton(
                              onPressed: () async {
                                FirebaseAuth.instance.signOut();

                                Workmanager().cancelByTag('location');
                                var sharedLogin =
                                    await SharedPreferences.getInstance();
                                sharedLogin.setBool(
                                    SplashPageState.loginKey, false);
                                var sharedUser =
                                    await SharedPreferences.getInstance();
                                sharedUser.setBool(
                                    SplashPageState.userKey, false);
                                Navigator.pushNamedAndRemoveUntil(
                                  navigatorKey.currentContext!,
                                  LoginPage.id,
                                  (route) => false,
                                );
                              },
                              child: const Text('Logout')),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'))
                        ],
                      ),
                    );
                  });

              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            label: 'Change Theme',
            icon: Icon(
              Icons.color_lens,
              size: 30,
            ),
          ),
          BottomNavigationBarItem(
            label: 'My Profile',
            icon: Icon(
              Icons.person_outlined,
              size: 30,
            ),
          ),
          BottomNavigationBarItem(
            label: 'Logout',
            icon: Icon(
              Icons.logout_outlined,
              size: 30,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 250.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Color(0xFF1FB7CC),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40.0),
                    bottomRight: Radius.circular(40.0),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Consumer<UserDataProvider>(
                      builder: (context, dataProvider, child) {
                        UserModel? userData = dataProvider.getUserData;
                        print(userData.displayName);

                        if (userData.displayName == null ||
                            userData.displayName!.isEmpty) {
                          return const CircularProgressIndicator();
                        } else {
                          return Text(
                            'Welcome ${userData.displayName} !',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.white,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 17.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                        ),
                        Expanded(
                          child: Text(
                            'Today\'s Scheduled Plan: Abbottabad to ${currentDayPlan?.area}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.medication_rounded,
                          color: Colors.white,
                        ),
                        Text(
                          'Doctors: ${currentDayPlan?.doctors.length}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyButton(
                            onPressed: () {},
                            color: const Color(0xFF009AAF),
                            text: 'Start Your Day'),
                        const SizedBox(
                          width: 15.0,
                        ),
                        MyButton(
                            onPressed: () {
                              Navigator.pushNamed(context, DayPlansScreen.id);
                            },
                            color: const Color.fromARGB(255, 171, 75, 95),
                            text: 'Change Plan'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              ContainerRow(
                  container1Clr: const Color(0xFFF0DCFF),
                  container1Icon: Icons.dashboard_outlined,
                  container1Text: 'Dashboard',
                  container1Tap: () =>
                      Navigator.pushNamed(context, Dashboard.id),
                  container2Clr: const Color(0xFFFFC8C8),
                  container2Icon: Icons.calendar_month_outlined,
                  container2Text: 'Call Planner',
                  container2Tap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => const CallPlanner())));
                  }),
              const SizedBox(
                height: 30.0,
              ),
              ContainerRow(
                container1Clr: const Color.fromARGB(255, 133, 254, 226),
                container1Icon: Icons.assignment_outlined,
                container1Text: 'My Call Plans',
                container1Tap: () =>
                    Navigator.pushNamed(context, DayPlansScreen.id),
                container2Clr: const Color(0xffFFE974),
                container2Icon: Icons.assignment_turned_in_outlined,
                container2Text: 'Daily Call Reports',
                container2Tap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) => const DailyCallReportScreen()))),
              ),
              const SizedBox(
                height: 30.0,
              ),
              ContainerRow(
                container1Clr: Colors.blue.shade200,
                container1Icon: Icons.medical_services_outlined,
                container1Text: 'Doctors',
                container2Clr: Colors.orange.shade200,
                container2Icon: Icons.add_shopping_cart_outlined,
                container2Text: 'Send Orders',
                container1Tap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: ((context) => const DoctorsPage()),
                  ),
                ),
                container2Tap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: ((context) => OrderScreen()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
