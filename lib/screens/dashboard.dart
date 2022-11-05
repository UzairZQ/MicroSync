import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';

class Dashboard extends StatelessWidget {
  static String id = 'user_dashboard';
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(appBartxt: 'Dashboard'),
    );
  }
}
