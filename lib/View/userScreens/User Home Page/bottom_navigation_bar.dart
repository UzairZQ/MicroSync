import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:workmanager/workmanager.dart';

import '../../../components/constants.dart';
import '../../../services/location_services.dart';
import '../../../splash_page.dart';
import '../User Profile Page/user_profile_page.dart';
import '../../LoginPage/login_page.dart';

class HomeNavigationBar extends StatelessWidget {
  const HomeNavigationBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      backgroundColor: Theme.of(context).cardColor,
      onDestinationSelected: (int index) {
        switch (index) {
          case 0:
            ThemeProvider.controllerOf(context).nextTheme();
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserProfilePage(),
              ),
            );
            break;
          case 2:
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Do you really want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (uid != null && uid.isNotEmpty) {
                          await LocationServices().endWorkDayTracking(uid);
                        }
                        FirebaseAuth.instance.signOut();
                        if (Platform.isAndroid) {
                          Workmanager().cancelByTag('location');
                        } else {
                          Workmanager().cancelAll();
                        }

                        final sharedLogin =
                            await SharedPreferences.getInstance();
                        await sharedLogin.setBool(
                          SplashPageState.loginKey,
                          false,
                        );

                        final sharedUser =
                            await SharedPreferences.getInstance();
                        await sharedUser.setBool(
                          SplashPageState.userKey,
                          false,
                        );

                        Navigator.pushNamedAndRemoveUntil(
                          navigatorKey.currentContext!,
                          LoginPage.id,
                          (route) => false,
                        );
                      },
                      child: const Text('Logout'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ],
                );
              },
            );
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          label: 'Theme',
          icon: Icon(Icons.color_lens_outlined),
          selectedIcon: Icon(Icons.color_lens),
        ),
        NavigationDestination(
          label: 'Profile',
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
        ),
        NavigationDestination(
          label: 'Logout',
          icon: Icon(Icons.logout_outlined),
          selectedIcon: Icon(Icons.logout),
        ),
      ],
    );
  }
}
