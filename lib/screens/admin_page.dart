import 'package:flutter/material.dart';
import '../components/constants.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(
        appBartxt: 'Admin Portal',
      ),
    );
  }
}
