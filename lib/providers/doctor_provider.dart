import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:micro_pharma/models/doctor_model.dart';

class DoctorDataProvider with ChangeNotifier {
  List<DoctorModel> _doctors = [];

  List<DoctorModel> get getDoctorList => _doctors;

  Future<void> fetchDoctors() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('doctors').get();
      if (querySnapshot.docs.isNotEmpty) {
        _doctors = querySnapshot.docs
            .map((doc) => DoctorModel.fromMap(doc.data()))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error in the fetch doctor data function: $e');
      return;
    }
  }
}
