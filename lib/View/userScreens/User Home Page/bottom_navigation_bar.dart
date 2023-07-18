
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:workmanager/workmanager.dart';

import '../../../components/constants.dart';
import '../../../splash_page.dart';
import '../User Profile Page/user_profile_page.dart';
import '../login_page.dart';
class HomeNavigationBar extends StatelessWidget {
  const HomeNavigationBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
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
    );
  }
}
