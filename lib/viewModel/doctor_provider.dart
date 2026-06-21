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
      _doctors = querySnapshot.docs
          .map((doc) => DoctorModel.fromMap(doc.data()))
          .toList();
      _doctors.sort(
        (a, b) => (a.name ?? '').toLowerCase().compareTo(
              (b.name ?? '').toLowerCase(),
            ),
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addDoctor(
      String docname, String docarea, String address, String special) async {
    try {
      await _firestore.collection('doctors').add({
        'address': address,
        'area': docarea,
        'name': docname,
        'speciality': special,
      });

      await fetchDoctors();
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
      return true;
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
      return false;
    }
  }

  Future<bool> deleteDoctor(String doctorName, String doctorArea) async {
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
      await fetchDoctors();
      showCustomDialog(
          context: navigatorKey.currentContext!,
          title: 'Deleted',
          content: 'The doctor is removed from the database ');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> editDoctor(
    String originalName,
    String originalArea,
    DoctorModel doctor,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('doctors')
          .where('name', isEqualTo: originalName)
          .where('area', isEqualTo: originalArea)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return false;
      }

      await querySnapshot.docs.first.reference.update(doctor.toMap());
      await fetchDoctors();
      return true;
    } catch (e) {
      return false;
    }
  }
}
