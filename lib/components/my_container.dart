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
  TextButton? button1;
  TextButton? button2;
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

class myContainerwithButtons extends StatelessWidget {
  myContainerwithButtons(
      {required this.containerclr,
      required this.containerIcon,
      required this.containerText,
      required this.txtBtn1Ontap,
      required this.txtBtn2Ontap,
      required this.txtBtn1text,
      required this.txtBtn2text});
  Color containerclr = Color(0xFFF0DCFF);
  IconData containerIcon;
  String containerText;

  Function() txtBtn1Ontap;
  Function() txtBtn2Ontap;
  String txtBtn1text;
  String txtBtn2text;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.0,
      width: 190.0,
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
            size: 35.0,
          ),
          Text(
            containerText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w300,
              fontSize: 15.0,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: txtBtn1Ontap,
                child: Text(txtBtn1text),
              ),
              TextButton(
                onPressed: txtBtn2Ontap,
                child: Text(txtBtn2text),
              )
            ],
          )
        ],
      ),
    );
  }
}
