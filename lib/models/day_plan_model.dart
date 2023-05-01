class DayPlanModel {
  final String userName;
  final String? shift;
  final String? dayPlanId;
  final DateTime date;
  final String area;
  final List<String> doctors;

  DayPlanModel({
    required this.shift,
    required this.userName,
    this.dayPlanId,
    required this.date,
    required this.area,
    required this.doctors,
  });

  factory DayPlanModel.fromMap(Map<String, dynamic> map, String id) {
    final List<dynamic> doctorsList = map['doctors'];
    final List<String> doctors = List<String>.from(doctorsList);
    return DayPlanModel(
      shift: map['shift'],
      userName: map['userName'],
      dayPlanId: id,
      date: DateTime.parse(map['date']),
      area: map['area'],
      doctors: doctors,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shift': shift,
      'userName': userName,
      'id': dayPlanId,
      'date': date.toIso8601String(),
      'area': area,
      'doctors': doctors,
    };
  }

  DayPlanModel copyWith({
    String? shift,
    String? userName,
    String? dayPlanId,
    DateTime? date,
    String? area,
    List<String>? doctors,
  }) {
    return DayPlanModel(
      shift: shift ?? this.shift,
      userName: userName ?? this.userName,
      dayPlanId: dayPlanId ?? this.dayPlanId,
      date: date ?? this.date,
      area: area ?? this.area,
      doctors: doctors ?? this.doctors,
    );
  }
}
