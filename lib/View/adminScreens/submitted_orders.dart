import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:micro_pharma/models/order_model.dart';

import '../../components/constants.dart';
import '../../viewModel/order_data_provider.dart';

class SubmittedOrders extends StatelessWidget {
  static const String id = 'submitted_orders';

  const SubmittedOrders({super.key});
  @override
  Widget build(BuildContext context) {
    final orderProvider =
        Provider.of<OrderDataProvider>(context, listen: false);

    return Scaffold(
      appBar: const MyAppBar(appBartxt: 'Orders'),
      body: FutureBuilder(
        future: orderProvider.fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error occurred: ${snapshot.error}'));
          } else {
            final List<OrderModel> orders = orderProvider.getOrders;
            orders.sort((a, b) => b.date.compareTo(a.date));

            if (orders.isEmpty) {
              return const Center(child: Text('No orders found.'));
            } else {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      color: Colors.amber[100],
                      child: ListTile(
                        title: MyTextwidget(
                          text: ' ${order.customerName}',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        subtitle:
                            Text('Area: ${order.area} \nDate: ${order.date}'),
                        onTap: () {
                          _showOrderDetails(context, order);
                        },
                      ),
                    );
                  },
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showOrderDetails(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.green[50],
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: MyTextwidget(
                    text: 'Order Details',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Order ID: ${order.id}'),
                const SizedBox(height: 10),
                MyTextwidget(
                  text: 'Medical Store: ${order.customerName}',
                  fontSize: 16,
                ),
                const SizedBox(height: 10),
                MyTextwidget(
                  text: 'Area: ${order.area}',
                  fontSize: 16,
                ),
                const SizedBox(height: 10),
                MyTextwidget(
                  text: 'Products:',
                  fontSize: 16,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: order.products.length,
                  itemBuilder: (context, index) {
                    final product = order.products[index];
                    return Card(
                      color: Colors.yellow[100],
                      child: ListTile(
                        title: MyTextwidget(
                          text: product.name,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyTextwidget(
                              text: 'Quantity: ${product.quantity}',
                              fontSize: 15,
                            ),
                            MyTextwidget(
                                text: 'Bonus: ${product.bonus ?? '0'}',
                                fontSize: 15),
                            MyTextwidget(
                              text: 'Discount: ${product.discount ?? '0.0'}',
                              fontSize: 15,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                MyTextwidget(
                  text: 'Total: ${order.total}',
                  fontSize: 18,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
