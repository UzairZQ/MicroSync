import 'dart:ffi';

import 'package:micro_pharma/models/product_model.dart';

class OrderModel {
  String? id;
  String userId;
  DateTime date;
  List<OrderSelectedProduct> products;
  int productCode;
  int quantity;
  int discount;
  int bonus;
  String customerName;
  String area;
  Double total;

  OrderModel(
      {this.id,
      required this.userId,
      required this.date,
      required this.products,
      required this.productCode,
      required this.quantity,
      required this.discount,
      required this.bonus,
      required this.customerName,
      required this.area,
      required this.total});

  factory OrderModel.fromMap(
    Map<String, dynamic> json,
  ) =>
      OrderModel(
          id: json['id'] as String,
          userId: json['userId'] as String,
          date: DateTime.parse(json['date'] as String),
          products: json['products'] as List<OrderSelectedProduct>,
          productCode: json['productCode'] as int,
          quantity: json['quantity'] as int,
          discount: json['discount'] as int,
          bonus: json['bonus'] as int,
          customerName: json['customerName'] as String,
          area: json['area'] as String,
          total: json['total'] as Double);

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'date': date.toIso8601String(),
        'products': products,
        'productCode': productCode,
        'quantity': quantity,
        'discount': discount,
        'bonus': bonus,
        'customerName': customerName,
        'area': area,
        'total': total
      };

  OrderModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    List<OrderSelectedProduct>? products,
    int? productCode,
    int? quantity,
    int? discount,
    int? bonus,
    String? customerName,
    String? area,
    Double? total,
  }) {
    return OrderModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        date: date ?? this.date,
        products: products ?? this.products,
        productCode: productCode ?? this.productCode,
        quantity: quantity ?? this.quantity,
        discount: discount ?? this.discount,
        bonus: bonus ?? this.bonus,
        customerName: customerName ?? this.customerName,
        area: area ?? this.area,
        total: total ?? this.total);
  }
}
