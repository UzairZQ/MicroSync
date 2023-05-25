import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:micro_pharma/userScreens/call_planner.dart';
import 'package:provider/provider.dart';

import '../components/constants.dart';
import '../models/day_plan_model.dart';
import '../providers/day_plans_provider.dart';

class CallPlansForAdmin extends StatefulWidget {
  static const String id = 'call_plans';

  const CallPlansForAdmin({super.key});

  @override
  _CallPlansForAdminState createState() => _CallPlansForAdminState();
}

class _CallPlansForAdminState extends State<CallPlansForAdmin> {
  @override
  void initState() {
    super.initState();
    Provider.of<DayPlanProvider>(context, listen: false).fetchDayPlans();
  }

  @override
  Widget build(BuildContext context) {
    final dayPlans = Provider.of<DayPlanProvider>(context).dayPlans;
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
        body: ListView.builder(
          itemCount: dayPlans.length,
          itemBuilder: (context, index) {
            final dayPlan = dayPlans[index];

            String dayPlanTime() {
              DateFormat dateFormat =
                  DateFormat('EEEE dd/MM/yyyy'); // create date format
              String formattedDate =
                  dateFormat.format(dayPlan.date); // format current date
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
                      MyTextwidget(
                        text: 'Date : ${dayPlanTime()}',
                        fontSize: 14,
                      ),
                      const SizedBox(height: 8.0),
                      MyTextwidget(
                        text: 'Area: ${dayPlan.area}',
                        fontSize: 15,
                      ),
                      const SizedBox(height: 8.0),
                      MyTextwidget(
                        text: 'Doctors: ${dayPlan.doctors.join(' , ')}',
                        fontSize: 16,
                      ),
                      const SizedBox(height: 8.0),
                      MyTextwidget(
                        text: 'Shift: ${dayPlan.shift}',
                        fontSize: 15,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}
