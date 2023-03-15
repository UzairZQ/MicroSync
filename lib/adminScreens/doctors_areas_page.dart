import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';

import 'package:micro_pharma/components/my_container.dart';

class DoctorsAreas extends StatelessWidget {
  static String id = 'doctors_areas';
  const DoctorsAreas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(appBartxt: 'Doctors and Areas'),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              myContainerwithButtons(
                  containerclr: Colors.teal.shade50,
                  containerIcon: Icons.person_outlined,
                  containerText: 'Doctors',
                  txtBtn1Ontap: () {},
                  txtBtn2Ontap: () {},
                  txtBtn1text: 'View Doctors',
                  txtBtn2text: 'Add Doctor'),
              myContainerwithButtons(
                  containerclr: Colors.teal.shade50,
                  containerIcon: Icons.place_outlined,
                  containerText: 'Areas',
                  txtBtn1Ontap: () {},
                  txtBtn2Ontap: () {},
                  txtBtn1text: 'View Areas',
                  txtBtn2text: 'Add Area'),
            ],
          ),
        ));
  }
}
