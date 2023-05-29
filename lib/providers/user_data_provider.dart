import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:micro_pharma/models/user_model.dart';
import 'package:micro_pharma/models/product_model.dart';
import 'package:micro_pharma/models/area_model.dart';

class UserDataProvider with ChangeNotifier {
  bool _isLoggedIn = true;
  UserModel _user = UserModel();
  List<UserModel> _users = [];

  UserModel get getUserData => _user;
  List<UserModel> get getUsers => _users;

  Future<void> fetchUserData(String userId) async {
    if (!_isLoggedIn) return;
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (docSnapshot.exists) {
        final newUser = UserModel.fromMap(docSnapshot.data()!);
        if (newUser != _user) {
          // only update if new user is different
          _user = newUser;
          notifyListeners();
        }
      }
    } catch (e) {
      print('error in the fetch user function $e');
      return;
    }
  }

  Future<void> fetchAllEmployees() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'user')
          .get();
      _users = querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error in fetching users by role: $e');
      return;
    }
  }

  Future<void> assignProductToEmployee(
      ProductModel product, UserModel employee) async {
    try {
      // Assign the product to the employee in the database
      await FirebaseFirestore.instance
          .collection('users')
          .doc(employee.uid)
          .update({
        'assignedProducts': FieldValue.arrayUnion([product.toMap()])
      });

      // Update the local user data
      _user.assignedProducts?.add(product);
      notifyListeners();
    } catch (e) {
      print('Error assigning product to employee: $e');
    }
  }

  Future<void> removeProductFromEmployee(
      ProductModel product, UserModel employee) async {
    try {
      // Remove the product from the employee in the database
      await FirebaseFirestore.instance
          .collection('users')
          .doc(employee.uid)
          .update({
        'assignedProducts': FieldValue.arrayRemove([product.toMap()])
      });

      // Update the local user data
      _user.assignedProducts?.remove(product);
      notifyListeners();
    } catch (e) {
      print('Error removing product from employee: $e');
    }
  }

  Future<void> assignAreaToEmployee(AreaModel area, UserModel employee) async {
    try {
      // Assign the area to the employee in the database
      await FirebaseFirestore.instance
          .collection('users')
          .doc(employee.uid)
          .update({
        'assignedAreas': FieldValue.arrayUnion([area.toMap()])
      });

      // Update the local user data
      _user.assignedAreas?.add(area);
      notifyListeners();
    } catch (e) {
      print('Error assigning area to employee: $e');
    }
  }

  Future<void> removeAreaFromEmployee(AreaModel area, UserModel employee) async {
    try {
      // Remove the area from the employee in the database
      await FirebaseFirestore.instance
          .collection('users')
          .doc(employee.uid)
          .update({
        'assignedAreas': FieldValue.arrayRemove([area.toMap()])
      });

      // Update the local user data
      _user.assignedAreas?.remove(area);
      notifyListeners();
    } catch (e) {
      print('Error removing area from employee: $e');
    }
  }
}
