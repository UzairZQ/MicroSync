import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';

class UserSettings extends StatelessWidget {
  const UserSettings({Key? key}) : super(key: key);
  static String id = 'usersettings';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MyAppBar(appBartxt: 'Settings'),
    );
  }
}
