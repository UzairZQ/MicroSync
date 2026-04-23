import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/View/adminScreens/admin_settings.dart';
import 'package:micro_pharma/View/adminScreens/admin_panel/admin_panel.dart';
import 'package:micro_pharma/View/adminScreens/view_dcr.dart';
import 'package:micro_pharma/View/adminScreens/location_screen.dart';
import 'package:micro_pharma/View/adminScreens/submitted_orders.dart';
import 'package:micro_pharma/components/widgets/my_container.dart';
import 'package:micro_pharma/components/widgets/container_row.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/viewModel/user_data_provider.dart';
import 'package:micro_pharma/View/LoginPage/login_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_provider/theme_provider.dart';
import '../../models/user_model.dart';
import '../../splash_page.dart';
import './user_call_plans.dart';

class AdminPage extends StatefulWidget {
  static const String id = 'admin';
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    Provider.of<UserDataProvider>(context, listen: false)
        .fetchUserData(currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
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
                    builder: (context) => const AdminProfilePage()),
              );
              break;
            case 2:
              _showLogoutDialog(context);
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Column(
            children: [
              Container(
                height: constraints.maxHeight * 0.3, // 30% of screen height
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
                        //dataProvider.fetchUserData(currentUser!.uid);
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
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                        ),
                        Text(
                          'Employees on Work:',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
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
              ContainerRow(
                children: [
                  MyContainer(
                    containerclr: const Color(0xFFF0DCFF),
                    containerIcon: Icons.place_outlined,
                    containerText: 'Live Tracking',
                    onTap: () =>
                        {Navigator.pushNamed(context, LocationScreen.id)},
                  ),
                  MyContainer(
                    containerclr: const Color(0xFFFFC8C8),
                    containerIcon: Icons.calendar_month_outlined,
                    containerText: 'Daily Call Report',
                    onTap: () {
                      Navigator.pushNamed(context, ViewDCRScreen.id);
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 30.0,
              ),
              ContainerRow(
                children: [
                  MyContainer(
                    containerclr: const Color.fromARGB(255, 133, 254, 226),
                    containerIcon: Icons.assignment_outlined,
                    containerText: 'Orders',
                    onTap: () {
                      Navigator.pushNamed(context, SubmittedOrders.id);
                    },
                  ),
                  MyContainer(
                    containerclr: const Color(0xffFFE974),
                    containerIcon: Icons.assignment_turned_in_outlined,
                    containerText: 'Call Plans',
                    onTap: () {
                      Navigator.pushNamed(context, CallPlansForAdmin.id);
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 30.0,
              ),
              ContainerRow(
                children: [
                  MyContainer(
                    containerclr: Colors.blue.shade200,
                    containerIcon: Icons.settings_applications_outlined,
                    containerText: 'Admin Panel ',
                    onTap: () {
                      Navigator.pushNamed(context, AdminPanel.id);
                    },
                  ),
                  MyContainer(
                    containerclr: Colors.orange.shade200,
                    containerIcon: Icons.add_box_outlined,
                    containerText: 'Add Delete Users',
                    onTap: () {
                      Navigator.pushNamed(context, 'add_employees');
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Do you really want to Logout?'),
          actions: [
            TextButton(
              onPressed: () async {
                FirebaseAuth.instance.signOut();

                var sharedLogin = await SharedPreferences.getInstance();
                sharedLogin.setBool(SplashPageState.loginKey, false);
                var sharedUser = await SharedPreferences.getInstance();
                sharedUser.setBool(SplashPageState.userKey, false);

                Navigator.pushNamedAndRemoveUntil(
                  navigatorKey.currentContext!,
                  LoginPage.id,
                  (route) => false,
                );
              },
              child: const Text('Logout'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
