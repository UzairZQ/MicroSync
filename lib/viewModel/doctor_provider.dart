import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:micro_pharma/models/doctor_model.dart';

import '../components/constants.dart';

class DoctorDataProvider with ChangeNotifier {
  List<DoctorModel> _doctors = [];
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

  static Future<void> addDoctor(
      String docname, String docarea, String address, String special) async {
    try {
      await _firestore.collection('doctors').add({
        'address': address,
        'area': docarea,
        'name': docname,
        'speciality': special,
      });
   
      print('Added to database');
      showCustomDialog(
          context: navigatorKey.currentContext!,
          title: 'Success',
          content: 'Doctor Added to Database',
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(navigatorKey.currentContext!);
                },
                child: const Text('Okay'))
          ]);
    } catch (a) {
      showCustomDialog(
          context: navigatorKey.currentContext!,
          title: 'Failure',
          content: 'An error occured',
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(navigatorKey.currentContext!);
                },
                child: const Text('Okay'))
          ]);
      print('This is the error $a');
    }
  }
}
