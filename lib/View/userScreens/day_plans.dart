import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import '../../components/constants.dart';
import '../../models/day_plan_model.dart';
import '../../viewModel/day_plans_provider.dart';
import 'Call Planner Page/call_planner.dart';
import 'package:pdf/widgets.dart' as pw;

class DayPlansScreen extends StatefulWidget {
  static const String id = 'day_plans';

  const DayPlansScreen({Key? key}) : super(key: key);

  @override
  DayPlansScreenState createState() => DayPlansScreenState();
}

class DayPlansScreenState extends State<DayPlansScreen> {
  String? selectedArea;

  @override
  void initState() {
    super.initState();

    Provider.of<DayPlanProvider>(context, listen: false).fetchDayPlans();

    final dayPlans =
        Provider.of<DayPlanProvider>(context, listen: false).dayPlans;
    dayPlans.sort((a, b) => b.date.compareTo(a.date));

    final List<String> areas =
        dayPlans.map((dayPlan) => dayPlan.area).toSet().toList();

    if (areas.isNotEmpty) {
      selectedArea = areas[0];
    }
  }

  Future<void> _refreshDayPlans(BuildContext context) async {
    await Provider.of<DayPlanProvider>(context, listen: false).fetchDayPlans();
  }

  @override
  Widget build(BuildContext context) {
    final dayPlans = Provider.of<DayPlanProvider>(context).dayPlans;
    dayPlans.sort((a, b) => b.date.compareTo(a.date));

    // Create a list of unique areas from dayPlans
    final List<String> areas =
        dayPlans.map((dayPlan) => dayPlan.area).toSet().toList();

    // Define variables to hold the selected area

    return Scaffold(
      floatingActionButton: PopupMenuButton(
        itemBuilder: (BuildContext context) {
          return [
            const PopupMenuItem(
              value: 'add_call_plan',
              child: ListTile(
                leading: Icon(Icons.calendar_view_day_outlined),
                title: Text('Add New Call Plan'),
              ),
            ),
            const PopupMenuItem(
              value: 'export_pdf',
              child: ListTile(
                leading: Icon(Icons.save),
                title: Text('Export to PDF'),
              ),
            ),
          ];
        },
        onSelected: (String value) {
          if (value == 'add_call_plan') {
            Navigator.pushNamed(context, CallPlanner.id);
          } else if (value == 'export_pdf') {
            _generatePDFFile(dayPlans);
          }
        },
        child: const Icon(Icons.more_vert),
      ),
      appBar: const MyAppBar(
        appBartxt: 'Call Plans',
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshDayPlans(context),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedArea,
              items: areas.map((area) {
                return DropdownMenuItem<String>(
                  value: area,
                  child: Text(area),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedArea = newValue;
                  });
                }
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: dayPlans.length,
                itemBuilder: (context, index) {
                  final dayPlan = dayPlans[index];
                  if (dayPlan.area != selectedArea) {
                    return const SizedBox
                        .shrink(); // Skip rendering if the area doesn't match the selected area
                  }
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
                        boxShadow: const [
                          BoxShadow(
                              blurRadius: 5,
                              blurStyle: BlurStyle.outer,
                              color: Colors.grey)
                        ],
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.blue.shade100,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
      ),
    );
  }

  Future<void> _generatePDFFile(List<DayPlanModel> dayPlans) async {
    final fontData =
        await rootBundle.load('assets/Poppins/Poppins-Regular.ttf');
    final pw.Font ttfFont = pw.Font.ttf(fontData);

    final pw.ThemeData theme = pw.ThemeData.withFont(base: ttfFont);
    final pdf = pw.Document(theme: theme);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          final List<pw.Widget> dayPlanWidgets = [];

          for (final dayPlan in dayPlans) {
            dayPlanWidgets.add(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Date: ${dayPlan.date.toIso8601String()}',
                    style: const pw.TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  pw.SizedBox(height: 8.0),
                  pw.Text(
                    'Area: ${dayPlan.area}',
                    style: const pw.TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  pw.SizedBox(height: 8.0),
                  pw.Text(
                    'Doctors: ${dayPlan.doctors.join(', ')}',
                    style: const pw.TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  pw.SizedBox(height: 8.0),
                  pw.Text(
                    'Shift: ${dayPlan.shift}',
                    style: const pw.TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  pw.Divider(), // Add a divider between day plans
                ],
              ),
            );
          }

          return pw.Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: dayPlanWidgets,
          );
        },
      ),
    );

    try {
      final storageDir = await getExternalStorageDirectory();
      final filePath = path.join(storageDir!.path, 'day_plans_report.pdf');
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      if (await file.exists()) {
        OpenFile.open(filePath);
        print('PDF saved');
      } else {
        print('Error: PDF file not found');
      }
    } catch (e, stackTrace) {
      print('Error generating PDF: $e');
      print(stackTrace);
    }
  }
}
