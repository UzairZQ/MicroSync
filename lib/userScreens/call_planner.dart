import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';

class CallPlanner extends StatelessWidget {
  const CallPlanner({Key? key}) : super(key: key);
  static String id = 'callplanner';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(appBartxt: 'Call Planner'),
    );
  }
}
