import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';

class Master extends StatelessWidget {
  const Master({Key? key}) : super(key: key);
  static String id = 'master';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(appBartxt: 'Master'),
    );
  }
}
