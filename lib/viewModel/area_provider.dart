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
      notifyListeners();
      final snapshot =
          await FirebaseFirestore.instance.collection('areas').get();
      final List<AreaModel> loadedAreas = [];
      for (var doc in snapshot.docs) {
        loadedAreas.add(AreaModel(
          areaId: doc.data()['id'],
          areaName: doc.data()['name'],
        ));
      }
      loadedAreas.sort((a, b) => a.areaName.compareTo(b.areaName));
      _areas = loadedAreas;
      notifyListeners();
      _isLoading = false;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> addAreatoDatabase(String areaName, String code) async {
    final areaCode = int.tryParse(code);
    if (areaCode == null) {
      return false;
    }
    try {
      await _firestore
          .collection('areas')
          .add({'id': areaCode, 'name': areaName});
      await fetchAreas();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAreaFromDatabase(int areaId) async {
    try {
      final querySnapshot = await _firestore
          .collection('areas')
          .where('id', isEqualTo: areaId)
          .get();
      if (querySnapshot.docs.isEmpty) {
        return false;
      }
      await querySnapshot.docs.first.reference.delete();
      await fetchAreas();
      notifyListeners();
      return true;
    } catch (error) {
      return false;
    }
  }
}
