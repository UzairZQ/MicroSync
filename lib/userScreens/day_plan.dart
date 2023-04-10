import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';

class DayPlan extends StatelessWidget {
  const DayPlan({Key? key}) : super(key: key);
  static String id = 'dayplan';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(appBartxt: 'Day Plan'),
    );
  }
}
