import 'package:flutter/material.dart';
import 'myContainer.dart';

class containerRow extends StatelessWidget {
  late Color container1Clr;
  late Color container2Clr;
  IconData container1Icon;
  IconData container2Icon;
  String container1Text;
  String container2Text;
  Function() container1Tap;
  Function() container2Tap;
  containerRow(
      {required this.container1Clr,
      required this.container2Clr,
      required this.container1Icon,
      required this.container2Icon,
      required this.container1Text,
      required this.container2Text,
      required this.container1Tap,
      required this.container2Tap});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        myContainer(
          containerclr: container1Clr,
          containerIcon: container1Icon,
          containerText: container1Text,
          onTap: container1Tap,
        ),
        SizedBox(
          width: 50.0,
        ),
        myContainer(
          containerclr: container2Clr,
          containerIcon: container2Icon,
          containerText: container2Text,
          onTap: container2Tap,
        ),
      ],
    );
  }
}
