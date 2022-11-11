import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:micro_pharma/components/containerRow.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/userScreens/daily_call_report.dart';
import 'package:micro_pharma/userScreens/dashboard.dart';
import 'package:micro_pharma/userScreens/day_plan.dart';
import 'package:micro_pharma/userScreens/login_page.dart';
import 'package:micro_pharma/userScreens/master_screen.dart';
import 'package:micro_pharma/userScreens/product_order.dart';
import 'package:micro_pharma/userScreens/userSettings.dart';

class HomePage extends StatelessWidget {
  static String id = 'home';
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    print(currentUser!.email);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FirebaseAuth.instance.signOut();
          Navigator.pushNamed(context, LoginPage.id);
        },
        child: Icon(Icons.logout_outlined),
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
                    Text(
                      'Welcome User!',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 17.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                        ),
                        Text(
                          'Today\'s Scheduled Plan: Abbottabad to Mansehra',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                    SizedBox(height: 25.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        kbuttonstyle(
                            onPressed: () => null,
                            color: Color(0xFF009AAF),
                            text: 'Start Your Day'),
                        SizedBox(
                          width: 15.0,
                        ),
                        kbuttonstyle(
                            onPressed: () => null,
                            color: Color.fromARGB(255, 171, 75, 95),
                            text: 'Change Plan'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              containerRow(
                container1Clr: Color(0xFFF0DCFF),
                container1Icon: Icons.dashboard_outlined,
                container1Text: 'Dashboard',
                container1Tap: () => Navigator.pushNamed(context, Dashboard.id),
                container2Clr: Color(0xFFFFC8C8),
                container2Icon: Icons.calendar_month_outlined,
                container2Text: 'Call Planner',
                container2Tap: () => null,
              ),
              SizedBox(
                height: 30.0,
              ),
              containerRow(
                container1Clr: Color.fromARGB(255, 133, 254, 226),
                container1Icon: Icons.assignment_outlined,
                container1Text: 'Day Plan',
                container1Tap: () => Navigator.pushNamed(context, DayPlan.id),
                container2Clr: Color(0xffFFE974),
                container2Icon: Icons.assignment_turned_in_outlined,
                container2Text: 'Daily Call Report',
                container2Tap: () =>
                    Navigator.pushNamed(context, DailyCallReport.id),
              ),
              SizedBox(
                height: 30.0,
              ),
              containerRow(
                container1Clr: Colors.blue.shade200,
                container1Icon: Icons.medical_services_outlined,
                container1Text: 'Doctors, Areas & Chemists',
                container2Clr: Colors.orange.shade200,
                container2Icon: Icons.add_shopping_cart_outlined,
                container2Text: 'Orders',
                container1Tap: () => Navigator.pushNamed(context, Master.id),
                container2Tap: () =>
                    Navigator.pushNamed(context, ProductOrder.id),
              ),
              SizedBox(
                height: 15.0,
              ),
              kbuttonstyle(
                  color: kappbarColor,
                  text: 'Settings',
                  onPressed: () {
                    Navigator.pushNamed(context, UserSettings.id);
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
