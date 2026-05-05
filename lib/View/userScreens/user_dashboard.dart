import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/models/day_plan_model.dart';
import 'package:micro_pharma/models/dcr_model.dart';
import 'package:micro_pharma/models/order_model.dart';
import 'package:micro_pharma/viewModel/daily_call_report_provider.dart';
import 'package:micro_pharma/viewModel/day_plans_provider.dart';
import 'package:micro_pharma/viewModel/doctor_provider.dart';
import 'package:micro_pharma/viewModel/order_data_provider.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  static const String id = 'user_dashboard';
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshDashboard());
  }

  Future<void> _refreshDashboard() async {
    final doctorProvider = context.read<DoctorDataProvider>();
    final dcrProvider = context.read<DailyCallReportProvider>();
    final orderProvider = context.read<OrderDataProvider>();
    final dayPlanProvider = context.read<DayPlanProvider>();

    setState(() => _isLoading = true);

    await Future.wait([
      doctorProvider.fetchDoctors(),
      dcrProvider.fetchReports(),
      orderProvider.fetchOrders(),
      dayPlanProvider.fetchDayPlans(),
    ]);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: const MyAppBar(appBartxt: 'Live Dashboard'),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: Consumer4<DoctorDataProvider, DailyCallReportProvider,
            OrderDataProvider, DayPlanProvider>(
          builder: (context, doctorProvider, dcrProvider, orderProvider,
              dayPlanProvider, child) {
            final doctors = doctorProvider.getDoctorList;
            final reports = dcrProvider.getAllReports();
            final orders = orderProvider.getOrders;
            final todayPlan = dayPlanProvider.getCurrentDayPlan();
            final metrics = _DashboardMetrics.fromData(
              doctorsCount: doctors.length,
              reports: reports,
              orders: orders,
              todayPlan: todayPlan,
            );

            return LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding =
                    constraints.maxWidth < 380 ? 16.0 : 20.0;
                final isCompact = constraints.maxWidth < 680;
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    12,
                    horizontalPadding,
                    24,
                  ),
                  children: [
                    _DashboardHero(
                      metrics: metrics,
                      isLoading: _isLoading,
                      onRefresh: _refreshDashboard,
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        _MetricCard(
                          width: isCompact
                              ? constraints.maxWidth - (horizontalPadding * 2)
                              : ((constraints.maxWidth -
                                      (horizontalPadding * 2) -
                                      14) /
                                  2),
                          title: 'Today visits',
                          value: metrics.todayVisits.toString(),
                          subtitle: metrics.todayPlanLine,
                          icon: Icons.medical_services_outlined,
                          accent: const Color(0xFF22C55E),
                        ),
                        _MetricCard(
                          width: isCompact
                              ? constraints.maxWidth - (horizontalPadding * 2)
                              : ((constraints.maxWidth -
                                      (horizontalPadding * 2) -
                                      14) /
                                  2),
                          title: 'Orders this month',
                          value: metrics.monthOrders.toString(),
                          subtitle: '${metrics.monthOrderUnits} units booked',
                          icon: Icons.inventory_2_outlined,
                          accent: const Color(0xFFF97316),
                        ),
                        _MetricCard(
                          width: isCompact
                              ? constraints.maxWidth - (horizontalPadding * 2)
                              : ((constraints.maxWidth -
                                      (horizontalPadding * 2) -
                                      14) /
                                  2),
                          title: 'Coverage',
                          value:
                              '${metrics.coveragePercent.toStringAsFixed(0)}%',
                          subtitle:
                              '${metrics.uniqueDoctorsVisited}/${metrics.totalDoctors} doctors reached',
                          icon: Icons.track_changes_outlined,
                          accent: const Color(0xFF14B8A6),
                        ),
                        _MetricCard(
                          width: isCompact
                              ? constraints.maxWidth - (horizontalPadding * 2)
                              : ((constraints.maxWidth -
                                      (horizontalPadding * 2) -
                                      14) /
                                  2),
                          title: 'DCR submitted',
                          value: metrics.submittedDays.toString(),
                          subtitle:
                              '${metrics.pendingDays} days pending this month',
                          icon: Icons.assignment_turned_in_outlined,
                          accent: const Color(0xFF8B5CF6),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    isCompact
                        ? Column(
                            children: [
                              _InsightCard(metrics: metrics),
                              const SizedBox(height: 14),
                              _ActivityCard(metrics: metrics),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _InsightCard(metrics: metrics)),
                              const SizedBox(width: 14),
                              Expanded(child: _ActivityCard(metrics: metrics)),
                            ],
                          ),
                    const SizedBox(height: 18),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Field rhythm',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'A quick read on how the month is moving.',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 18),
                            _ProgressRow(
                              label: 'Doctor coverage',
                              value: metrics.coveragePercent / 100,
                              trailing:
                                  '${metrics.uniqueDoctorsVisited}/${metrics.totalDoctors}',
                              color: const Color(0xFF14B8A6),
                            ),
                            const SizedBox(height: 14),
                            _ProgressRow(
                              label: 'DCR completion',
                              value: metrics.dcrCompletionPercent / 100,
                              trailing:
                                  '${metrics.submittedDays}/${metrics.daysElapsedThisMonth}',
                              color: const Color(0xFF8B5CF6),
                            ),
                            const SizedBox(height: 14),
                            _ProgressRow(
                              label: 'Plan execution',
                              value: metrics.planExecutionPercent / 100,
                              trailing:
                                  '${metrics.daysWithPlansCompleted}/${metrics.monthPlans}',
                              color: colorScheme.primary,
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
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({
    required this.metrics,
    required this.isLoading,
    required this.onRefresh,
  });

  final _DashboardMetrics metrics;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF155E75), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.22),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -10,
            top: -18,
            child: Container(
              height: 110,
              width: 110,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -24,
            bottom: -34,
            child: Container(
              height: 130,
              width: 130,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Live overview',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton.filledTonal(
                      onPressed: isLoading ? null : onRefresh,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.16),
                        foregroundColor: Colors.white,
                      ),
                      icon: isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  metrics.heroHeadline,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 29,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  metrics.heroSubline,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.86),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _HeroBadge(
                      icon: Icons.calendar_today_outlined,
                      label: metrics.todayLabel,
                    ),
                    _HeroBadge(
                      icon: Icons.route_outlined,
                      label: metrics.todayPlanLine,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.width,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final double width;
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(height: 16),
              Text(title, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 6),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.metrics});

  final _DashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Highlights', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'What stands out right now.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            _InfoTile(
              title: 'Average calls per submitted day',
              value: metrics.averageCalls.toStringAsFixed(1),
            ),
            const SizedBox(height: 12),
            _InfoTile(
              title: 'Best booked area',
              value: metrics.topOrderArea,
            ),
            const SizedBox(height: 12),
            _InfoTile(
              title: 'Most active weekday',
              value: metrics.bestWeekday,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.metrics});

  final _DashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Submission pulse', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'This month at a glance.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            _InfoTile(
              title: 'Today status',
              value: metrics.todaySubmitted ? 'Submitted' : 'Pending',
            ),
            const SizedBox(height: 12),
            _InfoTile(
              title: 'Doctors missed so far',
              value: metrics.missedDoctors.toString(),
            ),
            const SizedBox(height: 12),
            _InfoTile(
              title: 'Days without a day plan',
              value: metrics.unplannedDays.toString(),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.3),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.trailing,
    required this.color,
  });

  final String label;
  final double value;
  final String trailing;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
            Text(trailing, style: theme.textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: clampedValue,
            backgroundColor:
                theme.colorScheme.surfaceContainerHighest.withOpacity(0.65),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _DashboardMetrics {
  _DashboardMetrics({
    required this.totalDoctors,
    required this.uniqueDoctorsVisited,
    required this.missedDoctors,
    required this.todayVisits,
    required this.submittedDays,
    required this.pendingDays,
    required this.averageCalls,
    required this.coveragePercent,
    required this.dcrCompletionPercent,
    required this.monthOrders,
    required this.monthOrderUnits,
    required this.topOrderArea,
    required this.bestWeekday,
    required this.todaySubmitted,
    required this.monthPlans,
    required this.daysWithPlansCompleted,
    required this.planExecutionPercent,
    required this.unplannedDays,
    required this.todayPlanLine,
    required this.todayLabel,
    required this.heroHeadline,
    required this.heroSubline,
    required this.daysElapsedThisMonth,
  });

  final int totalDoctors;
  final int uniqueDoctorsVisited;
  final int missedDoctors;
  final int todayVisits;
  final int submittedDays;
  final int pendingDays;
  final double averageCalls;
  final double coveragePercent;
  final double dcrCompletionPercent;
  final int monthOrders;
  final int monthOrderUnits;
  final String topOrderArea;
  final String bestWeekday;
  final bool todaySubmitted;
  final int monthPlans;
  final int daysWithPlansCompleted;
  final double planExecutionPercent;
  final int unplannedDays;
  final String todayPlanLine;
  final String todayLabel;
  final String heroHeadline;
  final String heroSubline;
  final int daysElapsedThisMonth;

  static _DashboardMetrics fromData({
    required int doctorsCount,
    required List<DailyCallReportModel> reports,
    required List<OrderModel> orders,
    required DayPlanModel? todayPlan,
  }) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    final monthReports = reports
        .where((report) =>
            !report.date.isBefore(startOfMonth) &&
            !report.date.isAfter(endOfMonth))
        .toList();
    final monthOrdersData = orders
        .where((order) =>
            !order.date.isBefore(startOfMonth) &&
            !order.date.isAfter(endOfMonth))
        .toList();

    final uniqueVisited = <String>{};
    int todayVisits = 0;
    int monthOrderUnits = 0;
    final areaBookingCounts = <String, int>{};
    final weekdayCounts = <int, int>{};

    for (final report in monthReports) {
      weekdayCounts.update(
        report.date.weekday,
        (count) => count + report.doctorsVisited.length,
        ifAbsent: () => report.doctorsVisited.length,
      );

      if (_isSameDay(report.date, now)) {
        todayVisits += report.doctorsVisited.length;
      }

      for (final visit in report.doctorsVisited) {
        final doctorName = (visit.name ?? '').trim().toLowerCase();
        if (doctorName.isNotEmpty) {
          uniqueVisited.add(doctorName);
        }
      }
    }

    for (final order in monthOrdersData) {
      monthOrderUnits += order.products.fold<int>(
        0,
        (sum, product) => sum + (int.tryParse(product.quantity) ?? 0),
      );
      areaBookingCounts.update(
        order.area.trim().isEmpty ? 'Unassigned' : order.area,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    final submittedDays = monthReports.length;
    final daysElapsed = now.day;
    final pendingDays =
        (daysElapsed - submittedDays).clamp(0, daysElapsed).toInt();
    final coveragePercent =
        doctorsCount == 0 ? 0.0 : (uniqueVisited.length / doctorsCount) * 100;
    final dcrCompletionPercent =
        daysElapsed == 0 ? 0.0 : (submittedDays / daysElapsed) * 100;
    final averageCalls = submittedDays == 0
        ? 0.0
        : monthReports.fold<int>(
              0,
              (sum, report) => sum + report.doctorsVisited.length,
            ) /
            submittedDays;
    final monthPlans = daysElapsed;
    final daysWithPlansCompleted =
        monthReports.where((report) => report.doctorsVisited.isNotEmpty).length;
    final planExecutionPercent =
        monthPlans == 0 ? 0.0 : (daysWithPlansCompleted / monthPlans) * 100;
    final unplannedDays = pendingDays;
    final todaySubmitted =
        monthReports.any((report) => _isSameDay(report.date, now));
    final topOrderArea = areaBookingCounts.entries.isEmpty
        ? 'No bookings yet'
        : (areaBookingCounts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first
            .key;
    const weekdayNames = <int, String>{
      DateTime.monday: 'Monday',
      DateTime.tuesday: 'Tuesday',
      DateTime.wednesday: 'Wednesday',
      DateTime.thursday: 'Thursday',
      DateTime.friday: 'Friday',
      DateTime.saturday: 'Saturday',
      DateTime.sunday: 'Sunday',
    };
    final bestWeekday = weekdayCounts.entries.isEmpty
        ? 'No pattern yet'
        : weekdayNames[(weekdayCounts.entries
                .reduce((a, b) => a.value >= b.value ? a : b)
                .key)] ??
            'No pattern yet';
    final todayPlanLine = todayPlan == null
        ? 'No route planned for today'
        : '${todayPlan.area} - ${todayPlan.doctors.length} doctors';
    final heroHeadline = todaySubmitted
        ? 'Day tracked and moving.'
        : 'A strong field day starts here.';
    final heroSubline = todayPlan == null
        ? 'There is no assigned route for today yet. Pull to refresh when new plans are ready.'
        : 'Today is focused on ${todayPlan.area}. Keep momentum through visits, reporting, and booked orders.';

    return _DashboardMetrics(
      totalDoctors: doctorsCount,
      uniqueDoctorsVisited: uniqueVisited.length,
      missedDoctors:
          (doctorsCount - uniqueVisited.length).clamp(0, doctorsCount),
      todayVisits: todayVisits,
      submittedDays: submittedDays,
      pendingDays: pendingDays,
      averageCalls: averageCalls,
      coveragePercent: coveragePercent,
      dcrCompletionPercent: dcrCompletionPercent,
      monthOrders: monthOrdersData.length,
      monthOrderUnits: monthOrderUnits,
      topOrderArea: topOrderArea,
      bestWeekday: bestWeekday,
      todaySubmitted: todaySubmitted,
      monthPlans: monthPlans,
      daysWithPlansCompleted: daysWithPlansCompleted,
      planExecutionPercent: planExecutionPercent,
      unplannedDays: unplannedDays,
      todayPlanLine: todayPlanLine,
      todayLabel: DateFormat('EEEE, d MMM').format(now),
      heroHeadline: heroHeadline,
      heroSubline: heroSubline,
      daysElapsedThisMonth: daysElapsed,
    );
  }

  static bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
