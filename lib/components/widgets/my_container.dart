import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyContainer extends StatelessWidget {
  MyContainer(
      {super.key,
      required this.containerclr,
      required this.containerIcon,
      required this.containerText,
      required this.onTap});
  Color containerclr = const Color(0xFFF0DCFF);
  IconData containerIcon;
  String containerText;
  TextButton? button1;
  TextButton? button2;
  Function() onTap;
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colorScheme = Theme.of(context).colorScheme;
    final highlightColor = brightness == Brightness.dark
        ? Colors.white.withOpacity(0.03)
        : Colors.white.withOpacity(0.55);

    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 132, minWidth: 156),
          child: Ink(
            width: 156,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
                BoxShadow(
                  color: highlightColor,
                  blurRadius: 10,
                  offset: const Offset(-2, -2),
                ),
              ],
              color: containerclr,
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      containerIcon,
                      size: 26.0,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    containerText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class ContainerwithButtons extends StatelessWidget {
  ContainerwithButtons(
      {super.key,
      required this.containerclr,
      required this.containerIcon,
      required this.containerText,
      required this.txtBtn1Ontap,
      required this.txtBtn2Ontap,
      required this.txtBtn1text,
      required this.txtBtn2text});
  Color containerclr = const Color(0xFFF0DCFF);
  IconData containerIcon;
  String containerText;

  Function() txtBtn1Ontap;
  Function() txtBtn2Ontap;
  String txtBtn1text;
  String txtBtn2text;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128.0,
      width: 187.0,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        color: containerclr,
        borderRadius: BorderRadius.circular(16.0),
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
