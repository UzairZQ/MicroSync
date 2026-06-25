import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/View/userScreens/day_plans.dart';
import 'package:micro_pharma/View/userScreens/user_dashboard.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/components/widgets/production_widgets.dart';
import 'package:micro_pharma/models/area_model.dart';
import 'package:micro_pharma/models/product_model.dart';
import 'package:micro_pharma/models/user_model.dart';
import 'package:micro_pharma/viewModel/day_plans_provider.dart';
import 'package:micro_pharma/viewModel/user_data_provider.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatefulWidget {
  static const String id = 'user_profile';
  const UserProfilePage({super.key});

  @override
  UserProfilePageState createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage> {
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

    await Future.wait([
      context.read<UserDataProvider>().fetchUserData(user.uid),
      context.read<DayPlanProvider>().fetchDayPlans(),
    ]);
  }

  Future<void> _showEditNameDialog(String currentName) async {
    _nameController.text = currentName;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Update Profile Name'),
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
                      final uid =
                          context.read<UserDataProvider>().getUserData.uid;
                      if (newName.isEmpty ||
                          currentUser == null ||
                          uid == null) {
                        return;
                      }

                      setState(() => _isSavingName = true);
                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .update({'displayName': newName});
                        await context
                            .read<UserDataProvider>()
                            .fetchUserData(uid);
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
    return Scaffold(
      appBar: const MyAppBar(appBartxt: 'My Profile'),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: Consumer2<UserDataProvider, DayPlanProvider>(
          builder: (context, userProvider, dayPlanProvider, child) {
            final user = userProvider.getUserData;
            final todayPlan = dayPlanProvider.getCurrentDayPlan();
            final displayName = (user.displayName ?? '').trim();
            final email =
                (user.email ?? FirebaseAuth.instance.currentUser?.email ?? '')
                    .trim();
            final phone = (user.phone ?? '').trim();
            final assignedAreas = user.assignedAreas ?? [];
            final assignedProducts = user.assignedProducts ?? [];

            return LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding =
                    constraints.maxWidth < 380 ? 16.0 : 20.0;
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
                    _RepProfileHero(
                      user: user,
                      displayName: displayName.isEmpty
                          ? 'Sales Representative'
                          : displayName,
                      email: email.isEmpty ? 'Email not set' : email,
                      onEditName: () => _showEditNameDialog(displayName),
                    ),
                    const SizedBox(height: 16),
                    _WorkStatusCard(
                      user: user,
                      planArea: todayPlan?.area,
                      doctorsCount: todayPlan?.doctors.length ?? 0,
                    ),
                    const SizedBox(height: 16),
                    isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _AccountCard(
                                  email: email,
                                  phone: phone,
                                  role: user.role ?? 'user',
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
                              _AccountCard(
                                email: email,
                                phone: phone,
                                role: user.role ?? 'user',
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
                    _RepToolsCard(
                      onDashboard: () => Navigator.pushNamed(
                        context,
                        Dashboard.id,
                      ),
                      onPlans: () => Navigator.pushNamed(
                        context,
                        DayPlansScreen.id,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _AssignedAreasCard(areas: assignedAreas),
                    const SizedBox(height: 16),
                    _AssignedProductsCard(products: assignedProducts),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _RepProfileHero extends StatelessWidget {
  const _RepProfileHero({
    required this.user,
    required this.displayName,
    required this.email,
    required this.onEditName,
  });

  final UserModel user;
  final String displayName;
  final String email;
  final VoidCallback onEditName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = displayName.isEmpty ? 'R' : displayName[0].toUpperCase();
    final isTracking = user.locationTrackingActive;

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
            color: const Color(0xFF0F766E).withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroChip(
                icon: Icons.badge_outlined,
                label: 'Sales representative',
              ),
              _HeroChip(
                icon: isTracking
                    ? Icons.location_searching_outlined
                    : Icons.location_off_outlined,
                label: isTracking ? 'Tracking live' : 'Not tracking',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorkStatusCard extends StatelessWidget {
  const _WorkStatusCard({
    required this.user,
    required this.planArea,
    required this.doctorsCount,
  });

  final UserModel user;
  final String? planArea;
  final int doctorsCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTracking = user.locationTrackingActive;
    final accuracy = user.locationAccuracy;

    return _ProfileCard(
      title: 'Work Day Status',
      icon: Icons.route_outlined,
      child: Column(
        children: [
          _StatusBanner(
            isTracking: isTracking,
            title: isTracking ? 'Day is active' : 'Day is not active',
            subtitle: isTracking
                ? 'Your live location is being updated for field visibility.'
                : 'Tracking starts only after you press Start day.',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _CompactStat(
                  label: 'Today area',
                  value: planArea ?? 'No plan',
                  icon: Icons.place_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CompactStat(
                  label: 'Doctors',
                  value: doctorsCount.toString(),
                  icon: Icons.medical_services_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CompactStat(
                  label: 'Last update',
                  value: (user.update ?? '').isEmpty
                      ? 'Not available'
                      : user.update!,
                  icon: Icons.schedule_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CompactStat(
                  label: 'GPS accuracy',
                  value: accuracy == null
                      ? 'Pending'
                      : '${accuracy.toStringAsFixed(0)}m',
                  icon: Icons.gps_fixed_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Location is used only during an active work day.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
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
      icon: Icons.account_circle_outlined,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: email.isEmpty ? 'Not provided' : email,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: phone.isEmpty ? 'Not provided' : phone,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.verified_user_outlined,
            label: 'Role',
            value: role,
          ),
        ],
      ),
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
      icon: Icons.lock_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Password reset email',
              hintText: email.isEmpty ? 'you@example.com' : email,
              prefixIcon: const Icon(Icons.alternate_email_outlined),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isSending ? null : onSendReset,
              icon: Icon(
                isSending
                    ? Icons.hourglass_top_outlined
                    : Icons.lock_reset_outlined,
              ),
              label: Text(isSending ? 'Sending...' : 'Send reset link'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RepToolsCard extends StatelessWidget {
  const _RepToolsCard({
    required this.onDashboard,
    required this.onPlans,
  });

  final VoidCallback onDashboard;
  final VoidCallback onPlans;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      title: 'Field Shortcuts',
      icon: Icons.bolt_outlined,
      child: Row(
        children: [
          Expanded(
            child: _ShortcutButton(
              icon: Icons.space_dashboard_outlined,
              label: 'Dashboard',
              onTap: onDashboard,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ShortcutButton(
              icon: Icons.route_outlined,
              label: 'My plans',
              onTap: onPlans,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignedAreasCard extends StatelessWidget {
  const _AssignedAreasCard({required this.areas});

  final List<AreaModel> areas;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      title: 'Assigned Areas',
      icon: Icons.map_outlined,
      child: areas.isEmpty
          ? const EmptyState(
              icon: Icons.location_off_outlined,
              title: 'No areas assigned',
              message: 'Your manager has not assigned a territory yet.',
            )
          : Wrap(
              spacing: 10,
              runSpacing: 10,
              children: areas
                  .map(
                    (area) => _TagChip(
                      icon: Icons.place_outlined,
                      label: area.areaName,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _AssignedProductsCard extends StatelessWidget {
  const _AssignedProductsCard({required this.products});

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      title: 'Assigned Products',
      icon: Icons.inventory_2_outlined,
      child: products.isEmpty
          ? const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No products assigned',
              message: 'Assigned products will appear here.',
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 620 ? 3 : 2;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.4,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _ProductTile(product: product);
                  },
                );
              },
            ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1.5,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF0F766E), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.isTracking,
    required this.title,
    required this.subtitle,
  });

  final bool isTracking;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isTracking ? const Color(0xFFE0F2F1) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            isTracking
                ? Icons.location_searching_outlined
                : Icons.pause_circle_outline,
            color:
                isTracking ? const Color(0xFF0F766E) : const Color(0xFFC2410C),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactStat extends StatelessWidget {
  const _CompactStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0F766E), size: 20),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0F766E)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutButton extends StatelessWidget {
  const _ShortcutButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F2F1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF0F766E)),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: const Color(0xFF0F766E)),
          const SizedBox(width: 7),
          Flexible(child: Text(label)),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.medication_liquid_outlined,
              color: Color(0xFF0F766E),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
