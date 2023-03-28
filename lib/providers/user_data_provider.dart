import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:micro_pharma/models/user_model.dart';

class UserDataProvider with ChangeNotifier {
  bool _isLoggedIn = true;
  UserModel _user = UserModel();

  UserModel get getUserData => _user;

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
    }
  }

  void logIn() {
    _isLoggedIn = true;
  }

  void logOut() {
    _isLoggedIn = false;
    _user = UserModel();
  }
}
