import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/View/adminScreens/add_employees.dart';
import 'package:micro_pharma/View/adminScreens/admin_panel/admin_panel.dart';
import 'package:micro_pharma/View/adminScreens/admin_panel/products_page.dart';
import 'package:micro_pharma/View/adminScreens/location_screen.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/components/widgets/production_widgets.dart';
import 'package:micro_pharma/services/database_service.dart';
import 'package:micro_pharma/viewModel/user_data_provider.dart';
import 'package:provider/provider.dart';

class AdminProfilePage extends StatefulWidget {
  static const String id = 'admin_profile';
  const AdminProfilePage({super.key});

  @override
  AdminProfilePageState createState() => AdminProfilePageState();
}

class AdminProfilePageState extends State<AdminProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _resetEmailController = TextEditingController();
  bool _isSavingName = false;
  bool _isSendingReset = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshProfile());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _resetEmailController.dispose();
    super.dispose();
  }

  Future<void> _refreshProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    await context.read<UserDataProvider>().fetchUserData(user.uid);
  }

  Future<void> _showEditNameDialog(String currentName) async {
    _nameController.text = currentName;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Update Admin Name'),
          content: TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Display name',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: _isSavingName
                  ? null
                  : () async {
                      final newName = _nameController.text.trim();
                      final currentUser = FirebaseAuth.instance.currentUser;
                      if (newName.isEmpty || currentUser == null) {
                        return;
                      }

                      setState(() => _isSavingName = true);
                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUser.uid)
                            .update({'displayName': newName});
                        await context
                            .read<UserDataProvider>()
                            .fetchUserData(currentUser.uid);
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile updated')),
                          );
                        }
                      } catch (_) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not update profile name.'),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isSavingName = false);
                        }
                      }
                    },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendPasswordReset(String fallbackEmail) async {
    final email = _resetEmailController.text.trim().isEmpty
        ? fallbackEmail.trim()
        : _resetEmailController.text.trim();
    if (email.isEmpty || _isSendingReset) {
      return;
    }

    setState(() => _isSendingReset = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset sent to $email')),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Could not send password reset.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingReset = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserDataProvider>().getUserData;
    final displayName = (user.displayName ?? '').trim();
    final email =
        (user.email ?? FirebaseAuth.instance.currentUser?.email ?? '').trim();
    final phone = (user.phone ?? '').trim();
    final role = (user.role ?? 'admin').trim();

    return Scaffold(
      appBar: const MyAppBar(appBartxt: 'Admin Profile'),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 380 ? 16.0 : 20.0;
            final isWide = constraints.maxWidth >= 720;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                28,
              ),
              children: [
                _AdminProfileHero(
                  displayName: displayName.isEmpty
                      ? 'MicroSync Administrator'
                      : displayName,
                  email: email.isEmpty ? 'Email not set' : email,
                  role: role,
                  onEditName: () => _showEditNameDialog(displayName),
                ),
                const SizedBox(height: 16),
                _OperationsSnapshot(isWide: isWide),
                const SizedBox(height: 16),
                isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _AccountDetailsCard(
                              email: email,
                              phone: phone,
                              role: role,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _SecurityCard(
                              email: email,
                              controller: _resetEmailController,
                              isSending: _isSendingReset,
                              onSendReset: () => _sendPasswordReset(email),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _AccountDetailsCard(
                            email: email,
                            phone: phone,
                            role: role,
                          ),
                          const SizedBox(height: 14),
                          _SecurityCard(
                            email: email,
                            controller: _resetEmailController,
                            isSending: _isSendingReset,
                            onSendReset: () => _sendPasswordReset(email),
                          ),
                        ],
                      ),
                const SizedBox(height: 16),
                _AdminToolsCard(
                  onAdminPanel: () => Navigator.pushNamed(
                    context,
                    AdminPanel.id,
                  ),
                  onEmployees: () => Navigator.pushNamed(
                    context,
                    AddEmployees.id,
                  ),
                  onProducts: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductListScreen(),
                    ),
                  ),
                  onLiveTracking: () => Navigator.pushNamed(
                    context,
                    LocationScreen.id,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AdminProfileHero extends StatelessWidget {
  const _AdminProfileHero({
    required this.displayName,
    required this.email,
    required this.role,
    required this.onEditName,
  });

  final String displayName;
  final String email;
  final String role;
  final VoidCallback onEditName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = displayName.isEmpty ? 'A' : displayName[0].toUpperCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kappbarColor,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: kappbarColor.withOpacity(0.24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white.withOpacity(0.16),
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.78),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'Edit profile name',
            onPressed: onEditName,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }
}

class _OperationsSnapshot extends StatelessWidget {
  const _OperationsSnapshot({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseService.streamUser(),
      builder: (context, AsyncSnapshot snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final employeeCount = docs.length;
        final activeCount = docs
            .where((doc) =>
                (doc.data() as Map<String, dynamic>).containsKey('update'))
            .length;

        final tiles = [
          MetricTile(
            label: 'Field reps',
            value: '$employeeCount',
            icon: Icons.groups_2_outlined,
            accent: kappbarColor,
          ),
          MetricTile(
            label: 'Location updates',
            value: '$activeCount',
            icon: Icons.location_on_outlined,
            accent: const Color(0xFF0D9488),
          ),
        ];

        if (isWide) {
          return Row(
            children: [
              Expanded(child: tiles[0]),
              const SizedBox(width: 14),
              Expanded(child: tiles[1]),
            ],
          );
        }

        return Column(
          children: [
            tiles[0],
            const SizedBox(height: 12),
            tiles[1],
          ],
        );
      },
    );
  }
}

class _AccountDetailsCard extends StatelessWidget {
  const _AccountDetailsCard({
    required this.email,
    required this.phone,
    required this.role,
  });

  final String email;
  final String phone;
  final String role;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      title: 'Account Details',
      children: [
        _DetailRow(
          icon: Icons.mail_outline,
          label: 'Email',
          value: email.isEmpty ? 'Not set' : email,
        ),
        _DetailRow(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: phone.isEmpty ? 'Not set' : phone,
        ),
        _DetailRow(
          icon: Icons.verified_user_outlined,
          label: 'Access level',
          value: role.isEmpty ? 'Admin' : role,
        ),
      ],
    );
  }
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard({
    required this.email,
    required this.controller,
    required this.isSending,
    required this.onSendReset,
  });

  final String email;
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSendReset;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      title: 'Security',
      children: [
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Password reset email',
            hintText: email.isEmpty ? 'admin@example.com' : email,
            prefixIcon: const Icon(Icons.lock_reset_outlined),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: isSending ? null : onSendReset,
            icon: isSending
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.mark_email_read_outlined),
            label: Text(isSending ? 'Sending...' : 'Send Reset Link'),
          ),
        ),
      ],
    );
  }
}

