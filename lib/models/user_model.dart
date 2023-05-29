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
    this.assignedAreas,
    this.assignedProducts,
  });

  factory UserModel.fromMap(Map<String, dynamic>? data) {
    return UserModel(
      displayName: data!['displayName'],
      email: data['email'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      role: data['role'],
      uid: data['uid'],
      phone: data['phone'],
      update: data['update'],
      assignedAreas: (data['assignedAreas'] as List<dynamic>?)
          ?.map((areaData) => AreaModel.fromMap(areaData))
          .toList(),
      assignedProducts: (data['assignedProducts'] as List<dynamic>?)
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
      'assignedAreas': assignedAreas?.map((area) => area.toMap()).toList(),
      'assignedProducts':
          assignedProducts?.map((product) => product.toMap()).toList(),
    };
  }
}
