import 'package:flutter/material.dart';

import 'package:micro_pharma/components/constants.dart';

class Areas extends StatelessWidget {
  Areas({super.key});
  TextEditingController areaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(appBartxt: 'Areas'),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // Navigator.push(context,
            //     MaterialPageRoute(builder: ((context) => AddArea())));
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                    child: Form(
                      // key: _formkey,
                      child: Column(
                        children: [
                          ListTile(
                            title: const Center(
                              child: Text(
                                'Area',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            subtitle: Column(
                              children: [
                                TextFormField(
                                  decoration: const InputDecoration(
                                    hintText: 'Please Enter Area Name',
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          MyButton(
                              color: Colors.blue,
                              text: 'Save',
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  formKey.currentState!.save();
                                }
                              }),
                        ],
                      ),
                    ),
                  );
                });
          },
          label: const Text('Add Area')),
    );
  }
}
