import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';

class WeeklyCallPlanner extends StatefulWidget {
  @override
  _WeeklyCallPlannerState createState() => _WeeklyCallPlannerState();
}

class _WeeklyCallPlannerState extends State<WeeklyCallPlanner> {
  final _formKey = GlobalKey<FormState>();
  late String? _name;
  late String? _phoneNumber;
  late String? _email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(appBartxt: 'Weekly Call Planner'),
      body: Padding(
        padding: EdgeInsets.all(17.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your name:',
                style: TextStyle(fontSize: 16),
              ),
              TextFormField(
                decoration: InputDecoration(),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value;
                },
              ),
              SizedBox(height: 16.0),
              Text(
                'Enter your phone number:',
                style: TextStyle(fontSize: 16),
              ),
              TextFormField(
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _phoneNumber = value;
                },
              ),
              SizedBox(height: 16.0),
              Text(
                'Enter your email:',
                style: TextStyle(fontSize: 16),
              ),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value;
                },
              ),
              SizedBox(height: 30.0),
              Align(
                alignment: Alignment.bottomCenter,
                child: MyButton(
                  color: Colors.blue,
                  text: 'Save Plan',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                    
                    }
                  },
                ),
              )
            ], 
          ),
        ),
      ),
    );
  }
}
