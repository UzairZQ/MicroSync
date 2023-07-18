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
    Provider.of<DayPlanProvider>(context, listen: false).fetchDayPlans();
  }

  Future<void> _refreshDayPlans(BuildContext context) async {
    await Provider.of<DayPlanProvider>(context, listen: false).fetchDayPlans();
  }

  @override
  Widget build(BuildContext context) {
    final dayPlans = Provider.of<DayPlanProvider>(context).dayPlans;
    dayPlans.sort((a, b) => b.date.compareTo(a.date));

    // Create a list of unique areas for filtering
    final List<String> areas =
        dayPlans.map((dayPlan) => dayPlan.area).toSet().toList();
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.calendar_view_day_outlined),
            onPressed: () {
              Navigator.pushNamed(context, CallPlanner.id);
            },
            label: MyTextwidget(
              text: 'Add New Call Plan',
              fontSize: 14,
            )),
        appBar: const MyAppBar(
          appBartxt: 'Call Plans',
        ),
        body: RefreshIndicator(
          onRefresh: () => _refreshDayPlans(context),
          child: Column(
            children: [
              DropdownButton<String>(
                value: selectedFilter,
                items: areas.map((area) {
                  return DropdownMenuItem<String>(
                    value: area,
                    child: MyTextwidget(text: area),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedFilter = newValue;
                  });
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: dayPlans.length,
                  itemBuilder: (context, index) {
                    final dayPlan = dayPlans[index];

                    String dayPlanTime() {
                      DateFormat dateFormat =
                          DateFormat('EEEE dd/MM/yyyy'); // create date format
                      String formattedDate = dateFormat
                          .format(dayPlan.date); // format current date
                      return formattedDate;
                    }

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Colors.blue.shade100,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: MyTextwidget(
                                  fontSize: 15,
                                  text: ' Submitted by: ${dayPlan.userName}',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  const Icon(Icons.date_range),
                                  MyTextwidget(
                                    text: 'Date : ${dayPlanTime()}',
                                    fontSize: 14,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  const Icon(Icons.place),
                                  MyTextwidget(
                                    text: 'Area: ${dayPlan.area}',
                                    fontSize: 14,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  const Icon(Icons.person_pin_rounded),
                                  Flexible(
                                    child: MyTextwidget(
                                      text:
                                          'Doctors: ${dayPlan.doctors.join(' , ')}',
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  const Icon(Icons.event_outlined),
                                  MyTextwidget(
                                    text: 'Shift: ${dayPlan.shift}',
                                    fontSize: 14,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
