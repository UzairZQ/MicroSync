import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:micro_pharma/components/constants.dart';

import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  static String id = 'login';

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController changePassController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(
                'assets/images/login.png',
              ),
            ),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Flexible(
                child: Hero(
                  tag: 'micro-logo',
                  child: Image(
                    alignment: Alignment.center,
                    height: 170.0,
                    image: AssetImage('assets/images/micro_trans.png'),
                  ),
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          size: 35.0,
                        ),
                        filled: true,
                        fillColor: Colors.blue[100]!.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Enter Email',
                      ),
                      textAlign: TextAlign.center,
                      onSaved: (value) {
                        emailController.text = value!;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter Something';
                        }
                        return null;
                      },
                      //validator: validateEmail,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline, size: 35.0),
                        filled: true,
                        fillColor: Colors.blue[100]!.withOpacity(0.5),
                        hintText: 'Enter Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      textAlign: TextAlign.center,
                      obscureText: true,
                      onSaved: (value) {
                        passwordController.text = value!;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter Something';
                        }
                        return null;
                      },
                      // validator: validatePassword,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15.0),
              MyButton(
                  color: const Color(0xFFFFB800),
                  text: 'LOGIN',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                    }
                    AuthService().signIn(
                      emailController.text,
                      passwordController.text,
                    );
                  }),
              const SizedBox(height: 10.0),
              TextButton(
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Scaffold(
                          body: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  'Change Password For Your Account :',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18.0),
                                ),
                                const SizedBox(
                                  height: 15.0,
                                ),
                                MyTextFormField(
                                    key: formKey,
                                    hintext: 'Please Enter your Email',
                                    controller: changePassController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Email Cannot be empty';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      changePassController.text = value!;
                                    }),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                MyButton(
                                    color: Colors.amber,
                                    text: 'Send Email',
                                    onPressed: () {
                                      try {
                                        if (_formKey.currentState!.validate()) {
                                          _formKey.currentState!.save();
                                          _auth
                                              .sendPasswordResetEmail(
                                                  email:
                                                      changePassController.text)
                                              .then((value) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Please check your Email to reset the password'),
                                              ),
                                            );

                                            changePassController.clear();
                                          });
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text(
                                              'Please check your Email to reset the password'),
                                        ));
                                      }
                                    })
                              ],
                            ),
                          ),
                        );
                      });
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
