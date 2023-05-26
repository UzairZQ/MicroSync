import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class ExportData extends StatelessWidget {
  const ExportData({super.key});

  Future<void> addProductsToFirestore() async {
    String csvData = await rootBundle.loadString('assets/products.csv');

    List<List<dynamic>> csvList = const LineSplitter()
        .convert(csvData)
        .map((line) => line.split(','))
        .toList();

    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('products');

    for (List<dynamic> row in csvList) {
      int code = int.parse(row[0]);
      String name = row[1].toString();
      String packing = row[2].toString();
      double trp = double.parse(row[3]);
      double mrp = double.parse(row[4]);

      Map<String, dynamic> productData = {
        'name': name,
        'code': code,
        'packing': packing,
        'mrp': mrp,
        'trp': trp,
      };

      await collectionRef.add(productData);
    }
    print('added products to database');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(appBartxt: 'Export Data to Firestore'),
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          children: [MyButton(text: 'Export Products', onPressed: () {})],
        ),
      ),
    );
  }
}
