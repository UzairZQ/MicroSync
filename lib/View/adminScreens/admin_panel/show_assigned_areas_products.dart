import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/viewModel/user_data_provider.dart';
import 'package:provider/provider.dart';

import '../../../models/area_model.dart';
import '../../../models/product_model.dart';
import '../../../models/user_model.dart';

class ShowAssignedAreasProducts extends StatefulWidget {
  const ShowAssignedAreasProducts({Key? key}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
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
                future: fetchData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child:
                            CircularProgressIndicator()); // Show a loading indicator while fetching data
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final employeesList = userDataProvider.getUsers;
                    selectedEmployee = employeesList[selectedEmployeeIndex];
                    return Center(
                      child: DropdownButton<int>(
                        hint: MyTextwidget(text: 'Select Employee'),
                        value: selectedEmployeeIndex,
                        onChanged: (selectedIndex) {
                          setState(() {
                            selectedEmployeeIndex = selectedIndex!;
                          });
                          if (selectedIndex != null && selectedIndex >= 0) {
                            selectedEmployee = employeesList[selectedIndex];
                            if (selectedEmployee != null) {
                              userDataProvider
                                  .fetchUserData(selectedEmployee!.uid!);
                              userDataProvider
                                  .setSelectedUser(selectedEmployee!);
                              assignedAreas = selectedEmployee?.assignedAreas;
                              assignedProducts =
                                  selectedEmployee?.assignedProducts;
                            }
                          }
                        },
                        items: employeesList.asMap().entries.map((entry) {
                          final index = entry.key;
                          final employee = entry.value;

                          return DropdownMenuItem<int>(
                            value: index,
                            child: Text(employee.displayName!),
                          );
                        }).toList(),
                      ),
                    );
                  }
                },
              ),

              // Display assigned products and areas based on selected user
              if (assignedProducts == null || assignedProducts!.isEmpty)
                MyTextwidget(
                    text:
                        'No Products Assigned ${selectedEmployee?.displayName}')
              else
                MyTextwidget(
                  text:
                      'Assigned Products To ${selectedEmployee?.displayName}: ',
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
                                child: MyTextwidget(
                                  text: 'Cancel',
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: MyTextwidget(text: 'Yes'),
                                onPressed: () {
                                  userDataProvider
                                      .removeProductFromUser(product!);
                                  Navigator.pop(context);
                                  setState(() {
                                    assignedProducts?.removeAt(index);
                                  });
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
                        'No Areas Assigned to ${selectedEmployee?.displayName}')
              else
                MyTextwidget(
                  text: 'Assigned Areas To ${selectedEmployee?.displayName}:',
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
                                  child: MyTextwidget(text: 'Cancel'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                TextButton(
                                  child: MyTextwidget(text: 'Yes'),
                                  onPressed: () {
                                    Provider.of<UserDataProvider>(context,
                                            listen: false)
                                        .removeAreaFromUser(area!);
                                    Navigator.pop(context);
                                    setState(() {
                                      assignedAreas?.removeAt(index);
                                    });
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
