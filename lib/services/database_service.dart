import 'package:cloud_firestore/cloud_firestore.dart';

class DataBaseService {
  DataBaseService();
  final _db = FirebaseFirestore.instance;
  late String currentUser;

 

  Stream<QuerySnapshot> streamUser() {
    return _db.collection('users').where('role', isEqualTo: 'user').snapshots();
    
  }

  String setUser(String id) {
    currentUser = id;
    return currentUser;
  }
}

