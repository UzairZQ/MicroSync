class DoctorVisitModel {
  String? name;
  List<SelectedProduct>? selectedProducts;
  String? doctorRemarks;
  bool? visited;

  DoctorVisitModel({
    this.name,
    this.selectedProducts,
    this.doctorRemarks,
    this.visited
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'selectedProducts':
          selectedProducts?.map((product) => product.toMap()).toList(),
      'doctorRemarks': doctorRemarks,
      'visited': visited
    };
  }

  factory DoctorVisitModel.fromMap(Map<String, dynamic> map) {
    return DoctorVisitModel(
      name: map['name'],
      selectedProducts: List<SelectedProduct>.from(map['selectedProducts']
          ?.map((product) => SelectedProduct.fromMap(product))),
      doctorRemarks: map['doctorRemarks'],
      visited: map['visited']
    );
  }
}

class SelectedProduct {
  final String productName;
  final int quantity;

  SelectedProduct({required this.productName, required this.quantity});

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'quantity': quantity,
    };
  }

  static SelectedProduct fromMap(Map<String, dynamic> map) {
    return SelectedProduct(
      productName: map['productName'],
      quantity: map['quantity'],
    );
  }
}
