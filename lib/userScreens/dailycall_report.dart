import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/models/day_plan_model.dart';
import 'package:micro_pharma/models/product_model.dart';
import 'package:micro_pharma/providers/day_plans_provider.dart';
import 'package:micro_pharma/providers/product_data_provider.dart';
import 'package:provider/provider.dart';

class DailyCallReportScreen extends StatefulWidget {
  const DailyCallReportScreen({super.key});

  @override
  State<DailyCallReportScreen> createState() => _DailyCallReportScreenState();
}

class _DailyCallReportScreenState extends State<DailyCallReportScreen> {
  late List<ProductModel> products;
  DayPlanModel? currentDayPlan;

  bool visitedDoctor = false;
  @override
  void initState() {
    print(DateTime.now());
    Provider.of<ProductDataProvider>(context, listen: false)
        .fetchProductsList();
    products =
        Provider.of<ProductDataProvider>(context, listen: false).productsList;
    Provider.of<DayPlanProvider>(context, listen: false).fetchDayPlans();
    currentDayPlan = Provider.of<DayPlanProvider>(context, listen: false)
        .getCurrentDayPlan();
    super.initState();
  }

  String dayPlanTime() {
    DateFormat dateFormat = DateFormat('EEEE dd/MM/yyyy'); // create date format
    String formattedDate =
        dateFormat.format(currentDayPlan!.date); // format current date
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    print(currentDayPlan?.date);
    return Scaffold(
      appBar: const MyAppBar(appBartxt: 'Daily Call Report'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MyTextwidget(
              text:
                  'Doctors According to your today\'s Day Plan: ${dayPlanTime()}',
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (currentDayPlan != null)
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: currentDayPlan!.doctors.length,
                  itemBuilder: (context, index) {
                    final dayPlanDoctors = currentDayPlan!.doctors;

                    return Card(
                      color: Colors.teal[100],
                      child: ListTile(
                        title: MyTextwidget(
                          text: dayPlanDoctors[index],
                          fontSize: 16,
                        ),
                        trailing: TextButton(
                          child: MyTextwidget(text: 'Add Doctor Info'),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (
                                  context,
                                ) {
                                  return Dialog();
                                });
                          },
                        ),
                        subtitle: Row(
                          children: [
                            MyTextwidget(text: 'Visited?'),
                            Checkbox(
                              value: visitedDoctor,
                              onChanged: (value) {},
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          MyButton(text: 'Submit Report', onPressed: () {})
        ],
      ),
    );
  }
}
