import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/models/area_model.dart';
import 'package:micro_pharma/models/product_model.dart';
import 'package:micro_pharma/providers/area_provider.dart';
import 'package:micro_pharma/providers/product_data_provider.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<AreaModel> areas = [];
  List<OrderSelectedProduct> selectedProducts = [];
  double total = 0.0;
  double discount = 0.0;
  AreaModel? selectedArea;

  ProductModel? selectedProduct;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _productQuantityController =
      TextEditingController();
  final TextEditingController _bonusController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch products when the screen initializes
    Provider.of<ProductDataProvider>(context, listen: false)
        .fetchProductsList();
    Provider.of<AreaProvider>(context, listen: false).fetchAreas();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductDataProvider>(context);
    final List<ProductModel> products = productProvider.productsList;
    areas = Provider.of<AreaProvider>(context).getAreas;

    double discountedTotal = total - (total * discount / 100);

    return Scaffold(
      appBar: const MyAppBar(appBartxt: 'Order Screen'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _customerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) {
                    _customerNameController.text = value!;
                  },
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<AreaModel>(
                  value: selectedArea,
                  onChanged: (newValue) {
                    setState(() {
                      selectedArea = newValue!;
                    });
                  },
                  items: areas.map((area) {
                    return DropdownMenuItem<AreaModel>(
                      value: area,
                      child: Text(area.areaName),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Area',
                    hintText: 'Select Area',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<ProductModel>(
                  value: selectedProduct,
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedProduct = newValue;
                      });
                    }
                  },
                  items: products.map((product) {
                    return DropdownMenuItem<ProductModel>(
                      value: product,
                      child: Text(product.name),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Products',
                    hintText: 'Select products',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _productQuantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value) {
                          _productQuantityController.text = value!;
                        },
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: TextFormField(
                        controller: _bonusController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Bonus',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value) {
                          _bonusController.text = value!;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _discountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Discount',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value) {
                          setState(() {
                            _discountController.text = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        child: MyTextwidget(text: 'Add to List'),
                        onPressed: () {
                          setState(() {
                            // Calculate the total price of the selected product
                            final OrderSelectedProduct orderSelectedProduct =
                                OrderSelectedProduct(
                                    code: selectedProduct!.code,
                                    packing: selectedProduct!.packing,
                                    retailPrice: selectedProduct!.retailPrice,
                                    name: selectedProduct!.name,
                                    tradePrice: selectedProduct!.tradePrice,
                                    quantity: int.parse(
                                        _productQuantityController.text),
                                    bonus: int.parse(_bonusController.text),
                                    discount:
                                        double.parse(_discountController.text));

                            double totalPrice =
                                orderSelectedProduct.tradePrice *
                                    orderSelectedProduct.quantity;

                            // Apply the discount to the total price of the selected product
                            totalPrice -= (totalPrice *
                                (orderSelectedProduct.discount! / 100));

                            // Update the total value
                            total += totalPrice;

                            selectedProducts.add(orderSelectedProduct);

                            // Clear the input fields

                            _productQuantityController.clear();
                            _bonusController.clear();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: selectedProducts.length,
                  itemBuilder: (context, index) {
                    final product = selectedProducts[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                          'Quantity: ${product.quantity}, Bonus: ${product.bonus}, Discount: ${product.discount}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            // Update the total value
                            total -= (product.tradePrice * product.quantity);
                            selectedProducts.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16.0),
                MyTextwidget(
                  fontWeight: FontWeight.bold,
                  text: 'Total: $total',
                ),
                const SizedBox(height: 8.0),
                MyTextwidget(
                  text: 'Discount: $discount%', // Display the applied discount
                ),
                const SizedBox(height: 8.0),
                MyTextwidget(
                  fontWeight: FontWeight.bold,
                  text:
                      'Sub Total: $discountedTotal', // Display the discounted total
                ),
                const SizedBox(height: 16.0),
                MyButton(text: 'Place Order', onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
