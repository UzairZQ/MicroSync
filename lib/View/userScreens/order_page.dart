import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/models/area_model.dart';
import 'package:micro_pharma/models/order_model.dart';
import 'package:micro_pharma/models/product_model.dart';
import 'package:micro_pharma/viewModel/area_provider.dart';
import 'package:micro_pharma/viewModel/order_data_provider.dart';
import 'package:micro_pharma/viewModel/product_data_provider.dart';
import 'package:micro_pharma/viewModel/user_data_provider.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  @override
  OrderScreenState createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen> {
  late String currentUserId;
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
    currentUserId = FirebaseAuth.instance.currentUser!.uid;

    super.initState();
    // Fetch products when the screen initializes
    Provider.of<ProductDataProvider>(context, listen: false)
        .fetchProductsList();
    Provider.of<AreaProvider>(context, listen: false).fetchAreas();
    Provider.of<UserDataProvider>(context, listen: false)
        .fetchUserData(currentUserId);
  }

  @override
  void dispose() {
    _bonusController.dispose();
    _customerNameController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductDataProvider>(context);
    final List<ProductModel> products = productProvider.productsList;
    areas = Provider.of<AreaProvider>(context).getAreas;
    final userData =
        Provider.of<UserDataProvider>(context, listen: false).getUserData;

    double discountedTotal = total - (total * (discount / 100));

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
                            // Check if any of the required fields are empty
                            if (_productQuantityController.text.isEmpty) {
                              return; // Do nothing if quantity field is empty
                            }
                            // Calculate the total price of the selected product
                            final OrderSelectedProduct orderSelectedProduct =
                                OrderSelectedProduct(
                              code: selectedProduct!.code,
                              packing: selectedProduct!.packing,
                              retailPrice: selectedProduct!.retailPrice,
                              name: selectedProduct!.name,
                              tradePrice: selectedProduct!.tradePrice,
                              quantity: _productQuantityController.text,
                              bonus: _bonusController.text.isNotEmpty
                                  ? _bonusController.text
                                  : '0',
                              discount: _discountController.text.isNotEmpty
                                  ? _discountController.text
                                  : '0.0',
                            );

                            double totalPrice =
                                orderSelectedProduct.tradePrice *
                                    int.parse(orderSelectedProduct.quantity);

                            // Apply the discount to the total price of the selected product
                            double discountPercentage = double.tryParse(
                                    orderSelectedProduct.discount!) ??
                                0.0;
                            totalPrice -=
                                (totalPrice * (discountPercentage / 100));

                            // Update the total value
                            total += totalPrice;

                            // Update the total discount
                            discount =
                                selectedProducts.fold(0.0, (sum, product) {
                              double productDiscount =
                                  double.tryParse(product.discount!) ?? 0.0;
                              return sum + productDiscount;
                            });

                            selectedProducts.add(orderSelectedProduct);

                            // Clear the input fields
                            _productQuantityController.clear();
                            _bonusController.clear();
                            _discountController.clear();
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
                    double totalPrice =
                        product.tradePrice * int.parse(product.quantity);

                    // Apply the discount to the total price of the selected product
                    totalPrice -=
                        (totalPrice * (double.parse(product.discount!) / 100));
                    return selectedProductsList(product, totalPrice, index);
                  },
                ),
                const SizedBox(height: 16.0),
                MyTextwidget(
                  fontWeight: FontWeight.bold,
                  text: 'Total: $total',
                ),
                const SizedBox(height: 8.0),
                MyTextwidget(
                  fontWeight: FontWeight.bold,
                  text:
                      'Sub Total: $discountedTotal', // Display the discounted total
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              // Perform any additional logic for placing the order

              OrderModel orderModel = OrderModel(
                  userName: userData.displayName!,
                  date: DateTime.now(),
                  products: selectedProducts,
                  customerName: _customerNameController.text,
                  area: selectedArea!.areaName,
                  total: total,
                  subTotal: discountedTotal);
              await Provider.of<OrderDataProvider>(context, listen: false)
                  .addOrder(orderModel);
              showCustomDialog(
                  context: navigatorKey.currentContext!,
                  title: 'Order Sent',
                  content: 'Order Successfully Submitted!');

              // Clear the form fields
              _formKey.currentState!.reset();
              setState(() {
                selectedProducts.clear();
              });
            }
          },
          label: MyTextwidget(
            text: 'Place Order',
          ),
          icon: const Icon(Icons.shopping_cart_checkout)),
    );
  }

  Card selectedProductsList(OrderSelectedProduct product, double totalPrice, int index) {
    return Card(
                    color: Colors.amber[100],
                    child: ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                          'Quantity: ${product.quantity}, Bonus: ${product.bonus}, Discount: ${product.discount}% \n Value: $totalPrice'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            // Update the total value
                            total -= (product.tradePrice *
                                int.parse(product.quantity));
                            selectedProducts.removeAt(index);

                            // Update the total discount
                            discount =
                                selectedProducts.fold(0.0, (sum, product) {
                              return sum + double.parse(product.discount!);
                            });
                          });
                        },
                      ),
                    ),
                  );
  }
}
