import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:micro_pharma/screens/homepage.dart';
import '../main.dart';
import 'package:micro_pharma/components/constants.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  late String emailtxt, passwordtxt;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(
                'assets/images/login.png',
              ),
            ),
          ),
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Flexible(
                child: Image(
                  alignment: Alignment.center,
                  height: 170.0,
                  image: AssetImage('assets/images/micro_trans.png'),
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: null,
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
                        emailtxt = value!;
                      },
                      validator: validateEmail,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline, size: 35.0),
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
                        passwordtxt = value!;
                      },
                      validator: validatePassword,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15.0),
              kbuttonstyle(
                  color: const Color(0xFFFFB800),
                  text: 'Login',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _signIn();
                    }
                  }

                  //Navigator.pushNamed(context, HomePage.id),
                  ),
              const SizedBox(height: 10.0),
              TextButton(
                onPressed: () {},
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

  String? validateEmail(String? email) {
    if (email!.isEmpty) {
      return 'Please Enter Email Adress';
    } else {
      return null;
    }
  }

  String? validatePassword(String? password) {
    if (password!.isEmpty) {
      return 'Please Enter Password';
    } else {
      return null;
    }
  }

  Future _signIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: emailtxt.trim(), password: passwordtxt.trim());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Incorrect Email or Password or It can be a network issue'),
        ),
      );
    }
  }
}
