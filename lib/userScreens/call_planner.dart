// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// import 'package:micro_pharma/components/constants.dart';
// import 'package:micro_pharma/services/database_service.dart';

// class CallPlanner extends StatefulWidget {
//   static const String id = 'call_planner';

//   const CallPlanner({Key? key}) : super(key: key);

//   @override
//   State<CallPlanner> createState() => _CallPlannerState();
// }

// class _CallPlannerState extends State<CallPlanner> {
//   final db = DataBaseService();

//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController _areaController = TextEditingController();
//   final TextEditingController _doctorController = TextEditingController();

//   DateTime _selectedDate = DateTime.now();

//   List<String> _areaList = ['Area 1', 'Area 2', 'Area 3', 'Area 4'];
//   String? _selectedArea;

//   bool _isDayPlanEnabled = false;

//   List<String> _selectedDoctors = [];

//   void _onDateSelected(DateTime date) {
//     setState(() {
//       _selectedDate = date;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           'Call Planner',
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TableCalendar(
//               firstDay: DateTime.utc(2010, 1, 1),
//               lastDay: DateTime.utc(2030, 12, 31),
//               focusedDay: _selectedDate,
//               calendarFormat: CalendarFormat.month,
//               selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
//               onDaySelected: _onDateSelected,
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     decoration: const InputDecoration(
//                       hintText: 'Select Area',
//                       border: OutlineInputBorder(),
//                     ),
//                     value: _selectedArea,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedArea = value;
//                       });
//                     },
//                     items: _areaList.map((area) {
//                       return DropdownMenuItem(
//                         value: area,
//                         child: Text(area),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Checkbox(
//                   value: _isDayPlanEnabled,
//                   onChanged: (value) {
//                     setState(() {
//                       _isDayPlanEnabled = value ?? false;
//                     });
//                   },
//                 ),
//                 const SizedBox(width: 8),
//                 const Text('Add Day Plan'),
//               ],
//             ),
//             if (_isDayPlanEnabled)
//               Padding(
//                 padding: const EdgeInsets.only(top: 16.0),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       TextFormField(
//                         controller: _doctorController,
//                         decoration:const InputDecoration(
//                           hintText: 'Select Doctors',
//                           border: OutlineInputBorder(),
//                         ),
//                         readOnly: true,
//                         onTap: () {
//                           // Show doctors selection dialog
//                           showDialog(
//                             context: context,
//                             builder: (_) {
//                               return AlertDialog(
//                                 title: const Text('Select Doctors'),
//                                 content: SizedBox(
//                                   width: double.maxFinite,
//                                   child: FutureBuilder(
//                                     future: db.get
//                                     DoctorsByArea(_selectedArea ?? ''),
//                                     builder: (context, snapshot) {
//                                       if (snapshot.hasData) {
//                                         return ListView.builder(
//                                           shrinkWrap: true,
//                                           itemCount: snapshot.data!.length,
//                                           itemBuilder: (context, index) {
//                                             return CheckboxListTile(
//                                               title: Text(
//                                                 snapshot.data![index]['name'],
//                                               ),
//                                               value: _selectedDoctors.contains(
//                                                 snapshot.data![index]['id'],
//                                               ),
//                                               onChanged: (value) {
//                                                 setState(() {
//                                                   if (value == true) {
//                                                     _selectedDoctors.add(
//                                                       snapshot.data![index]['id'],
//                                                     );
//                                                   } else {
//                                                     _selectedDoctors.remove(
//                                                       snapshot.data![index]['id'],
//                                                     );
//                                                   }
//                                                 });
//                                               },
//                                             );
//                                           },
//                                         );
//                                       } else {
//                                         return const CircularProgressIndicator();
//                                       }
//                                     },
//                                   ),
//                                 ),
//                               );
//                             },
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: () async {
//                           if (_selectedArea != null && _selectedDoctors.isNotEmpty) {
//                             await db.addCallPlan(
//                               _selectedArea!,
//                               _selectedDoctors,
//                               DateFormat('yyyy-MM-dd').format(_selectedDate),
//                             );
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Call plan added successfully.'),
//                               ),
//                             );
//                             setState(() {
//                               _selectedDoctors.clear();
//                               _formKey.currentState?.reset();
//                             });
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Please select area and doctors.'),
//                               ),
//                             );
//                           }
//                         },
//                         child: const Text('Submit Call Plan'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class DoctorsByArea extends StatelessWidget {
//   final String area;

//   const DoctorsByArea(this.area);

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: DataBaseService().getDoctorsByArea(area),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           return ListView.builder(
//             shrinkWrap: true,
//             itemCount: snapshot.data!.length,
//             itemBuilder: (context, index) {
//               return CheckboxListTile(
//                 title: Text(
//                   snapshot.data![index]['name'],
//                 ),
//                 value: false,
//                 onChanged: (value) {},
//               );
//             },
//           );
//         } else {
//           return const CircularProgressIndicator();
//         }
//       },
//     );
//   }
// }
