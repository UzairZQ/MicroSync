import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:micro_pharma/components/containerRow.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/screens/login_page.dart';

class AdminPage extends StatelessWidget {
  static String id = 'admin';
  const AdminPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    print(currentUser!.email);
    return Scaffold(
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
                    Text(
                      'Welcome Admin !',
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
                    SizedBox(
                      height: 15.0,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              containerRow(
                container1Clr: Color(0xFFF0DCFF),
                container1Icon: Icons.place_outlined,
                container1Text: 'Live Tracking',
                container1Tap: () => {},
                container2Clr: Color(0xFFFFC8C8),
                container2Icon: Icons.calendar_month_outlined,
                container2Text: 'Daily Call Reports',
                container2Tap: () => null,
              ),
              SizedBox(
                height: 30.0,
              ),
              containerRow(
                container1Clr: Color.fromARGB(255, 133, 254, 226),
                container1Icon: Icons.assignment_outlined,
                container1Text: 'Orders',
                container1Tap: () => null,
                container2Clr: Color(0xffFFE974),
                container2Icon: Icons.assignment_turned_in_outlined,
                container2Text: 'Call Plans',
                container2Tap: () => null,
              ),
              SizedBox(
                height: 30.0,
              ),
              containerRow(
                container1Clr: Colors.blue.shade200,
                container1Icon: Icons.medical_services_outlined,
                container1Text: 'Doctors, Areas & Chemists',
                container2Clr: Colors.orange.shade200,
                container2Icon: Icons.settings_outlined,
                container2Text: 'Employees',
                container1Tap: () => null,
                container2Tap: () => null,
              ),
              SizedBox(
                height: 20.0,
              ),
              kbuttonstyle(
                  color: kappbarColor,
                  text: 'Logout',
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushNamed(context, LoginPage.id);
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
