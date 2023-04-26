
import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/services/database_service.dart';
import 'package:micro_pharma/userScreens/home_page.dart';

class DoctorsPage extends StatelessWidget {
  DoctorsPage({super.key});
  TextEditingController doctorNameController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController specializationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // Navigator.push(context,
            //     MaterialPageRoute(builder: ((context) => const AddDoctor()),));
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: ((context) {
                return GestureDetector(
                  onTap: () {
                    // dismiss the keyboard when the user taps outside the text fields
                    FocusScope.of(context).unfocus();
                  },
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 1.2,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text(
                                'Name & Area',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              subtitle: Column(
                                children: [
                                  TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please Enter Doctor Name';
                                      }
                                      return null;
                                    },
                                    onSaved: (name) {
                                      doctorNameController.text = name!;
                                    },
                                    decoration: const InputDecoration(
                                      hintText: 'Enter Doctor Name',
                                      contentPadding: EdgeInsets.only(top: 3),
                                    ),
                                  ),
                                  TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please Select Area';
                                      }
                                      return null;
                                    },
                                    onSaved: (area) {
                                      areaController.text = area!;
                                    },
                                    decoration: const InputDecoration(
                                      hintText: 'Select Area',
                                      contentPadding: EdgeInsets.only(top: 3),
                                      border: UnderlineInputBorder(),
                                    ),
                                  ),
                                  TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please Enter Doctor\'s Address';
                                      }
                                      return null;
                                    },
                                    onSaved: (address) {
                                      addressController.text = address!;
                                    },
                                    //skdafsgit
                                    decoration: const InputDecoration(
                                      hintText: 'Enter Address',
                                      contentPadding: EdgeInsets.only(top: 3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            ListTile(
                              title: const Text(
                                'Specialization',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              subtitle: Column(
                                children: [
                                  TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please Enter Phone Number';
                                      }
                                      return null;
                                    },
                                    onSaved: (category) {
                                      specializationController.text = category!;
                                    },
                                    decoration: const InputDecoration(
                                      hintText: 'Select Category',
                                      contentPadding: EdgeInsets.only(top: 3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            MyButton(
                              color: Colors.blue,
                              text: 'Save',
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  formKey.currentState!.save();
                                  DatabaseService.addDoctor(
                                    doctorNameController.text,
                                    areaController.text,
                                    addressController.text,
                                    specializationController.text,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
          label: const Text('Add Doctor')),
      appBar: AppBar(
        backgroundColor: kappbarColor,
        centerTitle: true,
        title: const MyTextwidget(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          text: 'Doctors',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ));
            },
          ),
        ],
      ),

      // appBar: MyAppBar(appBartxt: 'Visited Doctors'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(10)),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.blueGrey[900],
                  ),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      8.0,
                    ),
                  ),
                ),
              ),
              // Expanded(child: Container())
            ],
          ),
        ),
      ),
    );
  }
}
