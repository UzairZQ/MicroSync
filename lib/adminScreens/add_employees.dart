import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/database.dart';

class AddEmployees extends StatefulWidget {
  const AddEmployees({super.key});

  @override
  State<AddEmployees> createState() => _AddEmployeesState();
}

class _AddEmployeesState extends State<AddEmployees> {
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

  Future createUser(String email, String password) async {
    try {
      showDialog(
          context: context,
          builder: ((context) {
            return Builder(builder: (context) {
              return const Center(child: CircularProgressIndicator());
            });
          }));
      // if (email.isEmpty && password.isEmpty) {
      //   print('email or password is empty');
      //   return CircularProgressIndicator();
      //}
      FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((UserCredential userCredential) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'displayName': nameController.text,
          'email': emailController.text,
          'longitude': '',
          'latitude': '',
          'role': roleController.text,
          'uid': userCredential.user!.uid,
          'phone': phoneController.text
        });
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: ((context) {
              return Builder(builder: (context) {
                return Center(
                    child: AlertDialog(
                  title: const Text('Success'),
                  content: const Text('New User Created Successfully!'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('OK'))
                  ],
                ));
              });
            }));
      });
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      roleController.clear();
      phoneController.clear();
      confpasController.clear();
    } on FirebaseAuthException catch (e) {
      showDialog(
          context: context,
          builder: ((context) {
            return Builder(builder: (context) {
              return Center(
                  child: AlertDialog(
                title: const Text('Error'),
                content: const Text(
                    'User creation was unsuccessfull, Please try again'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'))
                ],
              ));
            });
          }));

      print('the error in the createUser ftn is:::::$e }');
    }
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController confpasController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    //TextEditingController nameController = TextEditingController();
    return Scaffold(
      appBar: myAppBar(appBartxt: 'Add Users'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  myTextFormField(
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
                  SizedBox(
                    height: 20.0,
                  ),
                  myTextFormField(
                    hintext: 'Please Enter Email',
                    onSaved: (value) {
                      emailController.text = value!;
                    },
                    validator: (email) {
                      if (email!.isEmpty) {
                        return 'Please Enter Email Adress';
                      } else if (!RegExp(
                              r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$')
                          .hasMatch(email)) {
                        return ("Please enter a valid email");
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  myTextFormField(
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
                  SizedBox(
                    height: 20,
                  ),
                  myTextFormField(
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
                  SizedBox(
                    height: 20.0,
                  ),
                  myTextFormField(
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
                  SizedBox(
                    height: 20.0,
                  ),
                  myTextFormField(
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
                      kbuttonstyle(
                          color: kappbarColor,
                          text: 'Create New User',
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                            }
                            createUser(
                                emailController.text, passwordController.text);
                          }),
                      kbuttonstyle(
                          color: Color.fromARGB(255, 224, 57, 90),
                          text: 'Delete User',
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return StreamBuilder(
                                      stream: DataBaseService().streamUser(),
                                      builder:
                                          (context, AsyncSnapshot snapshot) {
                                        if (!snapshot.hasData) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                        return ListView.builder(
                                            itemCount:
                                                snapshot.data?.docs.length,
                                            itemBuilder: (context, index) {
                                              return Card(
                                                elevation: 5,
                                                color: Colors.grey[290],
                                                child: ListTile(
                                                  title: Text(
                                                    snapshot
                                                        .data!
                                                        .docs[index]
                                                            ['displayName']
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontFamily: 'Poppins'),
                                                  ),
                                                  subtitle: Row(
                                                    children: [
                                                      Text(snapshot.data
                                                          .docs[index]['role'])
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
                                                            return Builder(
                                                                builder:
                                                                    (context) {
                                                              return Center(
                                                                  child:
                                                                      AlertDialog(
                                                                title: const Text(
                                                                    'Delete'),
                                                                content: const Text(
                                                                    'The following User will be permanently deleted!'),
                                                                actions: [
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        firebaseFirestore
                                                                            .collection('users')
                                                                            .doc(snapshot.data.docs[index]['uid'])
                                                                            .delete();

                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: const Text(
                                                                          'OK')),
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: const Text(
                                                                          'Cancel')),
                                                                ],
                                                              ));
                                                            });
                                                          }));
                                                    },
                                                  ),
                                                ),
                                              );
                                            });
                                      });
                                });
                          })
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class myTextFormField extends StatelessWidget {
  myTextFormField(
      {required this.hintext, this.onSaved, this.validator, this.controller});

  String? hintext;
  Function(String?)? onSaved;
  String? Function(String?)? validator;
  TextEditingController? controller;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onSaved: onSaved,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.blue[50],
        hintText: '$hintext',
        hintStyle: TextStyle(fontFamily: 'Poppins'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
      ),
    );
  }
}
