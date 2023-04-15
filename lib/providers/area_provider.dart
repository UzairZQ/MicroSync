import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:micro_pharma/models/area_model.dart';

class AreaProvider with ChangeNotifier {
  List<AreaModel> _areas = [];

  List<AreaModel> get areas => [..._areas];

  Future<void> fetchAreas() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('areas').get();
      final List<AreaModel> loadedAreas = [];
      for (var doc in snapshot.docs) {
        loadedAreas.add(AreaModel(
          areaId: doc.id,
          areaName: doc.data()['areaName'],
        ));
      }
      _areas = loadedAreas;
      notifyListeners();
    } catch (error) {
      print('Error loading areas: $error');
      rethrow;
    }
  }
}
