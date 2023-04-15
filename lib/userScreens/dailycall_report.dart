import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';

class DailyCallReports extends StatefulWidget {
  @override
  _DailyCallReportsState createState() => _DailyCallReportsState();
}

class _DailyCallReportsState extends State<DailyCallReports> {
  final _formKey = GlobalKey<FormState>();
  String? _doctorName;
  String? _purpose;
  String? _remarks;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(appBartxt: 'Daily Call Report'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Doctor Name:',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter doctor name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _doctorName = value;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Purpose of visit:',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter purpose of visit';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _purpose = value;
                    },
                  ),
                 const  SizedBox(height: 16.0),
                  const Text(
                    'Remarks:',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextFormField(
                    onSaved: (value) {
                      _remarks = value;
                    },
                  ),
                  const SizedBox(height: 30.0),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: MyButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          // Send data to admin here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Report submitted successfully')),
                          );
                        }
                      },
                      text: 'Submit Report',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
