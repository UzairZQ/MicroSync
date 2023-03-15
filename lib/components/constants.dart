import 'package:flutter/material.dart';

Color kappbarColor = const Color(0xff1FB7CC);

class MyButton extends StatelessWidget {
  MyButton({required this.color, required this.text, required this.onPressed});
  Color color = const Color(0xFFFFB800);
  late String text;
  Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.0,
      width: 150.0,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 6.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
      ),
    );
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key,required this.appBartxt});
  final String appBartxt;

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: kappbarColor,
      centerTitle: true,
      title: Text(
        '$appBartxt',
        style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold),
      ),
    );
  }
}

TextStyle ktextstyle = const TextStyle(
    fontFamily: 'Poppins', fontSize: 17.5, fontWeight: FontWeight.w400);

String? validateEmail(String? email) {
  if (email!.isEmpty) {
    return 'Please Enter Email Adress';
  } else if (!RegExp(
          r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$')
      .hasMatch(email)) {
    return ("Please enter a valid email");
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
