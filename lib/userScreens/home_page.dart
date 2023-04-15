import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:micro_pharma/adminScreens/doctors_page.dart';
import 'package:micro_pharma/components/container_Row.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/models/user_model.dart';
import 'package:micro_pharma/providers/user_data_provider.dart';
import 'package:micro_pharma/services/location_services.dart';
import 'package:micro_pharma/userScreens/product_order.dart';
import 'dailycall_report.dart';
import 'package:micro_pharma/userScreens/user_dashboard.dart';
import 'package:micro_pharma/userScreens/day_plan.dart';
import 'package:micro_pharma/userScreens/login_page.dart';
import 'package:micro_pharma/userScreens/user_profile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'package:workmanager/workmanager.dart';
import 'call_plans.dart';

class HomePage extends StatefulWidget {
  static String id = 'home';
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    userLocation();
    getBackgroundLocation();
    Provider.of<UserDataProvider>(context, listen: false).logIn();
    Provider.of<UserDataProvider>(context, listen: false)
        .fetchUserData(currentUser!.uid);
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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.logout_outlined),
        onPressed: () {
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
                            Provider.of<UserDataProvider>(context,
                                    listen: false)
                                .logOut();

                            FirebaseAuth.instance.signOut();
                            // Provider.of<UserDataProvider>(
                            //   context,
                            //   listen: false,
                            // ).dispose();
                            Workmanager().cancelByTag('location');
                            var sharedLogin =
                                await SharedPreferences.getInstance();
                            sharedLogin.setBool(
                                SplashPageState.loginKey, false);
                            var sharedUser =
                                await SharedPreferences.getInstance();
                            sharedUser.setBool(SplashPageState.userKey, false);
                            Navigator.pushReplacement(
                              navigatorKey.currentContext!,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
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
        },
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
                        // dataProvider.fetchUserData(currentUser!.uid);
                        UserModel? userData = dataProvider.getUserData;
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
                      children: const [
                        Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                        ),
                        Flexible(
                          child: Text(
                            'Today\'s Scheduled Plan: Abbottabad to Mansehra',
                            style: TextStyle(
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
                      children: const [
                        Icon(
                          Icons.medication_rounded,
                          color: Colors.white,
                        ),
                        Text(
                          'Doctors: 8',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        Icon(
                          Icons.medical_services_rounded,
                          color: Colors.white,
                        ),
                        Text(
                          'Chemists:5',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
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
                            onPressed: () {},
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
                  container2Text: 'Weekly Call Planner',
                  container2Tap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => WeeklyCallPlanner())));
                  }),
              const SizedBox(
                height: 30.0,
              ),
              ContainerRow(
                container1Clr: const Color.fromARGB(255, 133, 254, 226),
                container1Icon: Icons.assignment_outlined,
                container1Text: 'Day Plan',
                container1Tap: () => Navigator.pushNamed(context, DayPlan.id),
                container2Clr: const Color(0xffFFE974),
                container2Icon: Icons.assignment_turned_in_outlined,
                container2Text: 'Daily Call Reports',
                container2Tap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) => DailyCallReports()))),
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
                container2Text: 'Orders',
                container1Tap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: ((context) => const DoctorsPage()),
                  ),
                ),
                container2Tap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: ((context) => const ProductOrder()),
                  ),
                ),
              ),
              const SizedBox(
                height: 30.0,
              ),
              MyButton(
                  color: kappbarColor,
                  text: 'Settings',
                  onPressed: () {
                    Navigator.pushNamed(context, UserProfilePage.id);
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
