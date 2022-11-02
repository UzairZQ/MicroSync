import 'package:flutter/material.dart';

class myContainer extends StatelessWidget {
  myContainer(
      {required this.containerclr,
      required this.containerIcon,
      required this.containerText,
      required this.onTap});
  Color containerclr = Color(0xFFF0DCFF);
  IconData containerIcon;
  String containerText;
  Function() onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130.0,
        width: 140.0,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade500,
              blurRadius: 7.0,
            ),
          ],
          color: containerclr,
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              containerIcon,
              size: 40.0,
            ),
            Text(
              '$containerText',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
                fontSize: 15.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
