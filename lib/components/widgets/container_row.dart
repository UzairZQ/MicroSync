import 'package:flutter/material.dart';



class ContainerRow extends StatelessWidget {
  final List<Widget> children;
  const ContainerRow({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20.0,
      runSpacing: 20.0,
      alignment: WrapAlignment.center,
      children: children,
    );
  }
}