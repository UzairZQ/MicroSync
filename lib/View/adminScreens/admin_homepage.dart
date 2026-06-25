import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/View/adminScreens/add_employees.dart';
import 'package:micro_pharma/View/adminScreens/admin_settings.dart';
import 'package:micro_pharma/View/adminScreens/admin_panel/admin_panel.dart';
import 'package:micro_pharma/View/adminScreens/view_dcr.dart';
import 'package:micro_pharma/View/adminScreens/location_screen.dart';
import 'package:micro_pharma/View/adminScreens/submitted_orders.dart';
import 'package:micro_pharma/components/widgets/production_widgets.dart';
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
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      Provider.of<UserDataProvider>(context, listen: false)
          .fetchUserData(currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
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
        destinations: const [
          NavigationDestination(
            label: 'Change Theme',
            icon: Icon(
              Icons.color_lens,
            ),
          ),
          NavigationDestination(
            label: 'My Profile',
            icon: Icon(
              Icons.person_outlined,
            ),
          ),
          NavigationDestination(
            label: 'Logout',
            icon: Icon(
              Icons.logout_outlined,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 380 ? 14.0 : 18.0;
            return RefreshIndicator(
              onRefresh: () async {
                if (currentUser != null) {
                  await context
                      .read<UserDataProvider>()
                      .fetchUserData(currentUser!.uid);
                }
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  Consumer<UserDataProvider>(
                    builder: (context, dataProvider, child) {
                      final UserModel userData = dataProvider.getUserData;
                      return DashboardHeader(
                        icon: Icons.local_pharmacy_outlined,
                        title: (userData.displayName ?? '').isEmpty
                            ? 'Micropharma Control'
                            : 'Welcome, ${userData.displayName}',
                        subtitle:
                            'Track representatives, field reports, orders, doctors, medicines, and assignments.',
                        edgeToEdgeTop: true,
                      );
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      16,
                      horizontalPadding,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(title: 'Command Center'),
                        const SizedBox(height: 12),
                        ActionTile(
                          title: 'Live Tracking',
                          subtitle:
                              'View latest representative locations on maps.',
                          icon: Icons.map_outlined,
                          accent: const Color(0xFF0F766E),
                          onTap: () =>
                              Navigator.pushNamed(context, LocationScreen.id),
                        ),
                        const SizedBox(height: 10),
                        ActionTile(
                          title: 'Daily Call Reports',
                          subtitle:
                              'Review submitted doctor visits and field notes.',
                          icon: Icons.assignment_turned_in_outlined,
                          accent: const Color(0xFF7C3AED),
                          onTap: () =>
                              Navigator.pushNamed(context, ViewDCRScreen.id),
                        ),
                        const SizedBox(height: 10),
                        ActionTile(
                          title: 'Orders',
                          subtitle: 'Check submitted medicine order units.',
                          icon: Icons.receipt_long_outlined,
                          accent: const Color(0xFFEA580C),
                          onTap: () =>
                              Navigator.pushNamed(context, SubmittedOrders.id),
                        ),
                        const SizedBox(height: 10),
                        ActionTile(
                          title: 'Call Plans',
                          subtitle: 'Monitor planned routes and visits.',
                          icon: Icons.route_outlined,
                          accent: const Color(0xFF0891B2),
                          onTap: () => Navigator.pushNamed(
                              context, CallPlansForAdmin.id),
                        ),
                        const SizedBox(height: 22),
                        const SectionTitle(title: 'Administration'),
                        const SizedBox(height: 12),
                        ContainerRow(
                          children: [
                            MyContainer(
                              containerclr: const Color(0xFFC8EDE6),
                              containerIcon:
                                  Icons.settings_applications_outlined,
                              containerText: 'Admin Panel',
                              onTap: () =>
                                  Navigator.pushNamed(context, AdminPanel.id),
                            ),
                            MyContainer(
                              containerclr: const Color(0xFFFFD8B5),
                              containerIcon: Icons.person_add_alt_1_outlined,
                              containerText: 'Employees',
                              onTap: () =>
                                  Navigator.pushNamed(context, AddEmployees.id),
                            ),
                          ],
                        ),
                      ],
                    ),
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
