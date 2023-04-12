import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:micro_pharma/adminScreens/add_area.dart';
import 'package:micro_pharma/components/constants.dart';

class Areas extends StatelessWidget {
  const Areas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(appBartxt: 'Areas'),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: ((context) => AddArea())));
          
          },
          label: Text('Add Area')),
    );
  }
}
