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

  const DayPlansScreen({super.key});

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
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedArea,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blueGrey),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
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
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: dayPlans.length,
                itemBuilder: (context, index) {
                  final dayPlan = dayPlans[index];
                  if (dayPlan.area != selectedArea) {
                    return const SizedBox.shrink();
                  }
                  
                  final dateFormat = DateFormat('EEEE, MMM d, yyyy');
                  final formattedDate = dateFormat.format(dayPlan.date);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Left accent line
                        Container(
                          width: 5,
                          height: 120, // Approximate height
                          decoration: BoxDecoration(
                            color: kappbarColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: kappbarColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        dayPlan.shift,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: kappbarColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.place_outlined, color: Colors.orange, size: 18),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        dayPlan.area,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.medical_services_outlined, color: Colors.blue, size: 18),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        dayPlan.doctors.join(', '),
                                        style: TextStyle(
                                          fontSize: 14,
                                          height: 1.4,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
      } else {}
    } catch (e) {}
  }
}
