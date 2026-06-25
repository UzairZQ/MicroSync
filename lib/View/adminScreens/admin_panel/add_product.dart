import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/viewModel/product_data_provider.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});
  static const String id = 'addproduct';
  @override
  AddProductState createState() => AddProductState();
}

class AddProductState extends State<AddProduct> {
  final _productController = TextEditingController();
  final _codeController = TextEditingController();
  final _packingController = TextEditingController();

  void _submitProduct() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    final code = int.tryParse(_codeController.text.trim());
    if (code == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid product code')),
      );
      return;
    }

    final added = await ProductDataProvider.addProduct(
      name: _productController.text.trim(),
      code: code,
      packing: _packingController.text.trim(),
    );
    if (!added) {
      return;
    }
    _codeController.clear();
    _productController.clear();
    _packingController.clear();
  }

  @override
  void dispose() {
    _productController.dispose();
    _codeController.dispose();
    _packingController.dispose();

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
            key: formKey,
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
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid product code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _packingController,
                  decoration: const InputDecoration(labelText: ' Packing'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter packing ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
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
