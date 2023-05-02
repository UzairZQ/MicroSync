import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:micro_pharma/models/order_model.dart';

class OrderDataProvider {
  final CollectionReference _ordersCollection =
      FirebaseFirestore.instance.collection('orders');

  Future<List<OrderModel>> getOrders() async {
    QuerySnapshot snapshot = await _ordersCollection.get();
    List<OrderModel> orders = snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return OrderModel.fromMap(data);
    }).toList();
    return orders;
  }

  Future<void> addOrder(OrderModel order) async {
    final docRef = _ordersCollection.doc();
    final newOrder = order.copyWith(id: docRef.id);
    await docRef.set(newOrder.toMap());
  }

  Future<void> updateOrder(OrderModel order) async {
    await _ordersCollection.doc(order.id).update(order.toMap());
  }

  Future<void> deleteOrder(String orderId) async {
    await _ordersCollection.doc(orderId).delete();
  }
}
