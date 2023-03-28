import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';

class DailyCallReport extends StatelessWidget {
  const DailyCallReport({Key? key}) : super(key: key);
  static String id = 'dailycallreport';

  @override
  Widget build(BuildContext context) {
    return const  Scaffold(
      appBar: MyAppBar(appBartxt: 'Daily Call Report'),
    );
  }
}
