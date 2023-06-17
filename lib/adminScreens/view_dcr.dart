import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/doctor_visit_model.dart';
import '../providers/daily_call_report_provider.dart';

class ViewDCRScreen extends StatelessWidget {
  static const String id = 'view_dcr';

  const ViewDCRScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final dcrProvider =
        Provider.of<DailyCallReportProvider>(context, listen: false);

    return Scaffold(
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
        return Dialog(
          backgroundColor: Colors.green[100],
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var doctorVisit in doctorsVisited)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyTextwidget(
                          text: 'Doctor Name: ${doctorVisit.name}',
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                        ),
                        MyTextwidget(
                          text: 'Remarks: ${doctorVisit.doctorRemarks}',
                          fontSize: 16,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        MyTextwidget(
                          text: 'Samples Provided:',
                          fontSize: 16,
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: doctorVisit.selectedProducts?.length,
                          itemBuilder: (ctx, index) {
                            final product =
                                doctorVisit.selectedProducts?[index];
                            return Card(
                              color: Colors.amber[100],
                              child: ListTile(
                                title: Text(product?.productName ??
                                    'No Samples Provided'),
                                subtitle:
                                    Text('Quantity: ${product?.quantity}'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
    // Implement navigation to report details screen
    // Pass the report object to the details screen
  }
}
