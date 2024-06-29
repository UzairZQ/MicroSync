import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';

class ForgotPasswordBottomSheet extends StatelessWidget {
  const ForgotPasswordBottomSheet({
    super.key,
    required this.changePassController,
    required GlobalKey<FormState> formKey,
    required FirebaseAuth auth,
  }) : _formKey = formKey, _auth = auth;

  final TextEditingController changePassController;
  final GlobalKey<FormState> _formKey;
  final FirebaseAuth _auth;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        showModalBottomSheet(
            isScrollControlled: true,
            constraints:
                BoxConstraints.loose(const Size.fromHeight(500)),
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
                            fontSize: 14.0),
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
    );
  }
}
