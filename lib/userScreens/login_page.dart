import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/adminScreens/admin_page.dart';
import 'package:micro_pharma/userScreens/homepage.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'package:micro_pharma/components/constants.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);
  static String id = 'login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    print('textediting controllers are disposed');
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
                      validator: validateEmail,
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
                      validator: validatePassword,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15.0),
              kbuttonstyle(
                  color: const Color(0xFFFFB800),
                  text: 'LOGIN',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                    }
                    signIn(
                      emailController.text,
                      passwordController.text,
                    );
                  }),
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
    } else if (!RegExp(
            r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$')
        .hasMatch(email)) {
      return ("Please enter a valid email");
    } else {
      return null;
    }
  }

  String? validatePassword(String? password) {
    RegExp regex = RegExp(r'^.{6,}$');
    if (password!.isEmpty) {
      return 'Password Enter Password';
    } else if (!regex.hasMatch(password)) {
      return 'Enter Password with min. 6 Characters';
    } else {
      return null;
    }
  }

  void route() {
    User? user = FirebaseAuth.instance.currentUser;
    var kk = FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        if (documentSnapshot.get('role') == "user") {
          //if successfully loggedIn (Creds are correct)

          var sharedLogin = await SharedPreferences.getInstance();
          var sharedUser = await SharedPreferences.getInstance();
          sharedLogin.setBool(SplashPageState.KEYLOGIN, true);
          sharedUser.setBool(SplashPageState.KEYUSER, true);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        } else if (documentSnapshot.get('role') == "admin") {
          var sharedLogin = await SharedPreferences.getInstance();
          var sharedUser = await SharedPreferences.getInstance();
          sharedLogin.setBool(SplashPageState.KEYLOGIN, true);
          sharedUser.setBool(SplashPageState.KEYUSER, false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminPage(),
            ),
          );
        }
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  Future signIn(String email, String password) async {
    showDialog(
        context: context,
        builder: ((context) {
          return Builder(builder: (context) {
            return const Center(child: CircularProgressIndicator());
          });
        }));
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      route();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No user found for this Email'),
          ),
        );
        print('no user found for that email');
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter correct password'),
          ),
        );
        print('wrong password provided for that user');
      }
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content:
      //         Text('Incorrect Email or Password or It can be a network issue'),

    }
    Navigator.pop(context);
  }
}
