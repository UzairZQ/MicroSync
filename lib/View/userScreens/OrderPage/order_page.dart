import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/models/area_model.dart';
import 'package:micro_pharma/models/order_model.dart';
import 'package:micro_pharma/models/product_model.dart';
import 'package:micro_pharma/models/user_model.dart';
import 'package:micro_pharma/viewModel/area_provider.dart';
import 'package:micro_pharma/viewModel/order_data_provider.dart';
import 'package:micro_pharma/viewModel/product_data_provider.dart';
import 'package:micro_pharma/viewModel/user_data_provider.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  OrderScreenState createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen> {
  late String currentUserId;
  List<AreaModel> areas = [];
  List<OrderSelectedProduct> selectedProducts = [];
  AreaModel? selectedArea;

  ProductModel? selectedProduct;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _productQuantityController =
      TextEditingController();
  final TextEditingController _bonusController = TextEditingController();
  final TextEditingController _discountController = TextEditingController(text: '0');

  @override
  void initState() {
    final user = FirebaseAuth.instance.currentUser;
    super.initState();
    if (user == null) {
      return;
    }
    currentUserId = user.uid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.wait([
        context.read<ProductDataProvider>().fetchProductsList(),
        context.read<AreaProvider>().fetchAreas(),
        context.read<UserDataProvider>().fetchUserData(currentUserId),
      ]);
    });
  }

  @override
  void dispose() {
    _bonusController.dispose();
    _customerNameController.dispose();
    _productQuantityController.dispose();
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
                    prefixIcon: Icon(Icons.store),
                    labelText: 'Customer Name',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) {
                    _customerNameController.text = value?.trim() ?? '';
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter customer name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<AreaModel>(
                  initialValue: selectedArea,
                  onChanged: (newValue) {
                    setState(() => selectedArea = newValue);
                  },
                  items: areas.map((area) {
                    return DropdownMenuItem<AreaModel>(
                      value: area,
                      child: Text(area.areaName),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_pin),
                    labelText: 'Area',
                    hintText: 'Select Area',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select an area';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                Autocomplete<ProductModel>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<ProductModel>.empty();
                    }
                    return products.where((product) => product.name
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()));
                  },
                  displayStringForOption: (ProductModel option) => option.name,
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.shopping_cart_outlined),
                        labelText: 'Products',
                        hintText: 'Select products',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        // If you want to do something when the user types in the search field
                      },
                    );
                  },
                  onSelected: (ProductModel selection) {
                    setState(() {
                      selectedProduct = selection;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _productQuantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.numbers),
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value) {
                          _productQuantityController.text = value ?? '';
                        },
                        validator: (value) {
                          if (selectedProducts.isNotEmpty &&
                              (value == null || value.trim().isEmpty)) {
                            return null;
                          }
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          final quantity = int.tryParse(value.trim());
                          if (quantity == null || quantity <= 0) {
                            return 'Enter a valid quantity';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: TextFormField(
                        controller: _bonusController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          // prefixIcon: Icon(Icons.),
                          labelText: 'Bonus',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value) {
                          _bonusController.text = value ?? '';
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          final bonus = int.tryParse(value.trim());
                          if (bonus == null || bonus < 0) {
                            return 'Enter a valid bonus';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _discountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.percent),
                    labelText: 'Discount (%)',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) {
                    _discountController.text = value ?? '0';
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null;
                    }
                    final discount = double.tryParse(value.trim());
                    if (discount == null || discount < 0 || discount > 100) {
                      return 'Enter a valid discount percentage (0-100)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: addProductToList(),
                ),
                const SizedBox(height: 16.0),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: selectedProducts.length,
                  itemBuilder: (context, index) {
                    final product = selectedProducts[index];
                    return selectedProductsList(product, index);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: submitOrderActionButton(userData, context),
    );
  }

  FloatingActionButton submitOrderActionButton(
      UserModel userData, BuildContext context) {
    return FloatingActionButton.extended(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();

            if (selectedProducts.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add at least one product before placing.'),
                ),
              );
              return;
            }

            if (selectedArea == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select an area.')),
              );
              return;
            }

            OrderModel orderModel = OrderModel(
                userName: userData.displayName ?? 'Unknown user',
                date: DateTime.now(),
                products: selectedProducts,
                customerName: _customerNameController.text,
                area: selectedArea?.areaName ?? '',
                discount: _discountController.text.trim().isEmpty
                    ? null
                    : double.tryParse(_discountController.text.trim()));
            await Provider.of<OrderDataProvider>(context, listen: false)
                .addOrder(orderModel);
            showCustomDialog(
                context: navigatorKey.currentContext!,
                title: 'Order Sent',
                content: 'Order Successfully Submitted!');

            // Clear the form fields
            _formKey.currentState!.reset();
            _discountController.clear();
            setState(() {
              selectedProducts.clear();
              selectedArea = null;
            });
          }
        },
        label: const MyTextwidget(
          text: 'Place Order',
        ),
        icon: const Icon(Icons.shopping_cart_checkout));
  }

  Widget addProductToList() {
    return TextButton.icon(
      icon: const Icon(Icons.add_shopping_cart_outlined),
      label: const MyTextwidget(text: 'Add to List'),
      onPressed: () {
        final quantity = int.tryParse(_productQuantityController.text.trim());
        final bonus = _bonusController.text.trim().isEmpty
            ? 0
            : int.tryParse(_bonusController.text.trim());

        if (selectedProduct == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Select a product first.')),
          );
          return;
        }

        if (quantity == null || quantity <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enter a valid quantity.')),
          );
          return;
        }

        if (bonus == null || bonus < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enter a valid bonus quantity.')),
          );
          return;
        }

        final product = selectedProduct!;
        final orderSelectedProduct = OrderSelectedProduct(
          code: product.code,
          packing: product.packing,
          name: product.name,
          quantity: quantity.toString(),
          bonus: bonus.toString(),
        );

        setState(() {
          selectedProducts.add(orderSelectedProduct);
          _productQuantityController.clear();
          _bonusController.clear();
        });
      },
    );
  }

  Card selectedProductsList(OrderSelectedProduct product, int index) {
    return Card(
      color: Colors.amber[100],
      child: ListTile(
        title: Text(product.name),
        subtitle: Text(
          'Order units: ${product.quantity}, Bonus units: ${product.bonus ?? '0'}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            setState(() {
              selectedProducts.removeAt(index);
            });
          },
        ),
      ),
    );
  }
}
