import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:pie_chart/pie_chart.dart';

List<String> month = <String>[
  'January',
  'Febuary',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];
List<String> year = <String>['2022', '2023', '2024', '2025'];

class Dashboard extends StatefulWidget {
  static String id = 'user_dashboard';
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Map<String, double> dataMap = {
    "Flutter": 5,
    "React": 3,
    "Xamarin": 2,
    "Ionic": 2,
  };
  String monthValue = month.first;

  String yearValue = year.first;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(appBartxt: 'Dashboard'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    items: month.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        monthValue = value!;
                      });
                    },
                    elevation: 10,
                    icon: const Icon(Icons.arrow_drop_down),
                    value: monthValue,
                    borderRadius: BorderRadius.circular(10.0),
                    dropdownColor: Colors.white70,
                  ),
                  const SizedBox(width: 5.0),
                  DropdownButton<String>(
                    items: year.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        yearValue = value!;
                      });
                    },
                    elevation: 10,
                    icon: const Icon(Icons.arrow_drop_down),
                    value: yearValue,
                    borderRadius: BorderRadius.circular(10.0),
                    dropdownColor: Colors.white70,
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  const TextButton(
                    onPressed: null,
                    child: Text(
                      'View',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                  ),
                ],
              ),
              myTextwidget(fontSize: 17.5, text: 'Visit/Missed Details'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 30.0, right: 15.0),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 10.0),
                    height: 72.0,
                    width: 144.0,
                    child: Center(
                        child: myTextwidget(
                      fontSize: 17.5,
                      text: '14 Visited Doctors',
                      fontWeight: FontWeight.bold,
                    )),
                    decoration: BoxDecoration(
                      color: Color(0xff89B7FD),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 30.0, right: 15.0),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 10.0),
                    height: 72.0,
                    width: 144.0,
                    child: Center(
                      child: myTextwidget(
                        text: '20 missed doctors',
                        fontSize: 17.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffFF9292),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ],
              ),
              const Text(
                'Call Average',
                style: TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins'),
              ),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: PieChart(
                    dataMap: dataMap,
                    chartType: ChartType.ring,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
