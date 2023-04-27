class DoctorModel {
  DoctorModel({
    this.name,
    this.area,
    this.address,
    this.speciality,
  });

  factory DoctorModel.fromMap(Map<String, dynamic>? data) {
    return DoctorModel(
      name: data!['name'],
      area: data['area'],
      address: data['address'],
      speciality: data['speciality'],
    );
  }
  String? address;
  String? area;
  String? name;
  String? speciality;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'area': area,
      'address': address,
      'specialty': speciality,
    };
  }
}
