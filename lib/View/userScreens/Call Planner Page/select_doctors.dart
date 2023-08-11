import 'package:flutter/material.dart';


class SelectDoctorsDialog extends StatelessWidget {
  const SelectDoctorsDialog({
    super.key,
    required this.allDoctors,
    required List<String> selectedDoctors,
  }) : _selectedDoctors = selectedDoctors;

  final Set<String?> allDoctors;
  final List<String> _selectedDoctors;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Doctors'),
      content: StatefulBuilder(
        builder: (context, setState) {
          return SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: allDoctors
                  .map((doctor) => CheckboxListTile(
                        title: Text(doctor!),
                        value: _selectedDoctors
                            .contains(doctor),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedDoctors
                                  .add(doctor);
                            } else {
                              _selectedDoctors
                                  .remove(doctor);
                            }
                          });
                        },
                      ))
                  .toList(),
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, _selectedDoctors);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
