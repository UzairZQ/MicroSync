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

  static Future<void> deleteDoctor(String doctorName, String doctorArea) async {
    // Get the reference to the Firestore collection 'doctors'
    CollectionReference doctorsCollection =
        FirebaseFirestore.instance.collection('doctors');

    try {
      // Query the doctors collection based on the provided name and area
      QuerySnapshot querySnapshot = await doctorsCollection
          .where('name', isEqualTo: doctorName)
          .where('area', isEqualTo: doctorArea)
          .get();

      // Iterate through the documents returned from the query and delete each one
      for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
        await docSnapshot.reference.delete();
      }
      showCustomDialog(
          context: navigatorKey.currentContext!,
          title: 'Deleted',
          content: 'The doctor is removed from the database ');
    } catch (e) {
      print('Error deleting doctor: $e');
      // Handle any error that occurred during the deletion process
    }
  }
}
