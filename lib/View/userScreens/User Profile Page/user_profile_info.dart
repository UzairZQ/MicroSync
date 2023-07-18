import 'package:flutter/material.dart';
import 'package:micro_pharma/View/userScreens/User%20Profile%20Page/user_assigned_areas&products.dart';

import '../../../components/constants.dart';
import '../../../models/user_model.dart';


class UserInfo extends StatelessWidget {
  const UserInfo({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Card(
              color: Colors.teal[100],
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: MyTextwidget(
                  text: user.displayName ?? '',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Card(
              color: Colors.amber[100],
              elevation: 3.0,
              child: MyTextwidget(
                text: user.email ?? '',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Card(
              color: Colors.blue[100],
              child: MyTextwidget(
                text: user.phone ?? '',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            MyTextwidget(
              text: 'My Assigned Areas',
              fontSize: 20,
            ),
            UserAssignedAreas(user: user),
            const SizedBox(height: 20),
            MyTextwidget(
              text: 'My Assigned Products',
              fontSize: 20,
            ),
            const SizedBox(height: 10),
            UserAssignedProducts(user: user),
          ],
        ),
      ),
    );
  }
}
