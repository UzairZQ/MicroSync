class User {
  User(
      {this.displayName,
      this.email,
      this.latitude,
      this.longitude,
      this.role,
      this.uid});

  factory User.fromMap(Map<String, dynamic>? data) {
    return User(
        displayName: data!['displayName'] ?? 'defaultname',
        email: data['email'],
        latitude: data['latitude'],
        longitude: data['longitude'],
        role: data['role'],
        uid: data['uid']);
  }

  String? displayName;
  String? email;
  String? latitude;
  String? longitude;
  String? role;
  String? uid;

  
}

