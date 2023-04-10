class DoctorModel {
  DoctorModel({
    this.name,
    this.area,
    this.address,
    this.specialty,
  });

  factory DoctorModel.fromMap(Map<String, dynamic>? data) {
    return DoctorModel(
      name: data!['name'],
      area: data['area'],
      address: data['address'],
      specialty: data['specialty'],
    );
  }
  dynamic id;
  String? address;
  String? area;
  String? name;
  String? specialty;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'area': area,
      'address': address,
      'specialty': specialty,
    };
  }
}