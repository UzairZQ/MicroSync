class AreaModel {
  AreaModel({required this.areaId, required this.areaName});

  final int areaId;
  final String areaName;

  factory AreaModel.fromMap(Map<String, dynamic>? data) {
    return AreaModel(
      areaId: data!['id'],
      areaName: data['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': areaId,
      'name': areaName,
    };
  }
}
