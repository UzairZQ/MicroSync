import 'package:micro_pharma/models/product_model.dart';

class OrderModel {
  String? id;
  String userId;
  DateTime date;
  List<ProductModel> products;
  int productCode;
  int quantity;
  int discount;
  int bonus;
  String customerName;
  String area;

  OrderModel({
    this.id,
    required this.userId,
    required this.date,
    required this.products,
    required this.productCode,
    required this.quantity,
    required this.discount,
    required this.bonus,
    required this.customerName,
    required this.area,
  });

  factory OrderModel.fromMap(
    Map<String, dynamic> json,
  ) =>
      OrderModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        date: DateTime.parse(json['date'] as String),
        products: json['products'] as List<ProductModel>,
        productCode: json['productCode'] as int,
        quantity: json['quantity'] as int,
        discount: json['discount'] as int,
        bonus: json['bonus'] as int,
        customerName: json['customerName'] as String,
        area: json['area'] as String,
      );

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
      };

  OrderModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    List<ProductModel>? products,
    int? productCode,
    int? quantity,
    int? discount,
    int? bonus,
    String? customerName,
    String? area,
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
    );
  }
}
