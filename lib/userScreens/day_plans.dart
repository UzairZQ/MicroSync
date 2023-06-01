// import 'dart:io';

// import 'package:flutter/services.dart';
// import 'package:path/path.dart' as path;
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:micro_pharma/userScreens/call_planner.dart';
// import 'package:open_file/open_file.dart';
// import 'package:provider/provider.dart';
// import '../components/constants.dart';
// import '../models/day_plan_model.dart';
// import '../providers/day_plans_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';

// class DayPlansScreen extends StatefulWidget {
//   static const String id = 'day_plans';

//   const DayPlansScreen({super.key});

//   @override
//   DayPlansScreenState createState() => DayPlansScreenState();
// }

// class DayPlansScreenState extends State<DayPlansScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Provider.of<DayPlanProvider>(context, listen: false).fetchDayPlans();
//   }

//   Future<void> _refreshDayPlans(BuildContext context) async {
//     await Provider.of<DayPlanProvider>(context, listen: false).fetchDayPlans();
//   }

//   Future<void> _generatePDF(List<DayPlanModel> dayPlans) async {
//     final pdf = pw.Document();

//     // Load the Roboto font
//     final poppinsFont =
//         await rootBundle.load('assets/Poppins/Poppins-Regular.ttf');
//     final ttfFont = pw.Font.ttf(poppinsFont);

//     for (final dayPlan in dayPlans) {
//       String dayPlanTime() {
//         DateFormat dateFormat = DateFormat('EEEE dd/MM/yyyy');
//         String formattedDate = dateFormat.format(dayPlan.date);
//         return formattedDate;
//       }

//       pdf.addPage(
//         pw.Page(
//           build: (pw.Context context) {
//             return pw.Container(
//               decoration: pw.BoxDecoration(
//                 borderRadius: pw.BorderRadius.circular(15.0),
//                 color: PdfColors.blue100,
//               ),
//               child: pw.Padding(
//                 padding: const pw.EdgeInsets.all(16.0),
//                 child: pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     pw.Text(
//                       'Date: ${dayPlanTime()}',
//                       style: pw.TextStyle(
//                         fontSize: 14,
//                         font: ttfFont,
//                       ),
//                     ),
//                     pw.SizedBox(height: 8.0),
//                     pw.Text(
//                       'Area: ${dayPlan.area}',
//                       style: pw.TextStyle(
//                         fontSize: 14,
//                         font: ttfFont,
//                       ),
//                     ),
//                     pw.SizedBox(height: 8.0),
//                     pw.Text(
//                       'Doctors: ${dayPlan.doctors.join(' , ')}',
//                       style: pw.TextStyle(
//                         fontSize: 15,
//                         font: ttfFont,
//                       ),
//                     ),
//                     pw.SizedBox(height: 8.0),
//                     pw.Text(
//                       'Shift: ${dayPlan.shift}',
//                       style: pw.TextStyle(
//                         fontSize: 14,
//                         font: ttfFont,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       );
//     }
//     try {
//       final tempDir = await getTemporaryDirectory();
//       final filePath = path.join(tempDir.path, 'day_plans_report.pdf');
//       final file = File(filePath);
//       await file.writeAsBytes(await pdf.save());
//       if (await file.exists()) {
//         await OpenFile.open(filePath);
//       } else {
//         print('Error: PDF file not found');
//       }
//     } catch (e) {
//       print('error generating pdf $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dayPlans = Provider.of<DayPlanProvider>(context).dayPlans;
//     return Scaffold(
//       floatingActionButton: PopupMenuButton(
//         itemBuilder: (BuildContext context) {
//           return [
//             const PopupMenuItem(
//               value: 'add_call_plan',
//               child: ListTile(
//                 leading: Icon(Icons.calendar_view_day_outlined),
//                 title: Text('Add New Call Plan'),
//               ),
//             ),
//             const PopupMenuItem(
//               value: 'export_pdf',
//               child: ListTile(
//                 leading: Icon(Icons.save),
//                 title: Text('Export to PDF'),
//               ),
//             ),
//           ];
//         },
//         onSelected: (String value) {
//           if (value == 'add_call_plan') {
//             Navigator.pushNamed(context, CallPlanner.id);
//           } else if (value == 'export_pdf') {
//             _generatePDF(dayPlans);
//           }
//         },
//         child: const Icon(Icons.more_vert),
//       ),
//       appBar: const MyAppBar(
//         appBartxt: 'Call Plans',
//       ),
//       body: RefreshIndicator(
//         onRefresh: () => _refreshDayPlans(context),
//         child: ListView.builder(
//           itemCount: dayPlans.length,
//           itemBuilder: (context, index) {
//             final dayPlan = dayPlans[index];

