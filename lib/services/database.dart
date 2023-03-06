import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/services/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:provider/provider.dart';

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