import 'package:cloud_firestore/cloud_firestore.dart';


class DataBaseService {
  DataBaseService();
  final _db = FirebaseFirestore.instance;
  late String currentUser;

  // Future<User> getUser() async {
    
  // }

  Stream<QuerySnapshot> streamUser() {
    return _db.collection('users').snapshots();
    //       .map((snap) => User.fromMap(snap.data()));
  }

  String setUser(String id) {
    currentUser = id;
    return currentUser;
  }
}
//  .map((snap) => User.fromMap(snap.data()));