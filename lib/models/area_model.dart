class AreaModel {
  AreaModel({required this.areaId, required this.areaName});

  final dynamic areaId;
  final String areaName;

  factory AreaModel.fromMap(Map<String, dynamic>? data) {
    return AreaModel(
      areaId: data!['areaId'],
      areaName: data['areaName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'areaId': areaId,
      'areaName': areaName,
    };
  }
}
