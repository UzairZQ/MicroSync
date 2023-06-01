import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:micro_pharma/models/area_model.dart';

class AreaProvider with ChangeNotifier {
  List<AreaModel> _areas = [];

  List<AreaModel> get getAreas => [..._areas];
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoadin => _isLoading;

  Future<void> fetchAreas() async {
    try {
      _isLoading = true;
      final snapshot =
          await FirebaseFirestore.instance.collection('areas').get();
      final List<AreaModel> loadedAreas = [];
      for (var doc in snapshot.docs) {
        loadedAreas.add(AreaModel(
          areaId: doc.data()['id'],
          areaName: doc.data()['name'],
        ));
      }
      _areas = loadedAreas;
      notifyListeners();
      _isLoading = false;
    } catch (error) {
      _isLoading = false;
      print('Error loading areas: $error');
      rethrow;
    }
  }

  Future<void> addAreatoDatabase(String areaName, String code) async {
    int areaCode = int.parse(code);
    try {
      await _firestore
          .collection('areas')
          .add({'id': areaCode, 'name': areaName});
      notifyListeners();

      print('Added to database');
    } catch (e) {
      print('This is the error $e');
    }
  }

  Future<void> deleteAreaFromDatabase(int areaId) async {
    try {
      await _firestore
          .collection('areas')
          .where('id', isEqualTo: areaId)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.first.reference.delete();
        notifyListeners();
      });
    } catch (error) {
      print('Error deleting area: $error');
      rethrow;
    }
  }
}
