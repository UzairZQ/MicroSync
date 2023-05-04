import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/day_plan_model.dart';

class DayPlanProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _dayPlanCollection =
      FirebaseFirestore.instance.collection('day_plans');
  List<DayPlanModel> _dayPlans = [];

  List<DayPlanModel> get dayPlans => _dayPlans;

  Future<void> fetchDayPlans() async {
    try {
      final snapshot = await _dayPlanCollection.get();
      _dayPlans = snapshot.docs
          .map((doc) =>
              DayPlanModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> addDayPlan(DayPlanModel dayPlan) async {
    try {
      final docRef = _dayPlanCollection
          .doc(); // generate a new document reference with a unique ID
      final newDayPlan = dayPlan.copyWith(
          dayPlanId: docRef.id); // update the day plan with the generated ID
      await docRef.set(newDayPlan.toMap()); // add the day plan to the database
      _dayPlans.add(newDayPlan);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  DayPlanModel? getCurrentDayPlan() {
    DateTime currentDate = DateTime.now().toUtc().toLocal();
    // if (_dayPlans.isEmpty) {
    //   return null;
    // }
    return _dayPlans.firstWhere(
      (dayPlan) =>
          dayPlan.date.year == currentDate.year &&
          dayPlan.date.month == currentDate.month &&
          dayPlan.date.day == currentDate.day,
    );
  }

  Future<void> deleteDayPlan(DayPlanModel dayPlan) async {
    try {
      await _dayPlanCollection.doc(dayPlan.dayPlanId).delete();
      _dayPlans.remove(dayPlan);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
