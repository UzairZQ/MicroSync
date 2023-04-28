import 'package:flutter/material.dart';
import 'package:micro_pharma/adminScreens/add_product.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:provider/provider.dart';
import 'package:micro_pharma/providers/product_data_provider.dart';

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
                                fontSize: 18.0,
                                fontWeight: FontWeight.w700,
                              ),
                              const SizedBox(height: 8.0),
                              MyTextwidget(
                                text: 'Packing: ${product.packing}',
                                fontSize: 16.0,
                              ),
                              const SizedBox(height: 8.0),
                              MyTextwidget(
                                text: 'Retail Price: ${product.retailPrice}',
                                fontSize: 16.0,
                              ),
                              const SizedBox(height: 8.0),
                              MyTextwidget(
                                text: 'Trade Price: ${product.tradePrice}',
                                fontSize: 16.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            color: Colors.green,
                            onPressed: () {
                              // Navigate to the edit screen
                            },
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
                                          provider.deleteProduct(
                                              product.code.toString());
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
        label: const MyTextwidget(
          text: 'Add New Product',
          fontSize: 14,
        ),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
