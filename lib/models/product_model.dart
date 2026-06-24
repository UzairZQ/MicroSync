class OrderSelectedProduct extends ProductModel {
  String quantity;
  String? bonus;
  String? discount;

  OrderSelectedProduct(
      {required super.name,
      required super.tradePrice,
      required super.retailPrice,
      super.packing,
      required this.quantity,
      this.bonus,
      this.discount,
      required super.code});

  factory OrderSelectedProduct.fromMap(Map<String, dynamic> json) {
    return OrderSelectedProduct(
      code: json['code'] as int,
      name: json['name'] as String,
      retailPrice: (json['mrp'] as num).toDouble(),
      tradePrice: (json['trp'] as num).toDouble(),
      packing: json['packing'] as dynamic,
      quantity: json['quantity'] as String,
      bonus: json['bonus'] as String?,
      discount: json['discount'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = super.toMap();
    data['quantity'] = quantity;
    data['bonus'] = bonus;
    data['discount'] = discount;
    return data;
  }
}

class ProductModel {
  final int code;
  final String name;
  final double retailPrice;
  final double tradePrice;
  final dynamic packing;

  ProductModel({
    required this.code,
    required this.name,
    required this.retailPrice,
    required this.tradePrice,
    required this.packing,
  });

  factory ProductModel.fromMap(Map<String, dynamic> json) {
    return ProductModel(
      code: json['code'] as int,
      name: json['name'] as String,
      retailPrice: (json['mrp'] as num).toDouble(),
      tradePrice: (json['trp'] as num).toDouble(),
      packing: json['packing'],
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['name'] = name;
    data['mrp'] = retailPrice;
    data['trp'] = tradePrice;
    data['packing'] = packing;
    return data;
  }

  ProductModel copyWith({
    int? code,
    String? name,
    double? retailPrice,
    double? tradePrice,
    dynamic packing,
  }) {
    return ProductModel(
      code: code ?? this.code,
      name: name ?? this.name,
      retailPrice: retailPrice ?? this.retailPrice,
      tradePrice: tradePrice ?? this.tradePrice,
      packing: packing ?? this.packing,
    );
  }
}
