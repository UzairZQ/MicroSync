import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/View/userScreens/User%20Home%20Page/privacy_consent_dialog.dart';
import 'package:micro_pharma/models/day_plan_model.dart';
import 'package:micro_pharma/models/user_model.dart';
import 'package:micro_pharma/services/location_services.dart';
import 'package:micro_pharma/viewModel/daily_call_report_provider.dart';
import 'package:micro_pharma/viewModel/day_plans_provider.dart';
import 'package:micro_pharma/viewModel/order_data_provider.dart';
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
  bool _isUpdatingWorkDay = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (currentUser == null) {
        return;
      }

      await context.read<UserDataProvider>().fetchUserData(currentUser!.uid);
      await context.read<DayPlanProvider>().fetchDayPlans();
      await context.read<DailyCallReportProvider>().fetchReports();
      await context.read<OrderDataProvider>().fetchOrders();
      if (!mounted) {
        return;
      }

      if (!_hasInitializedLocation) {
        _hasInitializedLocation = true;
        await showPrivacyConsentDialog(currentUser!.uid);
        await LocationServices().resumeTrackingIfNeeded();
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
      context.read<DailyCallReportProvider>().fetchReports(),
      context.read<OrderDataProvider>().fetchOrders(),
    ]);
  }

  Future<void> _startDay() async {
    if (currentUser == null || _isUpdatingWorkDay) {
      return;
    }

    setState(() => _isUpdatingWorkDay = true);
    final success =
        await LocationServices().startWorkDayTracking(currentUser!.uid);
    if (mounted) {
      await context.read<UserDataProvider>().fetchUserData(currentUser!.uid);
      setState(() => _isUpdatingWorkDay = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Day started. Live location tracking is active.'
                : 'Location permission is required before starting the day.',
          ),
        ),
      );
    }
  }

  Future<void> _endDay() async {
    if (currentUser == null || _isUpdatingWorkDay) {
      return;
    }

    setState(() => _isUpdatingWorkDay = true);
    final success = await LocationServices().endWorkDayTracking(
      currentUser!.uid,
    );
    if (mounted) {
      await context.read<UserDataProvider>().fetchUserData(currentUser!.uid);
      setState(() => _isUpdatingWorkDay = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Day ended. Location tracking has stopped.'
                : 'Could not end the day. Please try again.',
          ),
        ),
      );
    }
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

              final dcrProvider = context.watch<DailyCallReportProvider>();
              final orderProvider = context.watch<OrderDataProvider>();

              // Calculate today's visits progress
              final todayReport = dcrProvider.getReportForCurrentDate();
              final int completedVisits = todayReport?.doctorsVisited.length ?? 0;
              final int totalPlannedVisits = todayPlan?.doctors.length ?? 0;

              // Calculate monthly stats for performance card
              final now = DateTime.now();
              final startOfMonth = DateTime(now.year, now.month, 1);
              final startOfNextMonth = DateTime(now.year, now.month + 1, 1);
              final repName = user.displayName?.trim().toLowerCase();

              final monthOrders = orderProvider.getOrders.where((order) {
                final isCurrentRep = repName == null || repName.isEmpty || order.userName.trim().toLowerCase() == repName;
                final isThisMonth = !order.date.isBefore(startOfMonth) && order.date.isBefore(startOfNextMonth);
                return isCurrentRep && isThisMonth;
              }).toList();

              int monthOrderUnits = 0;
              for (final order in monthOrders) {
                for (final product in order.products) {
                  monthOrderUnits += int.tryParse(product.quantity) ?? 0;
                }
              }

              final monthReports = dcrProvider.getAllReports().where((report) {
                final isCurrentRep = repName == null || repName.isEmpty || report.submittedBy.trim().toLowerCase() == repName;
                final isThisMonth = !report.date.isBefore(startOfMonth) && report.date.isBefore(startOfNextMonth);
                return isCurrentRep && isThisMonth;
              }).toList();

              int monthVisits = 0;
              for (final report in monthReports) {
                monthVisits += report.doctorsVisited.length;
              }

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
                        isUpdatingWorkDay: _isUpdatingWorkDay,
                        onStartDay: _startDay,
                        onEndDay: _endDay,
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
                                      _QuickStatsCard(
                                        todayPlan: todayPlan,
                                        completedVisits: completedVisits,
                                        totalVisits: totalPlannedVisits,
                                      ),
                                      const SizedBox(height: 14),
                                      _PerformanceCard(
                                        monthVisits: monthVisits,
                                        monthOrders: monthOrders.length,
                                        monthOrderUnits: monthOrderUnits,
                                      ),
                                    ],
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _QuickStatsCard(
                                          todayPlan: todayPlan,
                                          completedVisits: completedVisits,
                                          totalVisits: totalPlannedVisits,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: _PerformanceCard(
                                          monthVisits: monthVisits,
                                          monthOrders: monthOrders.length,
                                          monthOrderUnits: monthOrderUnits,
                                        ),
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
    required this.isUpdatingWorkDay,
    required this.onStartDay,
    required this.onEndDay,
    required this.onChangePlan,
  });

  final UserModel user;
  final DayPlanModel? todayPlan;
  final bool isUpdatingWorkDay;
  final Future<void> Function() onStartDay;
  final Future<void> Function() onEndDay;
  final VoidCallback onChangePlan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plan = todayPlan;
    final topInset = MediaQuery.paddingOf(context).top;
    final isDayActive = user.locationTrackingActive;

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
                if (isDayActive || (user.update ?? '').isNotEmpty)
                  Text(
                    isDayActive ? 'Tracking live' : user.update!,
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
                    onPressed: isUpdatingWorkDay
                        ? null
                        : isDayActive
                            ? () => onEndDay()
                            : () => onStartDay(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: isDayActive
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFF0F766E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    icon: Icon(
                      isUpdatingWorkDay
                          ? Icons.hourglass_top_rounded
                          : isDayActive
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                      size: 22,
                    ),
                    label: Text(
                      isUpdatingWorkDay
                          ? 'Please wait'
                          : isDayActive
                              ? 'End day'
                              : 'Start day',
                      style: const TextStyle(
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
  const _QuickStatsCard({
    required this.todayPlan,
    required this.completedVisits,
    required this.totalVisits,
  });

  final DayPlanModel? todayPlan;
  final int completedVisits;
  final int totalVisits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double progress = totalVisits > 0 ? (completedVisits / totalVisits) : 0.0;

    return _DashboardInfoCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today at a glance', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _MiniStat(
              label: 'Area',
              value: todayPlan?.area ?? 'Pending',
              icon: Icons.location_on_outlined,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _MiniStat(
              label: 'Shift',
              value: todayPlan?.shift ?? 'Not assigned',
              icon: Icons.access_time_outlined,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.teal.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.medical_services_outlined, color: Colors.teal, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Visit Progress', 
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$completedVisits / $totalVisits Visited',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (totalVisits > 0) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.teal.withOpacity(0.15),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({
    required this.monthVisits,
    required this.monthOrders,
    required this.monthOrderUnits,
  });

  final int monthVisits;
  final int monthOrders;
  final int monthOrderUnits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _DashboardInfoCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Performance (Month)', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _MiniStat(
              label: 'Visits Logged', 
              value: '$monthVisits visits',
              icon: Icons.assignment_ind_outlined,
              color: Colors.indigo,
            ),
            const SizedBox(height: 12),
            _MiniStat(
              label: 'Orders Sent', 
              value: '$monthOrders orders',
              icon: Icons.receipt_long_outlined,
              color: Colors.purple,
            ),
            const SizedBox(height: 12),
            _MiniStat(
              label: 'Product Units',
              value: '$monthOrderUnits units',
              icon: Icons.medication_outlined,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label, 
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label, 
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
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