//             String dayPlanTime() {
//               DateFormat dateFormat =
//                   DateFormat('EEEE dd/MM/yyyy'); // create date format
//               String formattedDate =
//                   dateFormat.format(dayPlan.date); // format current date
//               return formattedDate;
//             }

//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(15.0),
//                   color: Colors.blue.shade100,
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       MyTextwidget(
//                         text: 'Date : ${dayPlanTime()}',
//                         fontSize: 14,
//                       ),
//                       const SizedBox(height: 8.0),
//                       MyTextwidget(
//                         text: 'Area: ${dayPlan.area}',
//                         fontSize: 14,
//                       ),
//                       const SizedBox(height: 8.0),
//                       MyTextwidget(
//                         text: 'Doctors: ${dayPlan.doctors.join(' , ')}',
//                         fontSize: 15,
//                       ),
//                       const SizedBox(height: 8.0),
//                       MyTextwidget(
//                         text: 'Shift: ${dayPlan.shift}',
//                         fontSize: 14,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import '../components/constants.dart';
import '../models/day_plan_model.dart';
import '../providers/day_plans_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'call_planner.dart';

class DayPlansScreen extends StatefulWidget {
  static const String id = 'day_plans';

  const DayPlansScreen({Key? key}) : super(key: key);

  @override
  DayPlansScreenState createState() => DayPlansScreenState();
}

class DayPlansScreenState extends State<DayPlansScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<DayPlanProvider>(context, listen: false).fetchDayPlans();
  }

  Future<void> _refreshDayPlans(BuildContext context) async {
    await Provider.of<DayPlanProvider>(context, listen: false).fetchDayPlans();
  }

  Future<void> _generatePDF(List<DayPlanModel> dayPlans) async {
    final pdf = pw.Document();

    
    final fontData =
        await rootBundle.load('assets/Poppins/Poppins-Regular.ttf');
    final ttfFont = pw.Font.ttf(fontData);

    for (final dayPlan in dayPlans) {
      String dayPlanTime() {
        DateFormat dateFormat = DateFormat('EEEE dd/MM/yyyy');
        String formattedDate = dateFormat.format(dayPlan.date);
        return formattedDate;
      }

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                borderRadius: pw.BorderRadius.circular(15.0),
                color: PdfColors.blue100,
              ),
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(16.0),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Date: ${dayPlanTime()}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        font: ttfFont,
                      ),
                    ),
                    pw.SizedBox(height: 8.0),
                    pw.Text(
                      'Area: ${dayPlan.area}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        font: ttfFont,
                      ),
                    ),
                    pw.SizedBox(height: 8.0),
                    pw.Text(
                      'Doctors: ${dayPlan.doctors.join(' , ')}',
                      style: pw.TextStyle(
                        fontSize: 15,
                        font: ttfFont,
                      ),
                    ),
                    pw.SizedBox(height: 8.0),
                    pw.Text(
                      'Shift: ${dayPlan.shift}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        font: ttfFont,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = path.join(tempDir.path, 'day_plans_report.pdf');
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      if (await file.exists()) {
        OpenFile.open(filePath);
      } else {
        print('Error: PDF file not found');
      }
    } catch (e) {
      print('Error generating PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayPlans = Provider.of<DayPlanProvider>(context).dayPlans;
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
            _generatePDF(dayPlans);
          }
        },
        child: const Icon(Icons.more_vert),
      ),
      appBar: const MyAppBar(
        appBartxt: 'Call Plans', 
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshDayPlans(context),
        child: ListView.builder(
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
                      MyTextwidget(
                        text: 'Date : ${dayPlanTime()}',
                        fontSize: 14,
                      ),
                      const SizedBox(height: 8.0),
                      MyTextwidget(
                        text: 'Area: ${dayPlan.area}',
                        fontSize: 14,
                      ),
                      const SizedBox(height: 8.0),
                      MyTextwidget(
                        text: 'Doctors: ${dayPlan.doctors.join(' , ')}',
                        fontSize: 15,
                      ),
                      const SizedBox(height: 8.0),
                      MyTextwidget(
                        text: 'Shift: ${dayPlan.shift}',
                        fontSize: 14,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
