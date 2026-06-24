import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/View/userScreens/User%20Home%20Page/privacy_consent_dialog.dart';
import 'package:micro_pharma/models/day_plan_model.dart';
import 'package:micro_pharma/models/user_model.dart';
import 'package:micro_pharma/services/location_services.dart';
import 'package:micro_pharma/viewModel/day_plans_provider.dart';
import 'package:micro_pharma/viewModel/user_data_provider.dart';
import 'package:provider/provider.dart';

import '../../adminScreens/admin_panel/doctors_page.dart';
import '../../../components/widgets/production_widgets.dart';
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
  const HomePage({super.key});

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
        top: false,
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
                    padding: const EdgeInsets.only(bottom: 24),
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
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          18,
                          horizontalPadding,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            isCompact
                                ? Column(
                                    children: [
                                      _QuickStatsCard(todayPlan: todayPlan),
                                      const SizedBox(height: 14),
                                      _AssignedAreasCard(user: user),
                                    ],
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _QuickStatsCard(
                                          todayPlan: todayPlan,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: _AssignedAreasCard(user: user),
                                      ),
                                    ],
                                  ),
                            const SizedBox(height: 22),
                            const SectionTitle(title: 'Workspace'),
                            const SizedBox(height: 12),
                            ContainerRow(
                              children: [
                                MyContainer(
                                  containerclr: const Color(0xFFD9F4EC),
                                  containerIcon: Icons.space_dashboard_outlined,
                                  containerText: 'Live dashboard',
                                  onTap: () => Navigator.pushNamed(
                                      context, Dashboard.id),
                                ),
                                MyContainer(
                                  containerclr: const Color(0xFFFDE7D5),
                                  containerIcon: Icons.calendar_month_outlined,
                                  containerText: 'Call planner',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: ((context) =>
                                            const CallPlanner()),
                                      ),
                                    );
                                  },
                                ),
                                MyContainer(
                                  containerclr: const Color(0xFFE2E8FF),
                                  containerIcon: Icons.route_outlined,
                                  containerText: 'My call plans',
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    DayPlansScreen.id,
                                  ),
                                ),
                                MyContainer(
                                  containerclr: const Color(0xFFFFF0B8),
                                  containerIcon:
                                      Icons.assignment_turned_in_outlined,
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
                                  containerIcon:
                                      Icons.medical_services_outlined,
                                  containerText: 'Doctors',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: ((context) =>
                                          const DoctorsPage()),
                                    ),
                                  ),
                                ),
                                MyContainer(
                                  containerclr: const Color(0xFFFFE1DB),
                                  containerIcon:
                                      Icons.add_shopping_cart_outlined,
                                  containerText: 'Send orders',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: ((context) =>
                                          const OrderScreen()),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            _DashboardInfoCard(
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
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Icon(
                                            Icons.tips_and_updates_outlined,
                                            color:
                                                colorScheme.onPrimaryContainer,
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
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(34),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, topInset + 18, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.medical_services_outlined,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MicroSync',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.76),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Welcome${(user.displayName ?? '').isNotEmpty ? ', ${user.displayName}' : ''}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.14,
                        ),
                      ),
                    ],
                  ),
                ),
                if ((user.update ?? '').isNotEmpty)
                  Text(
                    user.update!,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.76),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.route_outlined, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Today\'s route',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan == null
                              ? 'No day plan found for today'
                              : '${plan.area} • ${plan.doctors.length} doctors',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onStartDay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F766E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 22),
                    label: const Text(
                      'Start day',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onChangePlan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.edit_calendar_outlined, size: 20),
                    label: const Text(
                      'Change plan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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

    return _DashboardInfoCard(
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

    return _DashboardInfoCard(
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

class _DashboardInfoCard extends StatelessWidget {
  const _DashboardInfoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.34),
        ),
      ),
      child: child,
    );
  }
}
