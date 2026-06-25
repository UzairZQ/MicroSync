import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:micro_pharma/View/userScreens/Call%20Planner%20Page/call_planner.dart';
import 'package:provider/provider.dart';
import '../../components/constants.dart';
import '../../viewModel/day_plans_provider.dart';

class CallPlansForAdmin extends StatefulWidget {
  static const String id = 'call_plans';

  const CallPlansForAdmin({super.key});

  @override
  CallPlansForAdminState createState() => CallPlansForAdminState();
}

class CallPlansForAdminState extends State<CallPlansForAdmin> {
  String? selectedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DayPlanProvider>().fetchDayPlans();
    });
  }

  Future<void> _refreshDayPlans(BuildContext context) async {
    await Provider.of<DayPlanProvider>(context, listen: false).fetchDayPlans();
  }

  @override
  Widget build(BuildContext context) {
    final dayPlans = Provider.of<DayPlanProvider>(context).dayPlans;
    dayPlans.sort((a, b) => b.date.compareTo(a.date));

    final areas = dayPlans.map((dayPlan) => dayPlan.area).toSet().toList()
      ..sort();
    final filteredPlans = selectedFilter == null
        ? dayPlans
        : dayPlans.where((plan) => plan.area == selectedFilter).toList();
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.calendar_view_day_outlined),
            onPressed: () {
              Navigator.pushNamed(context, CallPlanner.id);
            },
            label: const MyTextwidget(
              text: 'Add New Call Plan',
              fontSize: 14,
            )),
        appBar: const MyAppBar(
          appBartxt: 'Call Plans',
        ),
        body: RefreshIndicator(
          onRefresh: () => _refreshDayPlans(context),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              DropdownButtonFormField<String?>(
                value: selectedFilter,
                decoration: const InputDecoration(
                  labelText: 'Filter by area',
                  prefixIcon: Icon(Icons.filter_alt_outlined),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All areas'),
                  ),
                  ...areas.map((area) {
                    return DropdownMenuItem<String?>(
                      value: area,
                      child: Text(area),
                    );
                  }),
                ],
                onChanged: (String? newValue) {
                  setState(() => selectedFilter = newValue);
                },
              ),
              const SizedBox(height: 14),
              if (filteredPlans.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: Text('No call plans for this area.')),
                )
              else
                ...filteredPlans.map((dayPlan) {
                  String dayPlanTime() {
                    DateFormat dateFormat = DateFormat('EEEE dd/MM/yyyy');
                    return dateFormat.format(dayPlan.date);
                  }

                  return Card(
                    elevation: 2,
                    shadowColor:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.12),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: [
                            kappbarColor.withOpacity(0.12),
                            const Color(0xFF0D9488).withOpacity(0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      kappbarColor.withOpacity(0.14),
                                  child: Icon(Icons.route_outlined,
                                      color: kappbarColor),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyTextwidget(
                                        fontSize: 15,
                                        text: dayPlan.userName,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      Text(
                                        '${dayPlan.area} • ${dayPlan.shift}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14.0),
                            Row(
                              children: [
                                Icon(Icons.date_range, color: kappbarColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: MyTextwidget(
                                    text: dayPlanTime(),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.medical_services_outlined,
                                    color: kappbarColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: MyTextwidget(
                                    text:
                                        '${dayPlan.doctors.length} doctors: ${dayPlan.doctors.join(', ')}',
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ));
  }
}
