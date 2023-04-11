import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import '../userScreens/login_page.dart';
import 'package:micro_pharma/main.dart';
import 'package:micro_pharma/components/constants.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({Key? key}) : super(key: key);

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productDescriptionController =
      TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productQuantityController =
      TextEditingController();

  void _submitProduct() {
    if (_formKey.currentState!.validate()) {
      final produtName = _productNameController.text;
      final productDescribtion = _productDescriptionController.text;

      final productPrice = double.parse(_productPriceController.text);

      final productQuantity = int.parse(_productQuantityController.text);

      _formKey.currentState;

      // TODO: Send order details to pharmacy
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productDescriptionController.dispose();
    _productPriceController.dispose();
    _productQuantityController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(appBartxt: 'Add Product'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: _productNameController,
              decoration: InputDecoration(
                labelText: 'Product Name',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter product name';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _productDescriptionController,
              decoration: InputDecoration(
                labelText: 'Product Description',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter product description';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _productPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Product Price',
                prefixText: '\PKR  ',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter product price';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _productQuantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Product Quantity',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter product quantity';
                }
                return null;
              },
            ),
            SizedBox(height: 32.0),
            MyButton(
                color: Colors.blue,
                text: 'Add Product',
                onPressed: _submitProduct)
          ],
        ),
      ),
    );
  }
}
