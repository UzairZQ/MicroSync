import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/models/product_model.dart';



class ProductDataProvider with ChangeNotifier {
  List<ProductModel> _productsList = [];

  List<ProductModel> get productsList => _productsList;

  Future<void> fetchProductsList() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('products').get();
      final productsList = querySnapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data()))
          .toList();
      if (productsList != _productsList) {
        _productsList = productsList;
        notifyListeners();
      }
    } catch (e) {
      print('Error in the fetch products function $e');
      return;
    }
  }

  void addProduct(ProductModel product) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .add(product.toMap());
      notifyListeners();
    } catch (e) {
      print('Error in adding product: $e');
      return;
    }
  }

  void updateProduct(String productId, ProductModel newProduct) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update(newProduct.toMap());
      notifyListeners();
    } catch (e) {
      print('Error in updating product: $e');
      return;
    }
  }

  void deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();
      notifyListeners();
    } catch (e) {
      print('Error in deleting product: $e');
      return;
    }
  }
}
