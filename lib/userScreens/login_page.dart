import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/adminScreens/add_employees.dart';
import 'package:micro_pharma/adminScreens/admin_page.dart';
import 'package:micro_pharma/userScreens/home_page.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'package:micro_pharma/components/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  static String id = 'login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController changePassController = TextEditingController();

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
              MyButton(
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
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Scaffold(
                          body: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Change Password',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18.0),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                MyTextFormField(
                                    hintext: 'Please Enter you Email',
                                    controller: changePassController,
                                    validator: validateEmail,
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
                                      _auth
                                          .sendPasswordResetEmail(
                                              email: changePassController.text)
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
