import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import '../userScreens/login_page.dart';
import 'package:micro_pharma/main.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  final _codeController = TextEditingController();
  final _tradePriceController = TextEditingController();
  final _retailPriceController = TextEditingController();

  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      final productName = _productController.text;
      final quantity = int.parse(_codeController.text);
      final retailPrice = double.parse(_retailPriceController.text);
      final tradePrice = double.parse(_tradePriceController.text);

      _formKey.currentState;

      // TODO: Send order details to pharmacy
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
          title: Text('New Order'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(15),
              children: [
                Padding(padding: EdgeInsets.fromLTRB(5, 5, 5, 0)),
                TextFormField(
                  controller: _productController,
                  decoration: InputDecoration(labelText: 'Medicine Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter product name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(labelText: ' Product Code'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter quantity';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _retailPriceController,
                  onChanged: _updateTradePrice,
                  decoration: InputDecoration(labelText: 'Retail Price'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Pleas enter trade price';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _tradePriceController,
                  enabled: false,
                  decoration:
                      InputDecoration(labelText: ' Trade Price(15% less)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter trade price';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: MyButton(
                        color: Colors.blue,
                        text: 'Save',
                        onPressed: _submitOrder)),
              ],
            ),
          ),
        ));
  }
}
