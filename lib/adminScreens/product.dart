import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';

class ProductCatalogPage extends StatelessWidget {
  final List<Map<String, dynamic>> products = [
    {
      'product_name': 'Product A',
      'trade_price': '10.00',
      'retail_price': '15.00',
    },
    {
      'product_name': 'Product B',
      'trade_price': '20.00',
      'retail_price': '25.00',
    },
    {
      'product_name': 'Product C',
      'trade_price': '30.00',
      'retail_price': '35.00',
    },
    {
      'product_name': 'Product D',
      'trade_price': '40.00',
      'retail_price': '45.00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(appBartxt: 'Product Catalog'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: Container(
            color: Colors.blueGrey[700],
            child: Table(
              // columnWidths: ,
              columnWidths: {
                0: FixedColumnWidth(
                    150), // set width of first column to 100 pixels
                1: FlexColumnWidth(), // set width of second column to flex
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder.all(
                color: Colors.black,
                width: 1.0,
                style: BorderStyle.solid,
              ),
              children: [
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        // padding: EdgeInsets.all(5),
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Text(
                          'Product Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        // padding: EdgeInsets.all(5),
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Text(
                          'Trade Price',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        // padding: EdgeInsets.all(5),
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Text(
                          'Retail Price',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ...products.map((product) {
                  return TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                            // padding: EdgeInsets.all(5),
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Text(product['product_name'])),
                      ),
                      TableCell(
                        child: Padding(
                            // padding: EdgeInsets.all(5),
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Text('\PKR  ${product['trade_price']}')),
                      ),
                      TableCell(
                        child: Padding(
                            // padding: EdgeInsets.all(5),
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Text('\PKR  ${product['retail_price']}')),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
