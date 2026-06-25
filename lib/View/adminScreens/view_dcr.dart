import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/models/dcr_model.dart';
import 'package:micro_pharma/models/doctor_visit_model.dart';
import 'package:micro_pharma/viewModel/daily_call_report_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:pdf/widgets.dart' as pw;

class ViewDCRScreen extends StatelessWidget {
  static const String id = 'view_dcr';

  const ViewDCRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dcrProvider =
        Provider.of<DailyCallReportProvider>(context, listen: false);

    return Scaffold(
      appBar: const MyAppBar(appBartxt: 'Daily Call Reports'),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.picture_as_pdf_outlined),
        label: const Text('Export'),
        onPressed: () async {
          final reports = dcrProvider.getAllReports();
          final pdf = await _generatePDFForAllReports(reports);
          final directory = await getExternalStorageDirectory();
          if (directory == null) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Storage is not available.')),
              );
            }
            return;
          }
          final filePath = '${directory.path}/all_reports.pdf';
          final file = File(filePath);
          await file.writeAsBytes(await pdf.save());
          if (await file.exists()) {
            OpenFile.open(filePath);
          }
        },
      ),
      body: FutureBuilder(
        future: dcrProvider.fetchReports(),
        builder: (context, snapshot) {
          final reports = dcrProvider.getAllReports()
            ..sort((a, b) => b.date.compareTo(a.date));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error occurred: ${snapshot.error}'));
          }
          if (reports.isEmpty) {
            return const _EmptyAdminState(
              icon: Icons.assignment_turned_in_outlined,
              title: 'No daily reports yet',
              message: 'Submitted field reports will appear here.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final report = reports[index];
              return _DcrReportCard(
                report: report,
                onTap: () => _showReportDetails(context, report),
              );
            },
          );
        },
      ),
    );
  }

  void _showReportDetails(BuildContext context, DailyCallReportModel report) {
    final visitedCount =
        report.doctorsVisited.where((visit) => visit.visited == true).length;
    final sampleUnits = report.doctorsVisited.fold<int>(
      0,
      (sum, visit) =>
          sum +
          (visit.selectedProducts ?? [])
              .fold<int>(0, (inner, product) => inner + product.quantity),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.82,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                children: [
                  Center(
                    child: Container(
                      height: 4,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant
                            .withOpacity(0.9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: kappbarColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.assignment_turned_in_outlined,
                          color: kappbarColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.submittedBy,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${report.area} • ${DateFormat('EEE, d MMM yyyy').format(report.date)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _SummaryChip(
                        icon: Icons.medical_services_outlined,
                        label: '${report.doctorsVisited.length} doctors',
                      ),
                      _SummaryChip(
                        icon: Icons.check_circle_outline,
                        label: '$visitedCount visited',
                      ),
                      _SummaryChip(
                        icon: Icons.inventory_2_outlined,
                        label: '$sampleUnits sample units',
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Doctor Visits',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  ...report.doctorsVisited.map(_DoctorVisitPanel.new),
                ],
              ),
            );
          },
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

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Text(
              'Daily Call Reports',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            for (final report in allReports)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${report.submittedBy} • ${report.area} • ${DateFormat('yyyy-MM-dd').format(report.date)}',
                    style: pw.TextStyle(
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  for (final doctorVisit in report.doctorsVisited)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Doctor: ${doctorVisit.name ?? 'Unknown'}'),
                        pw.Text(
                          'Remarks: ${doctorVisit.doctorRemarks ?? 'No remarks'}',
                        ),
                        for (final product
                            in doctorVisit.selectedProducts ?? [])
                          pw.Text(
                            'Sample: ${product.productName} (${product.quantity})',
                          ),
                        pw.Divider(),
                      ],
                    ),
                  pw.SizedBox(height: 12),
                ],
              ),
          ];
        },
      ),
    );

    return pdf;
  }
}

class _DcrReportCard extends StatelessWidget {
  const _DcrReportCard({required this.report, required this.onTap});

  final DailyCallReportModel report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final doctorCount = report.doctorsVisited.length;
    final visitedCount =
        report.doctorsVisited.where((visit) => visit.visited == true).length;

    return Card(
      elevation: 2,
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: kappbarColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.assignment_outlined, color: kappbarColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.submittedBy,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${report.area} • ${DateFormat('EEE, d MMM').format(report.date)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _SummaryChip(
                          icon: Icons.medical_services_outlined,
                          label: '$doctorCount doctors',
                        ),
                        _SummaryChip(
                          icon: Icons.check_circle_outline,
                          label: '$visitedCount visited',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorVisitPanel extends StatelessWidget {
  const _DoctorVisitPanel(this.visit);

  final DoctorVisitModel visit;

  @override
  Widget build(BuildContext context) {
    final products = visit.selectedProducts ?? [];
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withOpacity(0.42),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  visit.visited == true
                      ? Icons.check_circle_outline
                      : Icons.radio_button_unchecked,
                  color: visit.visited == true ? kappbarColor : Colors.grey,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    visit.name ?? 'Unknown doctor',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
            if ((visit.doctorRemarks ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_outlined, size: 19),
                  const SizedBox(width: 8),
                  Expanded(child: Text(visit.doctorRemarks!)),
                ],
              ),
            ],
            const SizedBox(height: 10),
            if (products.isEmpty)
              const Text('No samples recorded.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: products
                    .map(
                      (product) => Chip(
                        avatar:
                            const Icon(Icons.inventory_2_outlined, size: 18),
                        label: Text(
                            '${product.productName} • ${product.quantity}'),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: kappbarColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: kappbarColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: kappbarColor, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _EmptyAdminState extends StatelessWidget {
  const _EmptyAdminState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: kappbarColor),
            const SizedBox(height: 14),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
