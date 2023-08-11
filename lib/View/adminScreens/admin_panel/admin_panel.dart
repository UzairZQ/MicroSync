import 'package:flutter/material.dart';
import 'package:micro_pharma/View/adminScreens/admin_panel/products_page.dart';
import 'package:micro_pharma/View/adminScreens/admin_panel/show_assigned_areas_products.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/components/widgets/container_row.dart';
import 'package:micro_pharma/View/adminScreens/admin_panel/doctors_page.dart';
import 'areas_page.dart';
import 'assign_areas_products.dart';

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
                            builder: ((context) => const DoctorsPage())));
                  },
                  container2Tap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => const Areas())));
                  },
                ),
                const SizedBox(
                  height: 20.0,
                ),
                ContainerRow(
                  container1Clr: Colors.amber[200]!,
                  container2Clr: Colors.amber[200]!,
                  container1Icon: Icons.picture_in_picture_alt_rounded,
                  container2Icon: Icons.assignment_add,
                  container1Text: 'Products',
                  container2Text: 'Assign Products & Areas',
                  container1Tap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => const ProductListScreen())));
                  },
                  container2Tap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) =>
                                const AssignAreasProductsToEmployees())));
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                ContainerRow(
                    container1Clr: Colors.green[100]!,
                    container2Clr: Colors.purple[100]!,
                    container1Icon: Icons.assignment_ind_outlined,
                    container2Icon: Icons.add_chart_outlined,
                    container1Text: 'Show Assigned Areas/Products to Employees',
                    container2Text: 'Monthly Targets',
                    container1Tap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const ShowAssignedAreasProducts();
                      }));
                    },
                    container2Tap: () {})
              ],
            )));
  }
}
