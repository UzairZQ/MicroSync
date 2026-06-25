class OrderSelectedProduct extends ProductModel {
  String quantity;
  String? bonus;

  OrderSelectedProduct(
      {required super.name,
      super.packing,
      required this.quantity,
      this.bonus,
      required super.code})
      : super(retailPrice: 0, tradePrice: 0);

  factory OrderSelectedProduct.fromMap(Map<String, dynamic> json) {
    return OrderSelectedProduct(
      code: json['code'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown product',
      packing: json['packing'] as dynamic,
      quantity: json['quantity']?.toString() ?? '0',
      bonus: json['bonus'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{
      'code': code,
      'name': name,
      'packing': packing,
    };
    data['quantity'] = quantity;
    data['bonus'] = bonus;
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
    this.retailPrice = 0,
    this.tradePrice = 0,
    required this.packing,
  });

  factory ProductModel.fromMap(Map<String, dynamic> json) {
    return ProductModel(
      code: json['code'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unnamed product',
      retailPrice: (json['mrp'] as num?)?.toDouble() ?? 0,
      tradePrice: (json['trp'] as num?)?.toDouble() ?? 0,
      packing: json['packing'],
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['name'] = name;
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
