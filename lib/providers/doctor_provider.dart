import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:micro_pharma/models/doctor_model.dart';

class DoctorDataProvider with ChangeNotifier {
  List<DoctorModel> _doctors = [];

  List<DoctorModel> get getDoctorList => _doctors;

  Future<void> fetchDoctorData() async {
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

  Future<void> addNewDoctor(DoctorModel newDoctor) async {
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('doctors')
          .add(newDoctor.toMap());
      newDoctor.id = docRef.id;
      _doctors.add(newDoctor);
      notifyListeners();
    } catch (e) {
      print('Error in the add new doctor function: $e');
      return;
    }
  }

  Future<void> updateDoctor(DoctorModel updatedDoctor) async {
    try {
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(updatedDoctor.id)
          .update(updatedDoctor.toMap());
      final doctorIndex =
          _doctors.indexWhere((doc) => doc.id == updatedDoctor.id);
      _doctors[doctorIndex] = updatedDoctor;
      notifyListeners();
    } catch (e) {
      print('Error in the update doctor function: $e');
      return;
    }
  }

  Future<void> deleteDoctor(String id) async {
    try {
      await FirebaseFirestore.instance.collection('doctors').doc(id).delete();
      _doctors.removeWhere((doc) => doc.id == id);
      notifyListeners();
    } catch (e) {
      print('Error in the delete doctor function: $e');
      return;
    }
  }
}
