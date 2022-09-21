import 'package:flutter/material.dart';
import 'login_page.dart';
import 'homepage.dart';

void main() {
  runApp(MicroPharma());
}

class MicroPharma extends StatelessWidget {
  const MicroPharma({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        'login': (context) => LoginPage(),
        'home':(context) => HomePage(),
      },
      home: LoginPage(),
    );
  }
}
