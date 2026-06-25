import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/viewModel/user_data_provider.dart';
import 'package:provider/provider.dart';

import '../../../models/area_model.dart';
import '../../../models/product_model.dart';
import '../../../models/user_model.dart';

class ShowAssignedAreasProducts extends StatefulWidget {
  const ShowAssignedAreasProducts({super.key});

  @override
  State<ShowAssignedAreasProducts> createState() =>
      _ShowAssignedAreasProductsState();
}

class _ShowAssignedAreasProductsState extends State<ShowAssignedAreasProducts> {
  late UserDataProvider userDataProvider;
  List<UserModel>? employeesList;
  UserModel? selectedEmployee;
  List<ProductModel>? assignedProducts;
  List<AreaModel>? assignedAreas;
  int selectedEmployeeIndex = 0;
  late Future<void> _employeesFuture;

  @override
  void initState() {
    super.initState();
    userDataProvider = context.read<UserDataProvider>();
    _employeesFuture = fetchData();
  }

  Future<void> fetchData() async {
    await userDataProvider.fetchAllEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(appBartxt: 'View Assigned Products & Areas'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              FutureBuilder(
                future: _employeesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child:
                            CircularProgressIndicator()); // Show a loading indicator while fetching data
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final employeesList = userDataProvider.getUsers;
                    if (employeesList.isEmpty) {
                      return const MyTextwidget(
                        text: 'No reps found.',
                        fontSize: 16,
                      );
                    }
                    final safeEmployeeIndex = selectedEmployeeIndex
                        .clamp(0, employeesList.length - 1)
                        .toInt();
                    selectedEmployee = employeesList[safeEmployeeIndex];
                    assignedAreas ??= selectedEmployee?.assignedAreas;
                    assignedProducts ??= selectedEmployee?.assignedProducts;
                    return Center(
                      child: DropdownButton<int>(
                        hint: const MyTextwidget(text: 'Select Rep'),
                        value: safeEmployeeIndex,
                        onChanged: (selectedIndex) {
                          if (selectedIndex == null) {
                            return;
                          }
                          setState(() {
                            selectedEmployeeIndex = selectedIndex;
                            selectedEmployee = employeesList[selectedIndex];
                            final employee = selectedEmployee;
                            final uid = employee?.uid;
                            if (employee != null) {
                              if (uid != null) {
                                userDataProvider.fetchUserData(uid);
                              }
                              userDataProvider.setSelectedUser(employee);
                              assignedAreas = employee.assignedAreas;
                              assignedProducts = employee.assignedProducts;
                            }
                          });
                        },
                        items: employeesList.asMap().entries.map((entry) {
                          final index = entry.key;
                          final employee = entry.value;

                          return DropdownMenuItem<int>(
                            value: index,
                            child: Text(employee.displayName ?? 'Unnamed rep'),
                          );
                        }).toList(),
                      ),
                    );
                  }
                },
              ),

              // Display assigned products and areas based on selected rep
              if (assignedProducts == null || assignedProducts!.isEmpty)
                MyTextwidget(
                    text:
                        'No products assigned to ${selectedEmployee?.displayName}')
              else
                MyTextwidget(
                  text:
                      'Assigned Products To Rep ${selectedEmployee?.displayName}: ',
                  fontSize: 17,
                ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.7),
                  itemCount: assignedProducts?.length ?? 0,
                  itemBuilder: (context, index) {
                    final product = assignedProducts?[index];
                    return InkWell(
                      onLongPress: () {
                        showCustomDialog(
                            actions: [
                              TextButton(
                                child: const MyTextwidget(
                                  text: 'Cancel',
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: const MyTextwidget(text: 'Yes'),
                                onPressed: () async {
                                  final employee = selectedEmployee;
                                  if (employee == null || product == null) {
                                    Navigator.pop(context);
                                    return;
                                  }
                                  userDataProvider.setSelectedUser(employee);
                                  final removed = await userDataProvider
                                      .removeProductFromUser(product);
                                  if (!context.mounted) {
                                    return;
                                  }
                                  Navigator.pop(context);
                                  if (removed) {
                                    setState(() {
                                      assignedProducts?.removeAt(index);
                                    });
                                  }
                                },
                              ),
                            ],
                            context: context,
                            title: 'Remove This Product?',
                            content: 'Do you want to un-assign this product?');
                      },
                      child: Material(
                        borderRadius: BorderRadius.circular(15),
                        elevation: 2,
                        child: Container(
                          height: 12,
                          width: 15,
                          decoration: BoxDecoration(
                            color: kappbarColor.withAlpha(100),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: MyTextwidget(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                text: product?.name ?? 'No Product found'),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (assignedAreas == null || assignedAreas!.isEmpty)
                MyTextwidget(
                    text:
                        'No areas assigned to ${selectedEmployee?.displayName}')
              else
                MyTextwidget(
                  text:
                      'Assigned Areas To Rep ${selectedEmployee?.displayName}:',
                  fontSize: 17,
                ),
              const SizedBox(
                height: 20,
              ),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: assignedAreas?.length ?? 0,
                itemBuilder: (context, index) {
                  final area = assignedAreas?[index];
                  return Card(
                    color: Colors.blue[100],
                    child: ListTile(
                      title:
                          MyTextwidget(text: area?.areaName ?? 'No Area Found'),
                      subtitle: MyTextwidget(text: '${area?.areaId}'),
                      trailing: IconButton(
                          onPressed: () {
                            showCustomDialog(
                              context: context,
                              title: 'Remove This Area?',
                              content: 'Do you want to un-assign this area?',
                              actions: [
                                TextButton(
                                  child: const MyTextwidget(text: 'Cancel'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                TextButton(
                                  child: const MyTextwidget(text: 'Yes'),
                                  onPressed: () async {
                                    final employee = selectedEmployee;
                                    if (employee == null || area == null) {
                                      Navigator.pop(context);
                                      return;
                                    }
                                    userDataProvider.setSelectedUser(employee);
                                    final removed = await userDataProvider
                                        .removeAreaFromUser(
                                      area,
                                    );
                                    if (!context.mounted) {
                                      return;
                                    }
                                    Navigator.pop(context);
                                    if (removed) {
                                      setState(() {
                                        assignedAreas?.removeAt(index);
                                      });
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          )),
                      // Other area widgets
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
