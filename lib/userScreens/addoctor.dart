import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/main.dart';
import 'package:flutter/material.dart';

final _formkey = GlobalKey<FormState>();

class Addoctor extends StatelessWidget {
  const Addoctor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(appBartxt: 'Add Doctor'),
      body: Padding(
        padding: EdgeInsets.all(18.0),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(hintText: 'Area',
                labelText: 'Area'),

               validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter Something';
                  }
                  return null;
                },
              ),
               
              
            ],
          ),
        ),
      ),
    );
  }
}
