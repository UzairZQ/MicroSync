import 'package:flutter/material.dart';

import 'my_container.dart';

class ContainerRow extends StatelessWidget {
  final Color container1Clr;
  final Color container2Clr;
  final IconData container1Icon;
  final IconData container2Icon;
  final String container1Text;
  final String container2Text;
  final Function() container1Tap;
  final Function() container2Tap;
  const ContainerRow(
      {super.key,
      required this.container1Clr,
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
      mainAxisAlignment:MainAxisAlignment.center,
      children: [
        MyContainer(
          containerclr: container1Clr,
          containerIcon: container1Icon,
          containerText: container1Text,
          onTap: container1Tap,
        ),
        const SizedBox(
          width: 50.0,
        ),
        MyContainer(
          containerclr: container2Clr,
          containerIcon: container2Icon,
          containerText: container2Text,
          onTap: container2Tap,
        ),
      ],
    );
  }
}
