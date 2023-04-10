import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:micro_pharma/adminScreens/admin_settings.dart';
import 'package:micro_pharma/adminScreens/call_plans.dart';
import 'package:micro_pharma/adminScreens/dailycall_report.dart';
import 'package:micro_pharma/adminScreens/doctors_areas_page.dart';
import 'package:micro_pharma/adminScreens/location_screen.dart';
import 'package:micro_pharma/adminScreens/order.dart';
import 'package:micro_pharma/components/container_row.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/main.dart';
import 'package:micro_pharma/userScreens/call_planner.dart';
import 'package:micro_pharma/userScreens/daily_call_report.dart';

import 'package:micro_pharma/userScreens/login_page.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'product.dart';

class AdminPage extends StatefulWidget {
  static String id = 'admin';
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    print(currentUser!.email);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
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

                              var sharedLogin =
                                  await SharedPreferences.getInstance();
                              sharedLogin.setBool(
                                  SplashPageState.KEYLOGIN, false);
                              var sharedUser =
                                  await SharedPreferences.getInstance();
                              sharedUser.setBool(
                                  SplashPageState.KEYUSER, false);

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
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
          child: const Icon(Icons.logout_outlined)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 230.0,
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
                    const Text(
                      'Welcome Admin !',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 17.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                        ),
                        Text(
                          'Employees on Work :',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              containerRow(
                container1Clr: const Color(0xFFF0DCFF),
                container1Icon: Icons.place_outlined,
                container1Text: 'Live Tracking',
                container1Tap: () =>
                    {Navigator.pushNamed(context, LocationScreen.id)},
                container2Clr: const Color(0xFFFFC8C8),
                container2Icon: Icons.calendar_month_outlined,
                container2Text: 'Daily Call Reports',
                container2Tap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => DailyCallReports())));
                },
              ),
              const SizedBox(
                height: 30.0,
              ),
              containerRow(
                container1Clr: const Color.fromARGB(255, 133, 254, 226),
                container1Icon: Icons.assignment_outlined,
                container1Text: 'Orders',
                container1Tap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: ((context) => OrderPage())));
                },
                container2Clr: const Color(0xffFFE974),
                container2Icon: Icons.assignment_turned_in_outlined,
                container2Text: 'Call Plans',
                container2Tap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: ((context) => CallPlans())));
                },
              ),
              const SizedBox(
                height: 30.0,
              ),
              containerRow(
                container1Clr: Colors.blue.shade200,
                container1Icon: Icons.medical_services_outlined,
                container1Text: 'Doctors & Areas ',
                container2Clr: Colors.orange.shade200,
                container2Icon: Icons.settings_outlined,
                container2Text: 'Add Delete Users',
                container1Tap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => const DoctorsAreas())));
                  // Navigator.pushNamed(context, 'doctors_areas_page');
                },
                container2Tap: () {
                  Navigator.pushNamed(context, 'add_employees');
                },
              ),
              const SizedBox(
                height: 30.0,
              ),
              MyButton(
                color: kappbarColor,
                text: 'Settings',
                onPressed: () {
                  Navigator.pushNamed(context, AdminSettings.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
