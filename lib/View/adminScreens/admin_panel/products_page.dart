import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:provider/provider.dart';
import 'package:micro_pharma/viewModel/product_data_provider.dart';

import '../../../models/product_model.dart';
import 'add_product.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        appBartxt: 'Products',
      ),
      body: Consumer<ProductDataProvider>(
        builder: (context, provider, child) {
          provider.fetchProductsList();

          final productsList = provider.productsList;

          return ListView.builder(
            shrinkWrap: true,
            itemCount: productsList.length,
            itemBuilder: (context, index) {
              final product = productsList[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyTextwidget(
                                text: product.name,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                              ),
                              const SizedBox(height: 8.0),
                              MyTextwidget(
                                text: 'Packing: ${product.packing}',
                                fontSize: 14.0,
                              ),
                              const SizedBox(height: 8.0),
                              MyTextwidget(
                                text: 'Retail Price: ${product.retailPrice}',
                                fontSize: 14.0,
                              ),
                              const SizedBox(height: 8.0),
                              MyTextwidget(
                                text: 'Trade Price: ${product.tradePrice}',
                                fontSize: 14.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                isScrollControlled: true,
                                constraints: BoxConstraints.loose(
                                    const Size.fromHeight(600)),
                                context: context,
                                builder: (BuildContext context) {
                                  return EditProductBottomSheet(
                                      product: product);
                                },
                              );
                            },
                            child: const Icon(
                              (Icons.edit),
                              color: Colors.green,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Delete Product?'),
                                    content: const Text(
                                        'Are you sure you want to delete this product?'),
                                    actions: [
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Delete'),
                                        onPressed: () {
                                          provider.deleteProduct(product.code);
                                          provider.fetchProductsList();
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AddProduct.id);
        },
        label: MyTextwidget(
          text: 'Add New Product',
          fontSize: 14,
        ),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class EditProductBottomSheet extends StatefulWidget {
  final ProductModel product;

  const EditProductBottomSheet({Key? key, required this.product})
      : super(key: key);

  @override
  State<EditProductBottomSheet> createState() => _EditProductBottomSheetState();
}

class _EditProductBottomSheetState extends State<EditProductBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _packingController = TextEditingController();
  final TextEditingController _retailPriceController = TextEditingController();
  final TextEditingController _tradePriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with the product details
    _nameController.text = widget.product.name;
    _packingController.text = widget.product.packing;
    _retailPriceController.text = widget.product.retailPrice.toString();
    _tradePriceController.text = widget.product.tradePrice.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _packingController.dispose();
    _retailPriceController.dispose();
    _tradePriceController.dispose();
    super.dispose();
  }

  void saveChanges() {
    // Create a new ProductModel object with the updated details
    ProductModel updatedProduct = ProductModel(
      code: widget.product.code,
      name: _nameController.text,
      packing: _packingController.text,
      retailPrice: double.parse(_retailPriceController.text),
      tradePrice: double.parse(_tradePriceController.text),
    );

    // Call the editProduct method to update the product in Firestore
    Provider.of<ProductDataProvider>(context, listen: false)
        .editProduct(widget.product.code, updatedProduct);

    // Close the bottom sheet
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 650,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
          ),
          TextField(
            controller: _packingController,
            decoration: const InputDecoration(
              labelText: 'Packing',
            ),
          ),
          TextField(
            controller: _retailPriceController,
            decoration: const InputDecoration(
              labelText: 'Retail Price',
            ),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _tradePriceController,
            decoration: const InputDecoration(
              labelText: 'Trade Price',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: saveChanges,
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
