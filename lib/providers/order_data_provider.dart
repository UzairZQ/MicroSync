import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:micro_pharma/models/order_model.dart';

class OrderDataProvider with ChangeNotifier {
  List<OrderModel> orders = [];
  final CollectionReference _ordersCollection =
      FirebaseFirestore.instance.collection('orders');
  List<OrderModel> get getOrders => orders;

  Future<void> fetchOrders() async {
    try {
      QuerySnapshot snapshot = await _ordersCollection.get();
      orders = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return OrderModel.fromMap(data);
      }).toList();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> addOrder(OrderModel order) async {
    final docRef = _ordersCollection.doc();
    final newOrder = order.copyWith(id: docRef.id);
    await docRef.set(newOrder.toMap());
    notifyListeners();
  }

  Future<void> updateOrder(OrderModel order) async {
    await _ordersCollection.doc(order.id).update(order.toMap());
    notifyListeners();
  }

  Future<void> deleteOrder(String orderId) async {
    await _ordersCollection.doc(orderId).delete();
    notifyListeners();
  }
}
