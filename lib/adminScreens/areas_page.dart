import 'package:flutter/material.dart';

import 'package:micro_pharma/components/constants.dart';

import '../services/database_service.dart';

class Areas extends StatelessWidget {
  // final formareaKey = GlobalKey<FormState>();

  Areas({super.key});
  final TextEditingController areaNameController = TextEditingController();
  final TextEditingController areaCodeController = TextEditingController();

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
                      key: formKey,
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
                                  onSaved: (name) {
                                    areaNameController.text = name!;
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Please Enter Area Name',
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                TextFormField(
                                  onSaved: (newValue) {
                                    areaCodeController.text = newValue!;
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'Please Enter Area Code',
                                  ),
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
                              text: 'Add Area',
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  formKey.currentState!.save();
                                  DatabaseService.addAreatoDatabase(
                                      areaNameController.text,
                                      areaCodeController.text);
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
