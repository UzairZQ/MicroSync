import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/models/area_model.dart';

import '../models/product_model.dart';

class ProductOrder extends StatefulWidget {
  const ProductOrder({Key? key}) : super(key: key);

  @override
  _ProductOrderState createState() => _ProductOrderState();
}

class _ProductOrderState extends State<ProductOrder> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _productQuantityController =
      TextEditingController();
  final TextEditingController _bonusController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  AreaModel? _selectedArea;
  List<ProductModel>? _selectedProduct;
  String userId = FirebaseAuth.instance.currentUser!.uid;

  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      final customerName = _customerNameController.text;
      final productQuantity = int.parse(_productQuantityController.text);
      final bonus = int.parse(_bonusController.text);
      final discount = int.parse(_discountController.text);

      _formKey.currentState;

      // TODO: Send order details to admin
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _productQuantityController.dispose();
    _bonusController.dispose();
    _discountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(appBartxt: 'Product Order'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter customer name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // TODO: Implement area dropdown using areaProvider
              // DropdownButtonFormField(
              //   decoration: InputDecoration(
              //     labelText: 'Area',
              //   ),
              //   value: _selectedArea,
              //   onChanged: (value) {
              //     setState(() {
              //       _selectedArea = value as String?;
              //     });
              //   },
              //   items: areaProvider.areas.map((area) {
              //     return DropdownMenuItem(
              //       value: area.name,
              //       child: Text(area.name),
              //     );
              //   }).toList(),
              //   validator: (value) {
              //     if (value == null) {
              //       return 'Please select an area';
              //     }
              //     return null;
              //   },
              // ),
              const SizedBox(height: 16.0),
              // TODO: Implement product dropdown using productProvider
              // DropdownButtonFormField(
              //   decoration: InputDecoration(
              //     labelText: 'Product',
              //   ),
              //   value: _selectedProduct,
              //   onChanged: (value) {
              //     setState(() {
              //       _selectedProduct = value as String?;
              //     });
              //   },
              // items: productProvider.products.map((product) {
              // return DropdownMenuItem(
              // value: product.name,
              // child: Text(produc t.name),
              // );
              // }).toList(),
              // validator: (value) {
              // if (value == null) {
              // return 'Please select a product';
              // }
              // return null;
              // },
              // ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _productQuantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _bonusController,
                decoration: const InputDecoration(
                  labelText: 'Bonus',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter bonus';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(
                  labelText: 'Discount',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter discount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              MyButton(text: 'Send Order', onPressed: _submitOrder)
            ],
          ),
        ),
      ),
    );
  }
}
