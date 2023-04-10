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
        '$appBartxt',
        style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold),
      ),
    );
  }
}

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
