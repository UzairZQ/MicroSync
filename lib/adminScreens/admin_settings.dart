import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';

class AdminSettings extends StatelessWidget {
  const AdminSettings({Key? key}) : super(key: key);
  static String id = 'adminsettings';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(appBartxt: 'Admin Settings'),
    );
  }
}
