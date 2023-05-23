import 'package:micro_pharma/models/product_model.dart';

class OrderModel {
  String? id;
  String userName;
  DateTime date;
  List<OrderSelectedProduct> products;
  String customerName;
  String area;
  double? total;
  double? subTotal;

  OrderModel(
      {this.id,
      required this.userName,
      required this.date,
      required this.products,
      required this.customerName,
      required this.area,
      required this.total,
      required this.subTotal});

  factory OrderModel.fromMap(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String?,
      userName: json['userName'] as String,
      date: DateTime.parse(json['date'] as String),
      products: (json['products'] as List<dynamic>)
          .map((product) => OrderSelectedProduct.fromMap(product))
          .toList(),
      customerName: json['customerName'] as String,
      area: json['area'] as String,
      total: json['total'] != null ? json['total'] as double : 0.0,
      subTotal: json['subTotal'] != null ? json['subTotal'] as double : 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'date': date.toIso8601String(),
      'products': products.map((product) => product.toMap()).toList(),
      'customerName': customerName,
      'area': area,
      'total': total,
      'subTotal': subTotal,
    };
  }

  OrderModel copyWith({
    String? id,
    String? userName,
    DateTime? date,
    List<OrderSelectedProduct>? products,
    String? customerName,
    String? area,
    double? total,
    double? subTotal,
  }) {
    return OrderModel(
        id: id ?? this.id,
        userName: userName ?? this.userName,
        date: date ?? this.date,
        products: products ?? this.products,
        customerName: customerName ?? this.customerName,
        area: area ?? this.area,
        total: total ?? this.total,
        subTotal: subTotal ?? this.subTotal);
  }
}
