import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/providers/user_data_provider.dart';
import 'package:provider/provider.dart';

class AdminProfilePage extends StatefulWidget {
  static const String id = 'admin_profile';
  const AdminProfilePage({Key? key}) : super(key: key);

  @override
  _AdminProfilePageState createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final TextEditingController _nameEditingController = TextEditingController();

  @override
  void dispose() {
    _nameEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final user = userDataProvider.getUserData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Profile'),
        centerTitle: true,
        backgroundColor: kappbarColor,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Edit Name'),
                    content: TextFormField(
                      controller: _nameEditingController,
                      decoration: const InputDecoration(
                        hintText: 'Enter new name',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final newName = _nameEditingController.text.trim();
                          if (newName.isNotEmpty) {
                            user.displayName = newName;
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .update({'displayName': newName});
                            userDataProvider.fetchUserData(user.uid!);
                          }
                          Navigator.pop(navigatorKey.currentContext!);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: Center(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  user.displayName ?? '',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins'),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Card(
                elevation: 3.0,
                child: Text(
                  user.email ?? '',
                  style: ktextstyle,
                )),
            const SizedBox(height: 5),
            Card(
                child: Text(
              user.phone ?? '',
              style: ktextstyle,
            )),
            const SizedBox(height: 20),
            MyButton(
              onPressed: () {
                
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    TextEditingController emailEditingController =
                        TextEditingController();
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Enter your email address to receive a password reset link',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 17,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: emailEditingController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'you@example.com',
                            ),
                          ),
                          const SizedBox(height: 20),
                          MyButton(
                            onPressed: () async {
                              final email = emailEditingController.text.trim();
                              if (email.isNotEmpty) {
                                try {
                                  await FirebaseAuth.instance
                                      .sendPasswordResetEmail(email: email);
                                  Navigator.pop(navigatorKey.currentContext!);
                                  ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'A password reset email has been sent to $email'),
                                    ),
                                  );
                                } catch (e) {
                                  print(
                                      'Error sending password reset email: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Error sending password reset email. Please try again later.'),
                                    ),
                                  );
                                }
                              }
                            },
                            text: 'Send Email',
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              text: 'Change Password',
            ),
          ],
        ),
      ),
    );
  }
}
