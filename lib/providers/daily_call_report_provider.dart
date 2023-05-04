import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dcr_model.dart';

class DailyCallReportProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _reportsCollection =
      FirebaseFirestore.instance.collection('daily_call_reports');
  List<DailyCallReportModel> _reports = [];

  Future<void> fetchReports() async {
    try {
      final snapshot = await _reportsCollection.get();
      _reports = snapshot.docs
          .map((doc) =>
              DailyCallReportModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void saveReport(DailyCallReportModel report) async {
    try {
      final docRef = _reportsCollection.doc(); // generate a new document reference with a unique ID
      final newReport = report.copyWith(
          reportId: docRef.id); // update the report with the generated ID
      await docRef.set(newReport.toMap()); // add the report to the database
      _reports.add(newReport);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  DailyCallReportModel? getReportForCurrentDate() {
    DateTime currentDate = DateTime.now();
    return _reports.firstWhere(
      (report) =>
          report.date.year == currentDate.year &&
          report.date.month == currentDate.month &&
          report.date.day == currentDate.day,
      //orElse: () => null,
    );
  }

  void updateReport(DailyCallReportModel report) async {
    try {
      final docRef = _reportsCollection.doc(report.reportId);
      await docRef.update(report.toMap());
      int index = _reports.indexWhere((r) => r.reportId == report.reportId);
      if (index != -1) {
        _reports[index] = report;
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  List<DailyCallReportModel> getAllReports() {
    return _reports;
  }

  void deleteReport(DateTime date) async {
    try {
      final reportToDelete = _reports.firstWhere(
        (report) =>
            report.date.year == date.year &&
            report.date.month == date.month &&
            report.date.day == date.day,
      );
      await _reportsCollection.doc(reportToDelete.reportId).delete();
      _reports.remove(reportToDelete);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
