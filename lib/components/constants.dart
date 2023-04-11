import 'package:flutter/material.dart';

Color kappbarColor = const Color(0xff1FB7CC);

// ignore: must_be_immutable
class MyButton extends StatelessWidget {
  MyButton(
      {super.key, this.color, required this.text, required this.onPressed});
  Color? color = const Color(0xFFFFB800);
  final String text;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.0,
      width: 170.0,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 6.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key, required this.appBartxt});
  final String appBartxt;

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: kappbarColor,
      centerTitle: true,
      title: Text(
        appBartxt,
        style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold),
      ),
    );
  }
}

//I have added a comment
TextStyle ktextstyle = const TextStyle(
    fontFamily: 'Poppins,', fontSize: 17.5, fontWeight: FontWeight.w400);

class myTextwidget extends StatelessWidget {
  myTextwidget({this.fontWeight, required this.fontSize, required this.text});

  FontWeight? fontWeight;
  double fontSize;
  String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontFamily: 'Poppins', fontWeight: fontWeight, fontSize: fontSize),
    );
  }
}

String? validateEmail(String? email) {
  if (email!.isEmpty) {
    return 'Please Enter Email Address';
  } else if (!RegExp(
          r'^[a-zA-Z0-9._%+-]+@(gmail|email|yahoo|outlook|hotmail|live|aol)\.[a-zA-Z]{2,}$')
      .hasMatch(email)) {
    return ("Please enter a valid Email Address ");
  } else {
    return null;
  }
}

String? validatePassword(String? password) {
  RegExp regex = RegExp(r'^.{6,}$');
  if (password!.isEmpty) {
    return 'Please Enter Password';
  } else if (!regex.hasMatch(password)) {
    return 'Enter Password with min. 6 Characters';
  } else {
    return null;
  }
}
