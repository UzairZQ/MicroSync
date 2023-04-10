import 'package:flutter/material.dart';
import 'package:micro_pharma/adminScreens/addproduct.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/components/container_row.dart';

import 'package:micro_pharma/components/my_container.dart';
import 'package:micro_pharma/adminScreens/addarea.dart';
import 'package:micro_pharma/adminScreens/addoctor.dart';
import 'package:micro_pharma/adminScreens/visited%20_doctors.dart';
import 'product.dart';

class DoctorsAreas extends StatelessWidget {
  static String id = 'doctors_areas';
  const DoctorsAreas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(appBartxt: 'Doctors and Areas'),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  myContainerwithButtons(
                      containerclr: Colors.teal.shade50,
                      containerIcon: Icons.person_outlined,
                      containerText: 'Doctors',
                      txtBtn1Ontap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) =>
                                    const VisitedDoctors())));
                      },
                      txtBtn2Ontap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => const Addoctor())));
                      },
                      txtBtn1text: 'View Doctors',
                      txtBtn2text: 'Add Doctor'),
                  myContainerwithButtons(
                      containerclr: Colors.teal.shade50,
                      containerIcon: Icons.place_outlined,
                      containerText: 'Areas',
                      txtBtn1Ontap: () {},
                      txtBtn2Ontap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => const Addarea())));
                      },
                      txtBtn1text: 'View Areas',
                      txtBtn2text: 'Add Area'),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              // containerRow(
              //     container1Clr: Colors.teal.shade50,
              //     container2Clr: Colors.teal.shade50,
              //     container1Icon: Icons.shopping_cart,
              //     container2Icon: Icons.shopping_cart,
              //     container1Text: 'Prouct',
              //     container2Text: 'Prouct',
              //     container1Tap: () {},
              //     container2Tap: () {})
              myContainerwithButtons(
                  containerclr: Colors.teal.shade50,
                  containerIcon: Icons.shopping_cart,
                  containerText: 'Prouct',
                  txtBtn1Ontap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => ProductCatalogPage())));
                  },
                  txtBtn2Ontap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => AddProduct())));
                  },
                  txtBtn1text: 'Add Product',
                  txtBtn2text: 'View Produt'),
            ],
          ),
        ));
  }
}
