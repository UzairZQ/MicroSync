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
  const AssignAreasProductsToEmployees({super.key});

  @override
  AssignAreasProductsToEmployeesState createState() =>
      AssignAreasProductsToEmployeesState();
}

class AssignAreasProductsToEmployeesState
    extends State<AssignAreasProductsToEmployees> {
  List<AreaModel> areasList = []; // List of available areas
  List<ProductModel> productsList = []; // List of available products
  List<UserModel> employeesList = []; // List of employees

  @override
  void initState() {
    super.initState();
      final userDataProvider =
          Provider.of<UserDataProvider>(context, listen: false);
      final productDataProvider =
          Provider.of<ProductDataProvider>(context, listen: false);
      final areaProvider = Provider.of<AreaProvider>(context, listen: false);

      userDataProvider.fetchAllEmployees();
      productDataProvider.fetchProductsList();
      areaProvider.fetchAreas();
    
  }

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final productDataProvider = Provider.of<ProductDataProvider>(context);
    final areaProvider = Provider.of<AreaProvider>(context);

    areasList = areaProvider.getAreas;
    productsList = productDataProvider.productsList;
    employeesList = userDataProvider.getUsers;

    return Scaffold(
      appBar: const MyAppBar(appBartxt: 'Assign Products & Areas to Employees',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyTextwidget(text:
                'Select an employee:',
                 fontWeight: FontWeight.bold,
                 fontSize: 18,
              ),
              const SizedBox(height: 16),
              DropdownButton<UserModel>(
                value: userDataProvider.getUserData,
                onChanged: (selectedEmployee) {
                  userDataProvider.fetchUserData(selectedEmployee!.uid!);
                },
                items: employeesList.map((employee) {
                  return DropdownMenuItem<UserModel>(
                    value: employee,
                    child: Text(employee.displayName!),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              MyTextwidget(text:
                'Assign Areas:',
                fontSize: 18, fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: areasList.map((area) {
                  bool isSelected =
                      userDataProvider.getUserData.assignedAreas!.contains(area);
                  return ChoiceChip(
                    label: Text(area.areaName),
                    selected: isSelected,
                    onSelected: (value) {
                      if (value) {
                        userDataProvider.assignAreaToEmployee(
                            area, userDataProvider.getUserData);
                      } else {
                        userDataProvider.removeAreaFromEmployee(
                            area, userDataProvider.getUserData);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              MyTextwidget(text:
                'Assign Products:',
              fontSize: 18, fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: productsList.map((product) {
                  bool isSelected = userDataProvider
                      .getUserData.assignedProducts!
                      .contains(product);
                  return ChoiceChip(
                    label: Text(product.name),
                    selected: isSelected,
                    onSelected: (value) {
                      if (value) {
                        userDataProvider.assignProductToEmployee(
                            product, userDataProvider.getUserData);
                      } else {
                        userDataProvider.removeProductFromEmployee(
                            product, userDataProvider.getUserData);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
