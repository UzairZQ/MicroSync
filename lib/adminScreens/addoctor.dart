import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/main.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/adminScreens/add_employees.dart';
import '../userScreens/login_page.dart';

final _formkey = GlobalKey<FormState>();

class Addoctor extends StatelessWidget {
  const Addoctor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(appBartxt: 'Add Doctor'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(18.0),
            child: Form(
              key: _formkey,
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'Area',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    subtitle: Column(children: [
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Enter text here',
                          contentPadding: EdgeInsets.only(top: 3),
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Doctor Code',
                          contentPadding: EdgeInsets.only(top: 3),
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Doctor Name',
                          contentPadding: EdgeInsets.only(top: 3),
                        ),
                        
                      ),
                    ]),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  ListTile(
                    title: Text(
                      'Category',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    subtitle: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Select Category',
                            contentPadding: EdgeInsets.only(top: 3),
                          ),
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Select Degree',
                            contentPadding: EdgeInsets.only(top: 3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  ListTile(
                    title: Text(
                      'Specialization',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    subtitle: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Select Category',
                            contentPadding: EdgeInsets.only(top: 3),
                          ),
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Business Potential',
                            contentPadding: EdgeInsets.only(top: 3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  MyButton(
                      color: Colors.blue,
                      text: 'Save',
                      onPressed: () {
                        if (_formkey.currentState!.validate()) {
                          _formkey.currentState!.save();
                        }
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
