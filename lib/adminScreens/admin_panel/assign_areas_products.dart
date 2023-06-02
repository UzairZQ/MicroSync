import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:micro_pharma/providers/user_data_provider.dart';
import 'package:micro_pharma/providers/product_data_provider.dart';
import 'package:micro_pharma/providers/area_provider.dart';
import 'package:micro_pharma/models/area_model.dart';
import 'package:micro_pharma/models/product_model.dart';
import 'package:micro_pharma/models/user_model.dart';

import '../../components/constants.dart';

class AssignAreasProductsToEmployees extends StatefulWidget {
  const AssignAreasProductsToEmployees({Key? key}) : super(key: key);

  @override
  AssignAreasProductsToEmployeesState createState() =>
      AssignAreasProductsToEmployeesState();
}

class AssignAreasProductsToEmployeesState
    extends State<AssignAreasProductsToEmployees>
    with SingleTickerProviderStateMixin {
  List<AreaModel>? areasList; // List of available areas
  List<ProductModel>? productsList; // List of available products
  List<UserModel>? employeesList; // List of employees
  late UserDataProvider userDataProvider;
  late ProductDataProvider productDataProvider;
  late AreaProvider areaProvider;
  List<AreaModel> selectedAreas = [];
  List<ProductModel> selectedProducts = [];

  int? selectedEmployeeIndex; // Add this variable

  @override
  void initState() {
    super.initState();

    fetchData();
  }

  Future<void> fetchData() async {
    userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    productDataProvider =
        Provider.of<ProductDataProvider>(context, listen: false);
    areaProvider = Provider.of<AreaProvider>(context, listen: false);
    await productDataProvider.fetchProductsList();
    await areaProvider.fetchAreas();
    await userDataProvider.fetchAllEmployees();

    setState(() {
      areasList = areaProvider.getAreas;
      productsList = productDataProvider.productsList;
      employeesList = userDataProvider.getUsers;
    });
  }

  void showLoading() {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: MyTextwidget(text: 'Assign Products & Areas'),
        icon: const Icon(Icons.save),
        onPressed: () {
          try {
            if (userDataProvider.selectedUser != null) {
              // Perform the database update with the selected areas and products
              // using the chosen user
              userDataProvider.addAreasAndProductsToEmployee(
                userDataProvider.selectedAreas,
                userDataProvider.selectedProducts,
                userDataProvider.selectedUser!,
              );
            }
            setState(() {
              selectedAreas = [];
              selectedProducts = [];
            });

            // Force the page to rebuild
            showCustomDialog(
                context: context,
                title: 'Success',
                content:
                    'Products and Areas Assigned to the selected Employee');
          } catch (e) {
            showCustomDialog(
                context: context,
                title: 'Failure',
                content: 'An error occured, please try again');
            print(e);
          }
        },
      ),
      appBar: const MyAppBar(
        appBartxt: 'Assign Products & Areas',
      ),
      body: Consumer<UserDataProvider>(builder: (context, userDataProvider, _) {
        selectedAreas = userDataProvider.selectedAreas;
        selectedProducts = userDataProvider.selectedProducts;
        if (userDataProvider.isLoading ||
            areaProvider.isLoadin ||
            productDataProvider.isLoadin) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyTextwidget(
                    text: 'Select Employee:',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<int>(
                    hint: MyTextwidget(text: 'Select From Here '),
                    value: selectedEmployeeIndex,
                    onChanged: (selectedIndex) {
                      setState(() {
                        selectedEmployeeIndex = selectedIndex;
                      });
                      final selectedEmployee = employeesList?[selectedIndex!];
                      if (selectedEmployee != null) {
                        userDataProvider.fetchUserData(selectedEmployee.uid!);
                        userDataProvider
                            .setSelectedUser(selectedEmployee); // Add this line
                      }
                    },
                    items: employeesList?.asMap().entries.map((entry) {
                      final index = entry.key;
                      final employee = entry.value;

                      return DropdownMenuItem<int>(
                        value: index, // Use the index as the value
                        child: Text(employee.displayName!),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  MyTextwidget(
                    text: 'Assign Areas:',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: areasList?.map((area) {
                          bool isSelected = selectedAreas.contains(area);
                          return ChoiceChip(
                            selectedColor: kappbarColor.withAlpha(150),
                            disabledColor: Colors.grey[100],
                            label: MyTextwidget(text: area.areaName),
                            selected: isSelected,
                            onSelected: (value) {
                              setState(() {
                                userDataProvider.toggleAreaSelection(area);
                              });
                            },
                          );
                        }).toList() ??
                        [],
                  ),
                  const SizedBox(height: 32),
                  MyTextwidget(
                    text: 'Assign Products:',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 16),
                  // Search TextField
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Products',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      // Filter products based on search input
                      setState(() {
                        productsList = productDataProvider.productsList
                            .where((product) => product.name
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),

                  SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: (productsList!.length / 2).ceil(),
                        itemBuilder: (context, index) {
                          final startIndex = index * 2;
                          final endIndex = startIndex + 2;
                          final rowProducts = productsList!.sublist(startIndex,
                              endIndex.clamp(0, productsList!.length));

                          return Wrap(
                            spacing: 8,
                            children: rowProducts.map((product) {
                              bool isSelected =
                                  selectedProducts.contains(product);
                              return ChoiceChip(
                                selectedColor: kappbarColor.withAlpha(150),
                                disabledColor: Colors.grey[100],
                                label: MyTextwidget(text: product.name),
                                selected: isSelected,
                                onSelected: (value) {
                                  setState(() {
                                    userDataProvider
                                        .toggleProductSelection(product);
                                  });
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }),
    );
  }
}
