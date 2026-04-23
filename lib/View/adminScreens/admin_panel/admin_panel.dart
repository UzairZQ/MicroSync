import 'package:flutter/material.dart';
import 'package:micro_pharma/View/adminScreens/admin_panel/products_page.dart';
import 'package:micro_pharma/View/adminScreens/admin_panel/show_assigned_areas_products.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/components/widgets/container_row.dart';


import 'package:micro_pharma/View/adminScreens/admin_panel/doctors_page.dart';
import 'package:micro_pharma/components/widgets/my_container.dart';
import 'areas_page.dart';
import 'assign_areas_products.dart';

class AdminPanel extends StatelessWidget {
  static const String id = 'addoctor';
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
                  children: [
                    MyContainer(
                      containerclr: const Color.fromARGB(255, 114, 191, 254),
                      containerIcon: Icons.person_outline_outlined,
                      containerText: 'Doctors',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => const DoctorsPage())));
                      },
                    ),
                    MyContainer(
                      containerclr: const Color.fromARGB(255, 114, 191, 254),
                      containerIcon: Icons.location_pin,
                      containerText: 'Areas',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => const Areas())));
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),
                ContainerRow(
                  children: [
                    MyContainer(
                      containerclr: Colors.amber[200]!,
                      containerIcon: Icons.picture_in_picture_alt_rounded,
                      containerText: 'Products',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => const ProductListScreen())));
                      },
                    ),
                    MyContainer(
                      containerclr: Colors.amber[200]!,
                      containerIcon: Icons.assignment_add,
                      containerText: 'Assign Products & Areas',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) =>
                                    const AssignAreasProductsToEmployees())));
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                ContainerRow(
                  children: [
                    MyContainer(
                      containerclr: Colors.green[100]!,
                      containerIcon: Icons.assignment_ind_outlined,
                      containerText: 'Show Assigned Areas/Products to Employees',
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const ShowAssignedAreasProducts();
                        }));
                      },
                    ),
                    MyContainer(
                      containerclr: Colors.purple[100]!,
                      containerIcon: Icons.add_chart_outlined,
                      containerText: 'Monthly Targets',
                      onTap: () {},
                    ),
                  ],
                )
              ],
            )));
  }
}
