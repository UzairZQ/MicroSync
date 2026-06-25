import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:micro_pharma/viewModel/user_data_provider.dart';
import 'package:micro_pharma/viewModel/product_data_provider.dart';
import 'package:micro_pharma/viewModel/area_provider.dart';
import 'package:micro_pharma/models/area_model.dart';
import 'package:micro_pharma/models/product_model.dart';
import 'package:micro_pharma/models/user_model.dart';

import '../../../components/constants.dart';

class AssignAreasProductsToEmployees extends StatefulWidget {
  const AssignAreasProductsToEmployees({super.key});

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
  UserDataProvider? userDataProvider;
  ProductDataProvider? productDataProvider;
  AreaProvider? areaProvider;
  List<AreaModel> selectedAreas = [];
  List<ProductModel> selectedProducts = [];
  bool _isLoadingData = true;

  int? selectedEmployeeIndex; // Add this variable

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    final userProvider = context.read<UserDataProvider>();
    final productProvider = context.read<ProductDataProvider>();
    final areasProvider = context.read<AreaProvider>();
    userDataProvider = userProvider;
    productDataProvider = productProvider;
    areaProvider = areasProvider;

    await Future.wait([
      productProvider.fetchProductsList(),
      areasProvider.fetchAreas(),
      userProvider.fetchAllEmployees(),
    ]);

    if (!mounted) {
      return;
    }

    setState(() {
      areasList = areasProvider.getAreas;
      productsList = productProvider.productsList;
      employeesList = userProvider.getUsers;
      _isLoadingData = false;
    });
  }

  void showLoading() {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: const MyTextwidget(text: 'Assign Products & Areas'),
        icon: const Icon(Icons.save),
        onPressed: () async {
          try {
            final userProvider = userDataProvider;
            if (userProvider == null) {
              return;
            }
            var saved = false;
            if (userProvider.selectedUser != null) {
              // Perform the database update with the selected areas and products
              // using the chosen user
              saved = await userProvider.addAreasAndProductsToEmployee(
                userProvider.selectedAreas,
                userProvider.selectedProducts,
                userProvider.selectedUser!,
              );
            }
            if (!mounted) {
              return;
            }
            setState(() {
              selectedAreas = [];
              selectedProducts = [];
            });

            if (saved) {
              showCustomDialog(
                  context: context,
                  title: 'Success',
                  content: 'Products and Areas Assigned to the selected Rep');
            } else {
              showCustomDialog(
                  context: context,
                  title: 'No rep selected',
                  content: 'Select a rep before saving assignments.');
            }
          } catch (e) {
            showCustomDialog(
                context: context,
                title: 'Failure',
                content: 'An error occured, please try again');
          }
        },
      ),
      appBar: const MyAppBar(
        appBartxt: 'Assign Products & Areas',
      ),
      body: Consumer<UserDataProvider>(builder: (context, userDataProvider, _) {
        selectedAreas = userDataProvider.selectedAreas;
        selectedProducts = userDataProvider.selectedProducts;
        if (_isLoadingData ||
            userDataProvider.isLoading ||
            (areaProvider?.isLoadin ?? false) ||
            (productDataProvider?.isLoadin ?? false)) {
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
                  const MyTextwidget(
                    text: 'Select Rep:',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<int>(
                    hint: const MyTextwidget(text: 'Select From Here '),
                    value: selectedEmployeeIndex,
                    onChanged: (selectedIndex) {
                      if (selectedIndex == null) {
                        return;
                      }
                      setState(() {
                        selectedEmployeeIndex = selectedIndex;
                      });
                      final selectedEmployee = employeesList?[selectedIndex];
                      if (selectedEmployee != null) {
                        final uid = selectedEmployee.uid;
                        if (uid != null) {
                          userDataProvider.fetchUserData(uid);
                        }
                        userDataProvider
                            .setSelectedUser(selectedEmployee); // Add this line
                      }
                    },
                    items: employeesList?.asMap().entries.map((entry) {
                      final index = entry.key;
                      final employee = entry.value;

                      return DropdownMenuItem<int>(
                        value: index, // Use the index as the value
                        child: Text(employee.displayName ?? 'Unnamed rep'),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  const MyTextwidget(
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
                  const MyTextwidget(
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
                        productsList = (productDataProvider?.productsList ?? [])
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
                        itemCount: ((productsList ?? []).length / 2).ceil(),
                        itemBuilder: (context, index) {
                          final startIndex = index * 2;
                          final endIndex = startIndex + 2;
                          final currentProducts = productsList ?? [];
                          final rowProducts = currentProducts.sublist(
                              startIndex,
                              endIndex.clamp(0, currentProducts.length));

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
