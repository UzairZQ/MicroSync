import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import '../screens/homepage.dart';

Color kappbarColor = Color(0xff1FB7CC);

class kbuttonstyle extends StatelessWidget {
  kbuttonstyle(
      {required this.color, required this.text, required this.onPressed});
  Color color = Color(0xFFFFB800);
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
          primary: color,
          elevation: 6.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
      ),
    );
  }
}

class myAppBar extends StatelessWidget implements PreferredSizeWidget {
  myAppBar({required this.appBartxt});
  String appBartxt;

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(60.0);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: kappbarColor,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
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
