import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/viewModel/user_data_provider.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatefulWidget {
  static const String id = 'user_profile';
  const UserProfilePage({super.key});

  @override
  UserProfilePageState createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage> {
  final TextEditingController _nameEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();

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
            isScrollControlled: true,
            constraints: BoxConstraints.loose(const Size.fromHeight(600)),
            context: context,
            builder: (BuildContext context) {
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
                            debugPrint(
                                'Error sending password reset email: $e');
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
        label: const MyTextwidget(text: 'Change Password'),
        icon: const Icon(Icons.lock_clock_outlined),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: kappbarColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: kappbarColor.withOpacity(0.2),
                    child: Text(
                      (user.displayName ?? 'U').isNotEmpty
                          ? (user.displayName ?? 'U')[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: kappbarColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.displayName ?? 'User Name',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kappbarColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Sales Representative',
                      style: TextStyle(
                        color: kappbarColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoTile(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    subtitle: user.email ?? 'Not provided',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoTile(
                    icon: Icons.phone_outlined,
                    title: 'Phone',
                    subtitle: (user.phone ?? '').isEmpty ? 'Not provided' : user.phone!,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Assigned Areas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (user.assignedAreas == null || user.assignedAreas!.isEmpty)
                    const Text('No assigned areas yet.', style: TextStyle(color: Colors.grey))
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: user.assignedAreas!.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final area = user.assignedAreas![index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.place_outlined, color: Colors.orange, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  area.areaName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 32),
                  const Text(
                    'Assigned Products',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (user.assignedProducts == null || user.assignedProducts!.isEmpty)
                    const Text('No assigned products yet.', style: TextStyle(color: Colors.grey))
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2.5,
                      ),
                      itemCount: user.assignedProducts!.length,
                      itemBuilder: (context, index) {
                        final product = user.assignedProducts![index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                decoration: BoxDecoration(
                                  color: kappbarColor,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.blueGrey, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
