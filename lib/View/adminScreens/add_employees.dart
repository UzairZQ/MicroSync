import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/components/widgets/production_widgets.dart';

import '../../services/database_service.dart';

class AddEmployees extends StatefulWidget {
  static const String id = 'add_employees';
  const AddEmployees({super.key});

  @override
  State<AddEmployees> createState() => _AddEmployeesState();
}

class _AddEmployeesState extends State<AddEmployees> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isCreating = false;
  String _query = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Reps'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _showAddRepSheet,
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Add New Rep'),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService.streamUser(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reps = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data['displayName']?.toString().toLowerCase() ?? '';
            final email = data['email']?.toString().toLowerCase() ?? '';
            final phone = data['phone']?.toString().toLowerCase() ?? '';
            final query = _query.toLowerCase();
            return query.isEmpty ||
                name.contains(query) ||
                email.contains(query) ||
                phone.contains(query);
          }).toList();

          return RefreshIndicator(
            onRefresh: () async {},
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _RepHeader(
                  totalReps: snapshot.data!.docs.length,
                  activeReps: snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['locationTrackingActive'] == true;
                  }).length,
                ),
                const SizedBox(height: 14),
                TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    labelText: 'Search reps',
                    prefixIcon: Icon(Icons.search_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                if (reps.isEmpty)
                  const EmptyState(
                    icon: Icons.people_outline,
                    title: 'No reps found',
                    message: 'Add a new rep or adjust the search.',
                  )
                else
                  ...reps.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _RepCard(
                      data: data,
                      onDelete: () => _confirmDeleteRep(data),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddRepSheet() {
    _clearForm();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> submit() async {
              if (!_formKey.currentState!.validate() || _isCreating) {
                return;
              }

              setSheetState(() => _isCreating = true);
              final result = await DatabaseService.createUser(
                _emailController.text.trim(),
                _passwordController.text.trim(),
                _nameController.text.trim(),
                'user',
                _phoneController.text.trim(),
              );
              setSheetState(() => _isCreating = false);

              if (!mounted) {
                return;
              }

              if (result == 'Success') {
                Navigator.pop(sheetContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('New rep created')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result)),
                );
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.viewInsetsOf(context).bottom + 18,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2F1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1_outlined,
                              color: Color(0xFF0F766E),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Add New Rep',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Rep name',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Enter rep name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: validateEmail,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Enter phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Temporary password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          final password = value ?? '';
                          if (password.isEmpty) {
                            return 'Enter password';
                          }
                          if (password.length < 6) {
                            return 'Minimum 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm password',
                          prefixIcon: Icon(Icons.lock_reset_outlined),
                        ),
                        validator: (value) {
                          if ((value ?? '').isEmpty) {
                            return 'Confirm password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isCreating ? null : submit,
                          icon: Icon(
                            _isCreating
                                ? Icons.hourglass_top_outlined
                                : Icons.person_add_alt_1_outlined,
                          ),
                          label:
                              Text(_isCreating ? 'Creating...' : 'Create Rep'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteRep(Map<String, dynamic> data) async {
    final uid = data['uid']?.toString() ?? '';
    final name = data['displayName']?.toString() ?? 'this rep';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Rep?'),
          content: Text(
            'Delete $name from MicroSync records? This removes assignments, '
            'latest location, route history, and work sessions from Firestore. '
            'If the Firebase Auth account must also be removed, delete it from '
            'Firebase Authentication or a secure admin backend.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton.tonalIcon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final result = await DatabaseService.deleteRepRecord(uid);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result == 'Success' ? 'Rep deleted from records' : result,
        ),
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }
}

class _RepHeader extends StatelessWidget {
  const _RepHeader({
    required this.totalReps,
    required this.activeReps,
  });

  final int totalReps;
  final int activeReps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withOpacity(0.2),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.groups_2_outlined, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalReps field reps',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$activeReps tracking live right now',
                  style: TextStyle(color: Colors.white.withOpacity(0.76)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RepCard extends StatelessWidget {
  const _RepCard({
    required this.data,
    required this.onDelete,
  });

  final Map<String, dynamic> data;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = data['displayName']?.toString() ?? 'Unnamed rep';
    final email = data['email']?.toString() ?? 'Email not set';
    final phone = data['phone']?.toString() ?? 'Phone not set';
    final isActive = data['locationTrackingActive'] == true;
    final update = data['update']?.toString() ?? 'No location update';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor:
                  isActive ? const Color(0xFFE0F2F1) : const Color(0xFFF1F5F9),
              child: Icon(
                isActive
                    ? Icons.location_searching_outlined
                    : Icons.person_outline,
                color: isActive
                    ? const Color(0xFF0F766E)
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _RepChip(
                        icon: Icons.phone_outlined,
                        label: phone,
                      ),
                      _RepChip(
                        icon: isActive
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        label: isActive ? 'Tracking live' : 'Not tracking',
                      ),
                      _RepChip(
                        icon: Icons.schedule_outlined,
                        label: update,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Delete rep',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _RepChip extends StatelessWidget {
  const _RepChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