class _AdminToolsCard extends StatelessWidget {
  const _AdminToolsCard({
    required this.onAdminPanel,
    required this.onEmployees,
    required this.onProducts,
    required this.onLiveTracking,
  });

  final VoidCallback onAdminPanel;
  final VoidCallback onEmployees;
  final VoidCallback onProducts;
  final VoidCallback onLiveTracking;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      title: 'Admin Shortcuts',
      children: [
        _ToolRow(
          icon: Icons.settings_applications_outlined,
          title: 'Admin Panel',
          subtitle: 'Areas, doctors, assignments, targets, and medicines.',
          onTap: onAdminPanel,
        ),
        _ToolRow(
          icon: Icons.person_add_alt_1_outlined,
          title: 'Rep Management',
          subtitle: 'Create reps and keep account access organized.',
          onTap: onEmployees,
        ),
        _ToolRow(
          icon: Icons.medication_outlined,
          title: 'Medicine Catalog',
          subtitle: 'Maintain product names, codes, and packing.',
          onTap: onProducts,
        ),
        _ToolRow(
          icon: Icons.map_outlined,
          title: 'Live Tracking',
          subtitle: 'Review field activity and latest location updates.',
          onTap: onLiveTracking,
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.34),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: kappbarColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: kappbarColor, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolRow extends StatelessWidget {
  const _ToolRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.42),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, color: kappbarColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
