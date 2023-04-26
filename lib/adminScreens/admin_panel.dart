import 'package:flutter/material.dart';
import 'package:micro_pharma/adminScreens/products_page.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/components/container_row.dart';
import 'package:micro_pharma/adminScreens/doctors_page.dart';
import 'areas_page.dart';

class AdminPanel extends StatelessWidget {
  static String id = 'doctors_areas';
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const MyAppBar(appBartxt: 'Admin Panel'),
        body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContainerRow(
                  container1Clr: const Color.fromARGB(255, 114, 191, 254),
                  container2Clr: const Color.fromARGB(255, 114, 191, 254),
                  container1Icon: Icons.person_outline_outlined,
                  container2Icon: Icons.location_pin,
                  container1Text: 'Doctors',
                  container2Text: 'Areas',
                  container1Tap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) =>  DoctorsPage())));
                  },
                  container2Tap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) =>  Areas())));
                  },
                ),
                const SizedBox(
                  height: 20.0,
                ),
                ContainerRow(
                  container1Clr: kappbarColor,
                  container2Clr: kappbarColor,
                  container1Icon: Icons.production_quantity_limits_outlined,
                  container2Icon: Icons.abc,
                  container1Text: 'Products',
                  container2Text: 'Nothing',
                  container1Tap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => ProductCatalogPage())));
                  },
                  container2Tap: () {},
                ),
              ],
            )));
  }
}
