
class UserModel {
  UserModel({
    this.displayName,
    this.email,
    this.latitude,
    this.longitude,
    this.role,
    this.uid,
  });

  factory UserModel.fromMap(Map<String, dynamic>? data) {
    return UserModel(
        displayName: data!['displayName'],
        email: data['email'],
        latitude: data['latitude'] ?? 'no Data',
        longitude: data['longitude'] ?? 'no Data',
        role: data['role'],
        uid: data['uid']);
  }

  String? displayName;
  String? email;
  double? latitude;
  double? longitude;
  String? role;
  String? uid;
  String? phone;
  String? update;

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'role': role,
      'uid': uid,
    };
  }
}
