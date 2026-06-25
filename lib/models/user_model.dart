import 'package:micro_pharma/models/product_model.dart';
import 'package:micro_pharma/models/area_model.dart';

class UserModel {
  UserModel({
    this.displayName,
    this.email,
    this.latitude,
    this.longitude,
    this.role,
    this.uid,
    this.phone,
    this.update,
    this.locationAccuracy,
    this.locationTrackingActive = false,
    this.workDayStatus,
    this.workSessionId,
    this.assignedAreas,
    this.assignedProducts,
  });

  factory UserModel.fromMap(Map<String, dynamic>? data) {
    final latitude = data?['latitude'];
    final longitude = data?['longitude'];

    return UserModel(
      displayName: data?['displayName'],
      email: data?['email'],
      latitude: latitude is num ? latitude.toDouble() : null,
      longitude: longitude is num ? longitude.toDouble() : null,
      role: data?['role'],
      uid: data?['uid'],
      phone: data?['phone'],
      update: data?['update'],
      locationAccuracy: data?['locationAccuracy'] is num
          ? (data?['locationAccuracy'] as num).toDouble()
          : null,
      locationTrackingActive: data?['locationTrackingActive'] == true,
      workDayStatus: data?['workDayStatus'],
      workSessionId: data?['workSessionId'],
      assignedAreas: (data?['assignedAreas'] as List<dynamic>?)
          ?.map((areaData) => AreaModel.fromMap(areaData))
          .toList(),
      assignedProducts: (data?['assignedProducts'] as List<dynamic>?)
          ?.map((productData) => ProductModel.fromMap(productData))
          .toList(),
    );
  }

  String? displayName;
  String? email;
  double? latitude;
  double? longitude;
  String? role;
  String? uid;
  String? phone;
  String? update;
  double? locationAccuracy;
  bool locationTrackingActive;
  String? workDayStatus;
  String? workSessionId;
  List<AreaModel>? assignedAreas;
  List<ProductModel>? assignedProducts;

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'role': role,
      'uid': uid,
      'phone': phone,
      'update': update,
      'locationAccuracy': locationAccuracy,
      'locationTrackingActive': locationTrackingActive,
      'workDayStatus': workDayStatus,
      'workSessionId': workSessionId,
      'assignedAreas': assignedAreas?.map((area) => area.toMap()).toList(),
      'assignedProducts':
          assignedProducts?.map((product) => product.toMap()).toList(),
    };
  }
}
