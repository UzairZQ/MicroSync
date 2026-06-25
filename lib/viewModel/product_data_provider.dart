import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/models/product_model.dart';

import '../components/constants.dart';

class ProductDataProvider with ChangeNotifier {
  List<ProductModel> _productsList = [];
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ProductModel> get productsList => _productsList;

  bool _isLoading = false;
  bool get isLoadin => _isLoading;

  Future<void> fetchProductsList() async {
    try {
      _isLoading = true;
      notifyListeners();
      final querySnapshot =
          await FirebaseFirestore.instance.collection('products').get();
      final productsList = querySnapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data()))
          .toList();
      productsList.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      _productsList = productsList;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  static Future<bool> addProduct({
    required String name,
    required int code,
    required String packing,
  }) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState;
      try {
        showDialog(
            context: navigatorKey.currentContext!,
            builder: ((context) {
              return Builder(builder: (context) {
                return const Center(child: CircularProgressIndicator());
              });
            }));
        await _firestore.collection('products').add({
          'name': name,
          'code': code,
          'packing': packing,
        });
        Navigator.pop(navigatorKey.currentContext!);

        showCustomDialog(
            context: navigatorKey.currentContext!,
            title: 'Success',
            content: 'Product added successfully');
        return true;
      } on FirebaseException catch (error) {
        if (Navigator.canPop(navigatorKey.currentContext!)) {
          Navigator.pop(navigatorKey.currentContext!);
        }
        showCustomDialog(
            context: navigatorKey.currentContext!,
            title: 'Failure',
            content: error.message ?? 'An error occurred. Please try again.');
        return false;
      }
    }
    return false;
  }

  Future<bool> editProduct(int productCode, ProductModel? newProduct) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('code', isEqualTo: productCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final productDoc = querySnapshot.docs.first;
        final existingProduct = ProductModel.fromMap(productDoc.data());

        final updatedProduct = existingProduct.copyWith(
          name: newProduct?.name ?? existingProduct.name,
          packing: newProduct?.packing ?? existingProduct.packing,
        );

        await productDoc.reference.update(updatedProduct.toMap());
        await fetchProductsList();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProduct(int productCode) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('code', isEqualTo: productCode)
          .get();

      if (querySnapshot.size > 0) {
        final productDoc = querySnapshot.docs.first;
        await productDoc.reference.delete();
      } else {
        return false;
      }

      await fetchProductsList();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
