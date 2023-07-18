import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:micro_pharma/components/constants.dart';

import '../../services/database_service.dart';

class AddEmployees extends StatefulWidget {
  static const String id = 'add_doctor';
  const AddEmployees({super.key});

  @override
  State<AddEmployees> createState() => _AddEmployeesState();
}

class _AddEmployeesState extends State<AddEmployees> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  @override
  void dispose() {
    super.dispose();
    passwordController.dispose();
    emailController.dispose();
    nameController.dispose();
    roleController.dispose();
    phoneController.dispose();
    confpasController.dispose();
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController confpasController = TextEditingController();
  TextEditingController areacontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    //TextEditingController nameController = TextEditingController();
    return Scaffold(
      appBar: const MyAppBar(appBartxt: 'Add Users'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                MyTextFormField(
                  icon: const Icon(Icons.person),
                  hintext: 'Please Enter Name',
                  onSaved: (value) {
                    nameController.text = value!;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter name';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20.0,
                ),
                MyTextFormField(
                    icon: const Icon(Icons.email_outlined),
                    hintext: 'Please Enter Email',
                    onSaved: (value) {
                      emailController.text = value!;
                    },
                    validator: validateEmail),
                const SizedBox(
                  height: 20.0,
                ),
                MyTextFormField(
                  icon: const Icon(Icons.admin_panel_settings),
                  controller: roleController,
                  hintext: 'Please Enter Role(user or admin)',
                  onSaved: (value) {
                    roleController.text = value!;
                  },
                  validator: (role) {
                    if (role == 'user' || role == 'admin') {
                      return null;
                    } else if (role!.isEmpty) {
                      return 'Please Enter role';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                MyTextFormField(
                  icon: const Icon(Icons.phone),
                  controller: phoneController,
                  hintext: 'Enter Phone Number',
                  onSaved: (phone) {
                    phoneController.text = phone!;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please Enter Phone Number';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20.0,
                ),
                MyTextFormField(
                  icon: const Icon(Icons.lock),
                  controller: passwordController,
                  hintext: 'Please Enter Password',
                  onSaved: (value) {
                    passwordController.text = value!;
                  },
                  validator: (password) {
                    RegExp regex = RegExp(r'^.{6,}$');
                    if (password!.isEmpty) {
                      return 'Please Enter Password';
                    } else if (!regex.hasMatch(password)) {
                      return 'Enter Password with min. 6 Characters';
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(
                  height: 20.0,
                ),
                MyTextFormField(
                  icon: const Icon(Icons.lock),
                  controller: confpasController,
                  hintext: 'Enter Confirm Password',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please Enter Confirm Password';
                    }
                    if (passwordController.text == confpasController.text) {
                      return null;
                    } else if (passwordController.text !=
                        confpasController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    confpasController.text = value!;
                  },
                ),
                const SizedBox(
                  height: 20.0,
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyButton(
                        color: kappbarColor,
                        text: 'Create User',
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            createUser();
                          }
                        }),
                    MyButton(
                        color: const Color.fromARGB(255, 224, 57, 90),
                        text: 'Delete User',
                        onPressed: () {
                          deleteUserBottomSheet(
                              context, firebaseFirestore, firebaseAuth);
                        })
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> deleteUserBottomSheet(BuildContext context,
      FirebaseFirestore firebaseFirestore, FirebaseAuth firebaseAuth) {
    return showModalBottomSheet(
        isDismissible: true,
        isScrollControlled: true,
        enableDrag: true,
        context: context,
        useSafeArea: true,
        builder: (context) {
          return SafeArea(
            child: StreamBuilder(
                stream: DatabaseService.streamUser(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Column(
                    children: [
                      MyTextwidget(
                        fontSize: 20,
                        text: 'Registered Users',
                        fontWeight: FontWeight.bold,
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data?.docs.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 5,
                              color: Colors.grey[290],
                              child: ListTile(
                                title: Text(
                                  snapshot.data!.docs[index]['displayName']
                                      .toString(),
                                  style: ktextstyle,
                                ),
                                subtitle: Row(
                                  children: [
                                    Text(
                                      snapshot.data.docs[index]['role'],
                                    )
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_forever,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: ((context) {
                                          return Builder(builder: (context) {
                                            return Center(
                                                child: AlertDialog(
                                              title: const Text('Delete'),
                                              content: const Text(
                                                  'The following User will be permanently deleted!'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    firebaseFirestore
                                                        .collection('users')
                                                        .doc(snapshot.data
                                                            .docs[index]['uid'])
                                                        .delete();

                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Delete',
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child:
                                                        const Text('Cancel')),
                                              ],
                                            ));
                                          });
                                        }));
                                  },
                                ),
                              ),
                            );
                          }),
                    ],
                  );
                }),
          );
        });
  }

  void createUser() async {
    await DatabaseService.createUser(
        emailController.text,
        passwordController.text,
        nameController.text,
        roleController.text,
        phoneController.text);
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confpasController.clear();
    roleController.clear();
    phoneController.clear();
  }
}
