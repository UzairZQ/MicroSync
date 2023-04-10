import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:flutter/src/rendering/box.dart';

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
List<String> day = <String>[
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '10',
  '11',
  '12',
  '13',
  '14',
  '15',
  '16',
  '17',
  '18',
  '19',
  '20',
  '21',
  '22',
  '23',
  '24',
  '25',
  '26',
  '28',
  '29',
  '30',
  '31'
];

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
  String dayValue = day.first;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(appBartxt: 'Dashboard'),
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
                    dropdownColor: Colors.white,
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  DropdownButton<String>(
                    items: day.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        dayValue = value!;
                      });
                    },
                    elevation: 10,
                    icon: const Icon(Icons.arrow_drop_down),
                    value: dayValue,
                    borderRadius: BorderRadius.circular(10.0),
                    dropdownColor: Colors.white,
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
                    dropdownColor: Colors.white,
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
              // Container(
              //     // padding: EdgeInsets.fromLTRB(50, 20, 180, 200),
              //     padding: EdgeInsets.all(10.0),
              //     child: Row(
              //       children: [
              //         PieChart(
              //           dataMap: dataMap,
              //           chartType: ChartType.ring,
              //           centerText: '1.55 doctor',
              //           chartValuesOptions: ChartValuesOptions(
              //             showChartValues: false,
              //             showChartValueBackground: false,
              //           ),
              //           legendOptions: LegendOptions(showLegends: false),
              //         ),
              //         Container(
              //           child: PieChart(
              //             dataMap: dataMap,
              //             chartType: ChartType.ring,
              //             centerText: '0.55 chemists',
              //             chartValuesOptions: ChartValuesOptions(
              //               showChartValues: false,
              //               showChartValueBackground: false,
              //             ),
              //             legendOptions: LegendOptions(showLegends: false),
              //           ),
              //         )
              //       ],
              //     )),
              SizedBox(
                height: 0.0,
              ),
              const Text(
                'DCR status',
                style: TextStyle(fontSize: 17.5, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
