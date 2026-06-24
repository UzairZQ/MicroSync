import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/models/area_model.dart';
import 'package:micro_pharma/models/day_plan_model.dart';
import 'package:micro_pharma/models/doctor_model.dart';
import 'package:micro_pharma/viewModel/area_provider.dart';
import 'package:micro_pharma/viewModel/doctor_provider.dart';
import 'package:micro_pharma/viewModel/user_data_provider.dart';
import 'package:micro_pharma/View/userScreens/Call%20Planner%20Page/select_doctors.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../models/user_model.dart';
import '../../../viewModel/day_plans_provider.dart';

class CallPlanner extends StatefulWidget {
  static const String id = 'call_planner';

  const CallPlanner({super.key});

  @override
  State<CallPlanner> createState() => _CallPlannerState();
}

class _CallPlannerState extends State<CallPlanner> {
  DateTime _selectedDate = DateTime.now();

  AreaModel? _selectedArea;

  List<String> _selectedDoctors = [];

  bool _isDayPlanEnabled = false;
  String _selectedShift = 'Morning';

  final TextEditingController _doctorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlannerData();
    });
  }

  Future<void> _loadPlannerData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (!mounted || user == null) {
      return;
    }

    await Future.wait([
      context.read<AreaProvider>().fetchAreas(),
      context.read<DoctorDataProvider>().fetchDoctors(),
      context.read<UserDataProvider>().fetchUserData(user.uid),
    ]);
  }

  @override
  void dispose() {
    _doctorController.dispose();
    super.dispose();
  }

  void _onDateSelected(DateTime date, DateTime day) {
    setState(() {
      // Extract only the date part of the selected date
      _selectedDate = date;
    });
  }

  void _clearDayPlanSelection() {
    setState(() {
      _selectedArea = null;
      _selectedDoctors = [];
      _doctorController.clear();
      _isDayPlanEnabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<AreaModel> areaList = Provider.of<AreaProvider>(context).getAreas;
    List<DoctorModel> doctors =
        Provider.of<DoctorDataProvider>(context).getDoctorList;
    UserModel? userData =
        Provider.of<UserDataProvider>(context, listen: false).getUserData;
    List<AreaModel>? assignedAreas = userData.assignedAreas;

    return Scaffold(
      appBar: const MyAppBar(
        appBartxt: 'Call Planner',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2010, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _selectedDate,
                calendarFormat: CalendarFormat.week,
                selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                onDaySelected: _onDateSelected,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: kappbarColor,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: kappbarColor.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String?>(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an area';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Area',
                      prefixIcon: const Icon(Icons.place_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    initialValue: _selectedArea?.areaName,
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      final availableAreas = assignedAreas?.isNotEmpty == true
                          ? assignedAreas!
                          : areaList;
                      AreaModel? selectedArea;
                      for (final area in availableAreas) {
                        if (area.areaName == value) {
                          selectedArea = area;
                          break;
                        }
                      }
                      if (selectedArea == null) {
                        return;
                      }
                      setState(() {
                        _selectedArea = selectedArea;
                      });
                    },
                    items: (assignedAreas?.isNotEmpty == true
                            ? assignedAreas
                            : areaList)!
                        .map((area) => DropdownMenuItem(
                              value: area.areaName,
                              child: Text(area.areaName),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedShift,
                    decoration: InputDecoration(
                      labelText: 'Select Shift',
                      prefixIcon: const Icon(Icons.access_time_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: <String>['Morning', 'Evening'].map((String shift) {
                      return DropdownMenuItem<String>(
                        value: shift,
                        child: Text(shift),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _selectedShift = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: _isDayPlanEnabled
                    ? kappbarColor.withOpacity(0.05)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isDayPlanEnabled
                      ? kappbarColor.withOpacity(0.3)
                      : Colors.transparent,
                ),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Add Day Plan Details',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Assign doctors to this call plan.'),
                value: _isDayPlanEnabled,
                activeColor: kappbarColor,
                onChanged: (value) {
                  setState(() {
                    _isDayPlanEnabled = value;
                  });
                },
              ),
            ),
            if (_isDayPlanEnabled) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _doctorController,
                decoration: InputDecoration(
                  labelText: 'Select Doctors',
                  prefixIcon: const Icon(Icons.medical_services_outlined),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                readOnly: true,
                onTap: () async {
                  final filteredDoctors = _selectedArea != null
                      ? doctors
                          .where((doctor) =>
                              doctor.area == _selectedArea!.areaName)
                          .toList()
                      : doctors;
                  final selectedDoctors = await showDialog<List<String>>(
                    context: context,
                    builder: (_) {
                      final allDoctors =
                          filteredDoctors.map((doctor) => doctor.name).toSet();
                      return SelectDoctorsDialog(
                        allDoctors: allDoctors,
                        selectedDoctors: _selectedDoctors,
                      );
                    },
                  );
                  if (selectedDoctors != null) {
                    setState(() {
                      _selectedDoctors = selectedDoctors;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_selectedDoctors.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Doctors (${_selectedDoctors.length})',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedDoctors
                            .map((doc) => Chip(
                                  label: Text(doc),
                                  backgroundColor: Colors.white,
                                  side: BorderSide(color: Colors.grey.shade300),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kappbarColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      final userData =
                          Provider.of<UserDataProvider>(context, listen: false)
                              .getUserData;
                      if (_selectedDoctors.isNotEmpty) {
                        final newDayPlan = DayPlanModel(
                          shift: _selectedShift,
                          userName: userData.displayName!,
                          date: _selectedDate,
                          area: _selectedArea!.areaName,
                          doctors: _selectedDoctors.toList(),
                        );
                        await Provider.of<DayPlanProvider>(context,
                                listen: false)
                            .addDayPlan(newDayPlan);

                        showCustomDialog(
                          context: navigatorKey.currentContext!,
                          title: 'Success',
                          content: 'Day Plan Added Successfully!',
                        );

                        _clearDayPlanSelection();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Please select at least one doctor.')),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Submit Day Plan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
