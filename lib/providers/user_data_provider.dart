import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:micro_pharma/models/user_model.dart';

class UserDataProvider with ChangeNotifier {
  UserModel user = UserModel();

  fetchUserData(String userId) async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    UserModel newUser = UserModel.fromMap(docSnapshot.data());
    if (newUser != user) {
      user = newUser;
      notifyListeners();
    }
  }

  get getUserData {
    return user;
  }
}
