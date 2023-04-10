import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import '../userScreens/login_page.dart';

final _formkey = GlobalKey<FormState>();

class Addarea extends StatelessWidget {
  const Addarea({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(appBartxt: 'Add Area'),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
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
                  subtitle: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Add Area',
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Area type',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                ListTile(
                  title: Text(
                    'Area Type',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  subtitle: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Area Type',
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 25,
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
      )),
    );
  }
}
