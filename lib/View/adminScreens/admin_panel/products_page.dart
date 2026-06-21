import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:provider/provider.dart';
import 'package:micro_pharma/viewModel/product_data_provider.dart';

import '../../../models/product_model.dart';
import 'add_product.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductDataProvider>().fetchProductsList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        appBartxt: 'Products',
      ),
      body: Consumer<ProductDataProvider>(
        builder: (context, provider, child) {
          final productsList = provider.productsList
              .where((product) =>
                  product.name.toLowerCase().contains(_query.toLowerCase()) ||
                  product.code.toString().contains(_query))
              .toList();

          if (provider.isLoadin && provider.productsList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: provider.fetchProductsList,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              itemCount: productsList.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search medicines by name or code',
                      ),
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  );
                }

                final product = productsList[index - 1];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                    title: MyTextwidget(
                      text: product.name,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Code ${product.code} • ${product.packing}\nRetail ${product.retailPrice.toStringAsFixed(2)} • Trade ${product.tradePrice.toStringAsFixed(2)}',
                      ),
                    ),
                    trailing: Wrap(
                      spacing: 2,
                      children: [
                        IconButton(
                          tooltip: 'Edit medicine',
                          icon: const Icon(Icons.edit_outlined),
                          color: Colors.green,
                          onPressed: () {
                            showModalBottomSheet(
                              isScrollControlled: true,
                              constraints: BoxConstraints.loose(
                                  const Size.fromHeight(600)),
                              context: context,
                              builder: (BuildContext context) {
                                return EditProductBottomSheet(product: product);
                              },
                            );
                          },
                        ),
                        IconButton(
                          tooltip: 'Delete medicine',
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete Product?'),
                                  content: Text(
                                      'Delete ${product.name} from medicines?'),
                                  actions: [
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Delete'),
                                      onPressed: () async {
                                        final navigator = Navigator.of(context);
                                        final messenger =
                                            ScaffoldMessenger.of(context);
                                        final deleted = await provider
                                            .deleteProduct(product.code);
                                        navigator.pop();
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(deleted
                                                ? 'Product deleted'
                                                : 'Could not delete product'),
                                          ),
                                        );
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
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AddProduct.id);
        },
        label: const MyTextwidget(
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

  const EditProductBottomSheet({super.key, required this.product});

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

  Future<void> saveChanges() async {
    final retailPrice = double.tryParse(_retailPriceController.text.trim());
    final tradePrice = double.tryParse(_tradePriceController.text.trim());
    if (_nameController.text.trim().isEmpty ||
        _packingController.text.trim().isEmpty ||
        retailPrice == null ||
        tradePrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Enter valid medicine details and prices')),
      );
      return;
    }

    // Create a new ProductModel object with the updated details
    ProductModel updatedProduct = ProductModel(
      code: widget.product.code,
      name: _nameController.text.trim(),
      packing: _packingController.text.trim(),
      retailPrice: retailPrice,
      tradePrice: tradePrice,
    );

    // Call the editProduct method to update the product in Firestore
    final saved = await Provider.of<ProductDataProvider>(context, listen: false)
        .editProduct(widget.product.code, updatedProduct);

    // Close the bottom sheet
    if (!mounted) {
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(saved ? 'Product updated' : 'Could not update product'),
      ),
    );
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
