import 'package:flutter/material.dart';

import '../../../components/constants.dart';
import '../../../models/user_model.dart';

class UserAssignedProducts extends StatelessWidget {
  const UserAssignedProducts({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.7),
      itemCount: user.assignedProducts!.length,
      itemBuilder: (context, index) {
        final product = user.assignedProducts![index];
        return Material(
          borderRadius: BorderRadius.circular(15),
          elevation: 2,
          child: Container(
            height: 15,
            width: 15,
            decoration: BoxDecoration(
              color: kappbarColor.withAlpha(100),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: MyTextwidget(text: product.name),
            ),
          ),
        );
      },
    );
  }
}

class UserAssignedAreas extends StatelessWidget {
  const UserAssignedAreas({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: user.assignedAreas?.length,
      itemBuilder: (context, index) {
        final area = user.assignedAreas?[index];
        return Card(
          color: Colors.amber[200],
          child: ListTile(
            title: MyTextwidget(text: area!.areaName),
          ),
        );
      },
    );
  }
}
