import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});
  static String id = 'addproduct';
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  final _codeController = TextEditingController();
  final _tradePriceController = TextEditingController();
  final _retailPriceController = TextEditingController();

  void _submitProduct() {
    if (_formKey.currentState!.validate()) {
      final productName = _productController.text;

      final retailPrice = double.parse(_retailPriceController.text);
      final tradePrice = double.parse(_tradePriceController.text);

      _formKey.currentState;

      // TODO: add product to database
    }
  }

  void _updateTradePrice(String value) {
    if (value.isNotEmpty) {
      double retailPrice = double.parse(value);
      double tradePrice = retailPrice * 0.85;
      _tradePriceController.text = tradePrice.toStringAsFixed(2);
    } else {
      _tradePriceController.text = '';
    }
  }

  @override
  void dispose() {
    _productController.dispose();
    _codeController.dispose();
    _retailPriceController.dispose();
    _tradePriceController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New Product'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                const Padding(padding: EdgeInsets.fromLTRB(5, 5, 5, 0)),
                TextFormField(
                  controller: _productController,
                  decoration: const InputDecoration(labelText: 'Medicine Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter product name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(labelText: ' Product Code'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(labelText: ' Packing'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter packing ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _retailPriceController,
                  onChanged: _updateTradePrice,
                  decoration: const InputDecoration(labelText: 'Retail Price'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Pleas enter retail price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _tradePriceController,
                  enabled: false,
                  decoration: const InputDecoration(labelText: ' Trade Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter trade price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: MyButton(
                        color: Colors.blue,
                        text: 'Save',
                        onPressed: _submitProduct)),
              ],
            ),
          ),
        ));
  }
}
