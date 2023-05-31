import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:micro_pharma/models/user_model.dart';
import 'package:micro_pharma/models/product_model.dart';
import 'package:micro_pharma/models/area_model.dart';

class UserDataProvider with ChangeNotifier {
  UserModel _user = UserModel();
  List<UserModel> _users = [];

  UserModel get getUserData => _user;
  List<UserModel> get getUsers => _users;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  UserModel? selectedUser;
  List<AreaModel> selectedAreas = [];
  List<ProductModel> selectedProducts = [];

  void setSelectedUser(UserModel user) {
    selectedUser = user;
    notifyListeners();
  }

  void toggleAreaSelection(AreaModel area) {
    if (selectedAreas.contains(area)) {
      selectedAreas.remove(area);
    } else {
      selectedAreas.add(area);
    }
    notifyListeners();
  }

  void toggleProductSelection(ProductModel product) {
    if (selectedProducts.contains(product)) {
      selectedProducts.remove(product);
    } else {
      selectedProducts.add(product);
    }
    notifyListeners();
  }

  Future<void> addAreasAndProductsToEmployee(List<AreaModel> areas,
      List<ProductModel> products, UserModel employee) async {
    try {
      _isLoading = true;
      // Get the document reference for the employee
      final employeeDocRef =
          FirebaseFirestore.instance.collection('users').doc(employee.uid);

      // Create a list of area objects
      final List<Map<String, dynamic>> areaObjects =
          areas.map((area) => area.toMap()).toList();

      // Create a list of product objects
      final List<Map<String, dynamic>> productObjects =
          products.map((product) => product.toMap()).toList();

      // Update the employee document with the selected areas and products
      await employeeDocRef.update({
        'assignedAreas': areaObjects,
        'assignedProducts': productObjects,
      });
      _isLoading = false;
      // Show a success message or perform any other necessary actions
    } catch (e) {
      _isLoading = false;
      print('Error adding areas and products to employee: $e');
      // Show an error message or handle the error in an appropriate way
    }
  }

  Future<void> fetchUserData(String userId) async {
    try {
      _isLoading = true;
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (docSnapshot.exists) {
        final newUser = UserModel.fromMap(docSnapshot.data()!);
        print('User Data: ${docSnapshot.data()}');

        _user = newUser;
        notifyListeners();
      }
      _isLoading = false;
      return;
    } catch (e) {
      _isLoading = false;
      print('error in the fetch user function $e');

      return;
    }
  }

  Future<void> fetchAllEmployees() async {
    try {
      _isLoading = true;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'user')
          .get();
      _users = querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
      notifyListeners();
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      print('Error in fetching users by role: $e');
      return;
    }
  }
}



 // Future<void> assignProductToEmployee(
  //     ProductModel product, UserModel employee) async {
  //   try {
  //     // Assign the product to the employee in the database
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(employee.uid)
  //         .update({
  //       'assignedProducts': FieldValue.arrayUnion([product.toMap()])
  //     });

  //     // Update the local user data
  //     _user.assignedProducts?.add(product);
  //     notifyListeners();
  //   } catch (e) {
  //     print('Error assigning product to employee: $e');
  //   }
  // }

  // Future<void> removeProductFromEmployee(
  //     ProductModel product, UserModel employee) async {
  //   try {
  //     // Remove the product from the employee in the database
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(employee.uid)
  //         .update({
  //       'assignedProducts': FieldValue.arrayRemove([product.toMap()])
  //     });

  //     // Update the local user data
  //     _user.assignedProducts?.remove(product);
  //     notifyListeners();
  //   } catch (e) {
  //     print('Error removing product from employee: $e');
  //   }
  // }

  // Future<void> assignAreaToEmployee(AreaModel area, UserModel employee) async {
  //   try {
  //     // Assign the area to the employee in the database
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(employee.uid)
  //         .update({
  //       'assignedAreas': FieldValue.arrayUnion([area.toMap()])
  //     });

  //     // Update the local user data
  //     _user.assignedAreas?.add(area);
  //     notifyListeners();
  //   } catch (e) {
  //     print('Error assigning area to employee: $e');
  //   }
  // }

  // Future<void> removeAreaFromEmployee(
  //     AreaModel area, UserModel employee) async {
  //   try {
  //     // Remove the area from the employee in the database
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(employee.uid)
  //         .update({
  //       'assignedAreas': FieldValue.arrayRemove([area.toMap()])
  //     });

  //     // Update the local user data
  //     _user.assignedAreas?.remove(area);
  //     notifyListeners();
  //   } catch (e) {
  //     print('Error removing area from employee: $e');
  //   }
  // }