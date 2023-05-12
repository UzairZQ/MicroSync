
import '../userScreens/dailycall_report.dart';

class DoctorVisitModel {
  String? name;
  List<SelectedProduct>? selectedProducts;
  String? doctorRemarks;

  DoctorVisitModel({
    this.name,
    this.selectedProducts,
    this.doctorRemarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'product': selectedProducts,
      'remarks': doctorRemarks,
    };
  }

  factory DoctorVisitModel.fromMap(Map<String, dynamic> map) {
    return DoctorVisitModel(
      name: map['name'],
      selectedProducts: map['products'],
      doctorRemarks: map['remarks'],
    );
  }
}

class DailyCallReportModel {
  final String? reportId;
  final DateTime date;
  final List<DoctorVisitModel>? doctorsVisited;
  final String? remarks;

  DailyCallReportModel({
    this.reportId,
    required this.date,
    required this.doctorsVisited,
    this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'date': date.toIso8601String(),
      'doctorsVisited': doctorsVisited?.map((visit) => visit.toMap()).toList(),
      'remarks': remarks,
    };
  }

  factory DailyCallReportModel.fromMap(Map<String, dynamic> map, String id) {
    return DailyCallReportModel(
      reportId: id,
      date: DateTime.parse(map['date']),
      doctorsVisited: List<DoctorVisitModel>.from(
          map['doctorsVisited']?.map((x) => DoctorVisitModel.fromMap(x))),
      remarks: map['remarks'],
    );
  }

  DailyCallReportModel copyWith({
    String? reportId,
    DateTime? date,
    List<DoctorVisitModel>? doctorsVisited,
    String? remarks,
  }) {
    return DailyCallReportModel(
      reportId: reportId ?? this.reportId,
      date: date ?? this.date,
      doctorsVisited: doctorsVisited ?? this.doctorsVisited,
      remarks: remarks ?? this.remarks,
    );
  }
}
