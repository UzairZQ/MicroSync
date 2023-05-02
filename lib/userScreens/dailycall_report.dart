import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/day_plans_provider.dart';
import '../models/day_plan_model.dart';

class DailyCallReportScreen extends StatefulWidget {
  static const String id = 'dailycallreport';
  @override
  _DailyCallReportScreenState createState() => _DailyCallReportScreenState();
}

class _DailyCallReportScreenState extends State<DailyCallReportScreen> {
  late DayPlanModel _currentDayPlan;

  @override
  void initState() {
    super.initState();
    _currentDayPlan = Provider.of<DayPlanProvider>(context, listen: false)
        .getCurrentDayPlan();
  }

  Future<void> _showDoctorsDialog(BuildContext context) async {
    List<String> doctors = _currentDayPlan.doctors;

    List<bool> doctorSelections =
        List.filled(doctors.length, false, growable: false);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Doctors'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(doctors.length, (index) {
                return CheckboxListTile(
                  title: Text(doctors[index]),
                  value: doctorSelections[index],
                  onChanged: (bool? value) {
                    setState(() {
                      doctorSelections[index] = value ?? false;
                    });
                  },
                );
              }),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Add logic to save selected doctors
                Navigator.of(context).pop();
              },
              child: const Text('OKAY'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Call Report'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Doctors as per Day Plan: ${_currentDayPlan.date}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: null,
              items: _currentDayPlan.doctors
                  .map((doctor) => DropdownMenuItem(
                        value: doctor,
                        child: Text(doctor),
                      ))
                  .toList(),
              onChanged: (_) => _showDoctorsDialog(context),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select Doctor',
                hintText: 'Choose a doctor',
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
