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
import 'package:micro_pharma/services/database_service.dart';
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
                padding: EdgeInsets.fromLTRB(
                    horizontalPadding, 12, horizontalPadding, 24),
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
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder(
                    stream: DatabaseService.streamUser(),
                    builder: (context, AsyncSnapshot snapshot) {
                      final employeeCount = snapshot.data?.docs.length ?? 0;
                      final activeCount = snapshot.data?.docs
                              .where((doc) =>
                                  (doc.data() as Map<String, dynamic>)
                                      .containsKey('update'))
                              .length ??
                          0;

                      return LayoutBuilder(
                        builder: (context, metricConstraints) {
                          final isWide = metricConstraints.maxWidth > 620;
                          final tiles = [
                            MetricTile(
                              label: 'Field employees',
                              value: '$employeeCount',
                              icon: Icons.groups_2_outlined,
                              accent: const Color(0xFF2563EB),
                            ),
                            MetricTile(
                              label: 'Location updates',
                              value: '$activeCount',
                              icon: Icons.location_on_outlined,
                              accent: const Color(0xFF059669),
                            ),
                          ];
                          if (isWide) {
                            return Row(
                              children: [
                                Expanded(child: tiles[0]),
                                const SizedBox(width: 12),
                                Expanded(child: tiles[1]),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              tiles[0],
                              const SizedBox(height: 12),
                              tiles[1],
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  const SectionTitle(title: 'Command Center'),
                  const SizedBox(height: 12),
                  ActionTile(
                    title: 'Live Tracking',
                    subtitle: 'View latest representative locations on maps.',
                    icon: Icons.map_outlined,
                    accent: const Color(0xFF0F766E),
                    onTap: () =>
                        Navigator.pushNamed(context, LocationScreen.id),
                  ),
                  const SizedBox(height: 10),
                  ActionTile(
                    title: 'Daily Call Reports',
                    subtitle: 'Review submitted doctor visits and field notes.',
                    icon: Icons.assignment_turned_in_outlined,
                    accent: const Color(0xFF7C3AED),
                    onTap: () => Navigator.pushNamed(context, ViewDCRScreen.id),
                  ),
                  const SizedBox(height: 10),
                  ActionTile(
                    title: 'Orders',
                    subtitle: 'Check submitted medicine orders and totals.',
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
                    onTap: () =>
                        Navigator.pushNamed(context, CallPlansForAdmin.id),
                  ),
                  const SizedBox(height: 22),
                  const SectionTitle(title: 'Administration'),
                  const SizedBox(height: 12),
                  ContainerRow(
                    children: [
                      MyContainer(
                        containerclr: const Color(0xFFE0F2FE),
                        containerIcon: Icons.settings_applications_outlined,
                        containerText: 'Admin Panel',
                        onTap: () =>
                            Navigator.pushNamed(context, AdminPanel.id),
                      ),
                      MyContainer(
                        containerclr: const Color(0xFFFFEDD5),
                        containerIcon: Icons.person_add_alt_1_outlined,
                        containerText: 'Employees',
                        onTap: () =>
                            Navigator.pushNamed(context, AddEmployees.id),
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
