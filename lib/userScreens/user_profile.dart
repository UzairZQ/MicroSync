import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/providers/user_data_provider.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatefulWidget {
  static const String id = 'user_profile';
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  UserProfilePageState createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage> {
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
        title: const Text('My Profile'),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              TextEditingController emailEditingController =
                  TextEditingController();
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Enter your email address to receive a password reset link',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
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
                            await FirebaseAuth.instance.sendPasswordResetEmail(
                              email: email,
                            );
                            Navigator.pop(navigatorKey.currentContext!);
                            ScaffoldMessenger.of(
                              navigatorKey.currentContext!,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'A password reset email has been sent to $email',
                                ),
                              ),
                            );
                          } catch (e) {
                            print(
                              'Error sending password reset email: $e',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Error sending password reset email. Please try again later.',
                                ),
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
        label: MyTextwidget(text: 'Change Password'),
        icon: const Icon(Icons.lock_clock_outlined),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Card(
                color: Colors.teal[100],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyTextwidget(
                    text: user.displayName ?? '',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Card(
                color: Colors.amber[100],
                elevation: 3.0,
                child: MyTextwidget(
                  text: user.email ?? '',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Card(
                color: Colors.blue[100],
                child: MyTextwidget(
                  text: user.phone ?? '',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              MyTextwidget(
                text: 'My Assigned Areas',
                fontSize: 20,
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: user.assignedAreas?.length,
                itemBuilder: (context, index) {
                  final area = user.assignedAreas?[index];
                  return Card(
                    color: Colors.amber[200],
                    child: ListTile(
                      title: MyTextwidget(text: area!.areaName),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              MyTextwidget(
                text: 'My Assigned Products',
                fontSize: 20,
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.7),
                itemCount: user.assignedProducts!.length,
                itemBuilder: (context, index) {
                  final product = user.assignedProducts![index];
                  return Material(
                    borderRadius: BorderRadius.circular(15),
                    elevation: 2,
                    child: Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                        color: kappbarColor.withAlpha(100),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: MyTextwidget(text: product.name),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
