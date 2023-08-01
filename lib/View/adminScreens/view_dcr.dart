import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/dcr_model.dart';
import '../../models/doctor_visit_model.dart';
import '../../viewModel/daily_call_report_provider.dart';

import 'package:pdf/widgets.dart' as pw;

class ViewDCRScreen extends StatelessWidget {
  static const String id = 'view_dcr';

  const ViewDCRScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final dcrProvider =
        Provider.of<DailyCallReportProvider>(context, listen: false);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final reports = dcrProvider.getAllReports();
          final pdf = await _generatePDFForAllReports(
            reports,
          );

          // Save the PDF to the device storage
          final String dir = (await getExternalStorageDirectory())!.path;
          final String filePath = '$dir/all_reports.pdf';
          final File file = File(filePath);
          await file.writeAsBytes(await pdf.save());

          if (await file.exists()) {
            OpenFile.open(filePath);
            print('PDF saved');
          } else {
            print('Error: PDF file not found');
          }
        },
        child: const Icon(Icons.picture_as_pdf),
      ),
      appBar: const MyAppBar(
        appBartxt: 'Daily Call Reports',
      ),
      body: FutureBuilder(
          future: dcrProvider.fetchReports(),
          builder: (context, snapshot) {
            final reports = dcrProvider.getAllReports();
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error occurred: ${snapshot.error}'));
            } else {
              return ListView.builder(
                itemCount: reports.length,
                itemBuilder: (ctx, index) {
                  final report = reports[index];
                  return Card(
                    color: Colors.cyan[100],
                    child: ListTile(
                      title: MyTextwidget(
                        text:
                            ' Submitted By: ${report.submittedBy}  \n Area: ${report.area}',
                        fontSize: 16,
                      ),
                      subtitle:
                          Text('Date: ${DateFormat.yMd().format(report.date)}'),
                      onTap: () {
                        _navigateToReportDetails(
                            context, report.doctorsVisited);
                      },
                    ),
                  );
                },
              );
            }
          }),
    );
  }

  void _navigateToReportDetails(
      BuildContext context, List<DoctorVisitModel> doctorsVisited) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog.fullscreen(
          backgroundColor: Colors.yellow[100],
          child: SizedBox(
            width: 400, // Set the width to an appropriate value
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: doctorsVisited.length,
              itemBuilder: (context, index) {
                final doctorVisit = doctorsVisited[index];
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyTextwidget(
                        text: '${doctorVisit.name}',
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                      MyTextwidget(
                        text: 'Remarks: ${doctorVisit.doctorRemarks}',
                        fontSize: 14,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      MyTextwidget(
                        text: 'Samples Provided:',
                        fontSize: 14,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics:
                            NeverScrollableScrollPhysics(), // Disable inner list's scrolling
                        itemCount: doctorVisit.selectedProducts?.length,
                        itemBuilder: (ctx, index) {
                          final product = doctorVisit.selectedProducts?[index];
                          return ListTile(
                            // tileColor: Colors.blue[100],
                            title: Text(
                                product?.productName ?? 'No Samples Provided'),
                            subtitle: Text('Quantity: ${product?.quantity}'),
                          );
                        },
                      ),
                      // Add a separator between each doctor's information
                      const Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<pw.Document> _generatePDFForAllReports(
      List<DailyCallReportModel> allReports) async {
    final fontData =
        await rootBundle.load('assets/Poppins/Poppins-Regular.ttf');
    final pw.Font ttfFont = pw.Font.ttf(fontData);

    final pw.ThemeData theme = pw.ThemeData.withFont(base: ttfFont);
    final pdf = pw.Document(theme: theme);

    // Create a single page for all doctors
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(8.0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                for (final report in allReports)
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(' '),
                      pw.Text(
                        'Date: ${report.date}',
                        style: const pw.TextStyle(fontSize: 18),
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          for (final doctorVisit in report.doctorsVisited)
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Doctor Name: ${doctorVisit.name}',
                                  style: pw.TextStyle(
                                      fontSize: 16,
                                      fontWeight: pw.FontWeight.bold),
                                ),
                                pw.Text(
                                  'Remarks: ${doctorVisit.doctorRemarks ?? 'No remarks'}',
                                  style: const pw.TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                pw.Text(
                                  'Samples Provided:',
                                  style: const pw.TextStyle(fontSize: 14),
                                ),
                                for (final product
                                    in doctorVisit.selectedProducts ?? [])
                                  pw.Row(
                                    // mainAxisAlignment:
                                    //     pw.MainAxisAlignment.spaceAround,
                                    children: [
                                      pw.Text(
                                        product.productName ??
                                            'No Samples Provided',
                                        style: const pw.TextStyle(fontSize: 12),
                                      ),
                                      pw.SizedBox(
                                        width: 5.0,
                                      ),
                                      pw.Text(
                                        'Quantity: ${product.quantity ?? 'No Samples given'}',
                                        style: const pw.TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                // Add spacing between each doctor's details
                                pw.SizedBox(height: 10),
                                // Add a divider between each doctor's details
                                pw.Divider(),
                              ],
                            ),
                        ],
                      ),
                      // Add a divider between each report
                      pw.Divider(),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }
}
