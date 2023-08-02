import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:micro_pharma/components/constants.dart';

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
      appBar: const MyAppBar(appBartxt: 'Dashboard'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(
                height: 20.0,
              ),
              MyTextwidget(
                fontSize: 18,
                text: 'Visit/Missed Details',
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 30.0, right: 15.0),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 10.0),
                      height: 72.0,
                      width: 144.0,
                      decoration: BoxDecoration(
                        color: const Color(0xff89B7FD),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Center(
                          child: MyTextwidget(
                        fontSize: 13.5,
                        text: '14 Visited Doctors',
                        fontWeight: FontWeight.bold,
                      )),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 30.0, right: 15.0),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 10.0),
                      height: 72.0,
                      width: 144.0,
                      decoration: BoxDecoration(
                        color: const Color(0xffFF9292),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Center(
                        child: MyTextwidget(
                          text: '20 missed doctors',
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Text(
                'Call Average',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins'),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Container(
                  // padding: EdgeInsets.fromLTRB(50, 20, 180, 200),
                  padding: const EdgeInsets.all(8.0),
                  child: PieChart(
                    dataMap: dataMap,
                    chartRadius: MediaQuery.of(context).size.width / 2.2,
                    chartType: ChartType.ring,
                    centerText: '1.55 doctor',
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValues: false,
                      showChartValueBackground: false,
                    ),
                    legendOptions: const LegendOptions(showLegends: false),
                  )),
              const SizedBox(
                height: 25.0,
              ),
              const Text(
                'Product order booking',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Center(
                child: Container(
                    height: 90,
                    margin: const EdgeInsets.all(15),
                    width: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xffD9D9D9),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Total POB',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '0.0984',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        // Additional widgets in the row, if needed
                      ],
                    )),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'DCR status',
                style: TextStyle(fontSize: 17.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20.0,
              ),
              PieChart(
                dataMap: dataMap,
                chartRadius: MediaQuery.of(context).size.width / 3.2,
                chartType: ChartType.ring,
                centerText: '1.55 doctor',
                chartValuesOptions: const ChartValuesOptions(
                  showChartValues: false,
                  showChartValueBackground: false,
                ),
                legendOptions: const LegendOptions(showLegends: false),
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Text(
                'Tour Program Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     Container(
              //         padding: const EdgeInsets.all(20),
              //         margin: const EdgeInsets.all(15),
              //         height: 90,
              //         width: 122.0,
              //         decoration: BoxDecoration(
              //           color: const Color(0xFFD9D9D9),
              //           borderRadius: BorderRadius.circular(15.0),
              //         ),
              //         child: const Row(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: [
              //                 Icon(
              //                   Icons.check_circle_outline,
              //                   size: 25,
              //                   color: Color(0xFF333333),
              //                 ),
              //                 Text(
              //                   'Submitted',
              //                   style: TextStyle(
              //                       fontWeight: FontWeight.bold,
              //                       fontSize: 17.5),
              //                 ),
              //               ],
              //             ),
              //             // Additional widgets in the row, if needed
              //           ],
              //         )),
              //     const SizedBox(width: 40),
              //     Container(
              //       margin: const EdgeInsets.all(15),
              //       height: 90,
              //       width: 122.0,
              //       decoration: BoxDecoration(
              //         color: const Color(0xFFD9D9D9),
              //         borderRadius: BorderRadius.circular(15.0),
              //       ),
              //       child: const Row(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               Icon(Icons.check_circle_outline),
              //               Text(
              //                 'Approved',
              //                 style: TextStyle(
              //                     fontWeight: FontWeight.bold, fontSize: 17.5),
              //               ),
              //             ],
              //           ),
              //           // Additional widgets in the row, if needed
              //         ],
              //       ),
              //     ),
              //   ],
              // )
            ],
          ),
        ),
      ),
    );
  }
}
