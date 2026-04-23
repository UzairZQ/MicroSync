import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/View/userScreens/User%20Home%20Page/privacy_consent_dialog.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/models/day_plan_model.dart';
import 'package:micro_pharma/models/user_model.dart';
import 'package:micro_pharma/services/location_services.dart';
import 'package:micro_pharma/viewModel/day_plans_provider.dart';
import 'package:micro_pharma/viewModel/user_data_provider.dart';
import 'package:provider/provider.dart';

import '../../adminScreens/admin_panel/doctors_page.dart';
import '../../../components/widgets/container_row.dart';
import '../../../components/widgets/my_container.dart';
import '../Call Planner Page/call_planner.dart';
import '../Daily Call Report Page/dailycall_report.dart';
import '../OrderPage/order_page.dart';
import '../day_plans.dart';
import '../user_dashboard.dart';
import 'bacground_location.dart';
import 'bottom_navigation_bar.dart';

class HomePage extends StatefulWidget {
  static const String id = 'home';
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  bool _hasInitializedLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (currentUser == null) {
        return;
      }

      await context.read<UserDataProvider>().fetchUserData(currentUser!.uid);
      await context.read<DayPlanProvider>().fetchDayPlans();
      if (!mounted) {
        return;
      }

      if (!_hasInitializedLocation) {
        _hasInitializedLocation = true;
        await showPrivacyConsentDialog(currentUser!.uid);
        getBackgroundLocation(currentUser!.uid);
      }
    });
  }

  Future<void> _refreshHome() async {
    if (currentUser == null) {
      return;
    }

    await Future.wait([
      context.read<UserDataProvider>().fetchUserData(currentUser!.uid),
      context.read<DayPlanProvider>().fetchDayPlans(),
      LocationServices().getLocation(currentUser!.uid),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      bottomNavigationBar: const HomeNavigationBar(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshHome,
          child: Consumer2<UserDataProvider, DayPlanProvider>(
            builder: (context, userProvider, dayPlanProvider, child) {
              final UserModel user = userProvider.getUserData;
              final DayPlanModel? todayPlan =
                  dayPlanProvider.getCurrentDayPlan();

              return LayoutBuilder(
                builder: (context, constraints) {
                  final bool isCompact = constraints.maxWidth < 700;
                  final horizontalPadding =
                      constraints.maxWidth < 380 ? 16.0 : 20.0;

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      12,
                      horizontalPadding,
                      24,
                    ),
                    children: [
                      _HomeHero(
                        user: user,
                        todayPlan: todayPlan,
                        onStartDay: () {
                          if (currentUser != null) {
                            LocationServices().getLocation(currentUser!.uid);
                          }
                        },
                        onChangePlan: () {
                          Navigator.pushNamed(context, DayPlansScreen.id);
                        },
                      ),
                      const SizedBox(height: 18),
                      isCompact
                          ? Column(
                              children: [
                                _QuickStatsCard(todayPlan: todayPlan),
                                const SizedBox(height: 14),
                                _AssignedAreasCard(user: user),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _QuickStatsCard(todayPlan: todayPlan),
                                ),
                                const SizedBox(width: 14),
                                Expanded(child: _AssignedAreasCard(user: user)),
                              ],
                            ),
                      const SizedBox(height: 22),
                      Text(
                        'Workspace',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Everything you need for today, arranged for quick access on any Android screen.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 18),
                      ContainerRow(
                        children: [
                          MyContainer(
                            containerclr: const Color(0xFFD9F4EC),
                            containerIcon: Icons.space_dashboard_outlined,
                            containerText: 'Live dashboard',
                            onTap: () =>
                                Navigator.pushNamed(context, Dashboard.id),
                          ),
                          MyContainer(
                            containerclr: const Color(0xFFFDE7D5),
                            containerIcon: Icons.calendar_month_outlined,
                            containerText: 'Call planner',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: ((context) => const CallPlanner()),
                                ),
                              );
                            },
                          ),
                          MyContainer(
                            containerclr: const Color(0xFFE2E8FF),
                            containerIcon: Icons.route_outlined,
                            containerText: 'My call plans',
                            onTap: () =>
                                Navigator.pushNamed(context, DayPlansScreen.id),
                          ),
                          MyContainer(
                            containerclr: const Color(0xFFFFF0B8),
                            containerIcon: Icons.assignment_turned_in_outlined,
                            containerText: 'Daily call reports',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: ((context) =>
                                    const DailyCallReportScreen()),
                              ),
                            ),
                          ),
                          MyContainer(
                            containerclr: const Color(0xFFD8F2FF),
                            containerIcon: Icons.medical_services_outlined,
                            containerText: 'Doctors',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: ((context) => const DoctorsPage()),
                              ),
                            ),
                          ),
                          MyContainer(
                            containerclr: const Color(0xFFFFE1DB),
                            containerIcon: Icons.add_shopping_cart_outlined,
                            containerText: 'Send orders',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: ((context) => const OrderScreen()),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      Icons.tips_and_updates_outlined,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Field note',
                                      style: theme.textTheme.titleLarge,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                todayPlan == null
                                    ? 'No route is assigned for today yet. Pull to refresh after your manager updates the schedule.'
                                    : 'Your route is centered on ${todayPlan.area}. Start the day once you are on the move so location and activity logs stay current.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({
    required this.user,
    required this.todayPlan,
    required this.onStartDay,
    required this.onChangePlan,
  });

  final UserModel user;
  final DayPlanModel? todayPlan;
  final VoidCallback onStartDay;
  final VoidCallback onChangePlan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plan = todayPlan;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF0F766E), Color(0xFF134E4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withOpacity(0.24),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'MicroSync',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if ((user.update ?? '').isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Last sync ${user.update}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Welcome back${(user.displayName ?? '').isNotEmpty ? ', ${user.displayName}' : ''}',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              plan == null
                  ? 'No route is locked in for today yet. Use the tools below to review plans and stay ready.'
                  : 'Today\'s route is ${plan.area} with ${plan.doctors.length} doctor visits planned.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.86),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.13),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today\'s plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plan?.area ?? 'No day plan found for today',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (plan != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      plan.doctors.join(', '),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.78),
                        height: 1.45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                MyButton(
                  onPressed: onStartDay,
                  color: const Color(0xFFF59E0B),
                  text: 'Start your day',
                ),
                MyButton(
                  onPressed: onChangePlan,
                  color: const Color(0xFF1D4ED8),
                  text: 'Change plan',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStatsCard extends StatelessWidget {
  const _QuickStatsCard({required this.todayPlan});

  final DayPlanModel? todayPlan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today at a glance', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _MiniStat(
              label: 'Area',
              value: todayPlan?.area ?? 'Pending',
            ),
            const SizedBox(height: 12),
            _MiniStat(
              label: 'Doctors',
              value: todayPlan?.doctors.length.toString() ?? '0',
            ),
            const SizedBox(height: 12),
            _MiniStat(
              label: 'Shift',
              value: todayPlan?.shift ?? 'Not assigned',
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignedAreasCard extends StatelessWidget {
  const _AssignedAreasCard({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final areas = user.assignedAreas ?? [];
    final products = user.assignedProducts ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assigned coverage', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _MiniStat(label: 'Areas', value: areas.length.toString()),
            const SizedBox(height: 12),
            _MiniStat(label: 'Products', value: products.length.toString()),
            const SizedBox(height: 12),
            _MiniStat(
              label: 'Phone',
              value: (user.phone ?? '').isEmpty ? 'Not set' : user.phone!,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
