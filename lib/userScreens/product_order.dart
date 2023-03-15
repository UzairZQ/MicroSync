import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';

class ProductOrder extends StatelessWidget {
  const ProductOrder({Key? key}) : super(key: key);
  static String id = 'productorder';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(appBartxt: 'Product Orders'),
    );
  }
}
