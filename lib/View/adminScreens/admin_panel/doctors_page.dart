import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/models/doctor_model.dart';
import 'package:micro_pharma/viewModel/area_provider.dart';
import 'package:micro_pharma/viewModel/doctor_provider.dart';
import 'package:provider/provider.dart';
import '../../../models/area_model.dart';

class DoctorsPage extends StatefulWidget {
  const DoctorsPage({super.key});

  @override
  State<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  TextEditingController doctorNameController = TextEditingController();

  TextEditingController areaController = TextEditingController();

  TextEditingController addressController = TextEditingController();

  TextEditingController specializationController = TextEditingController();

  AreaModel? selectedArea;

  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AreaProvider>().fetchAreas();
      context.read<DoctorDataProvider>().fetchDoctors();
    });
  }

  Future<void> _refreshDoctors(BuildContext context) async {
    // Fetch the products list again
    await Provider.of<DoctorDataProvider>(context, listen: false)
        .fetchDoctors();
  }

  @override
  Widget build(BuildContext context) {
    List<AreaModel> areas = Provider.of<AreaProvider>(context).getAreas;
    List<DoctorModel> doctors =
        Provider.of<DoctorDataProvider>(context).getDoctorList;
    final filteredDoctors = selectedArea != null
        ? doctors
            .where((doctor) =>
                doctor.area == selectedArea!.areaName &&
                (doctor.name ?? '')
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
            .toList()
        : doctors
            .where((doctor) => (doctor.name ?? '')
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
            .toList();
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add_outlined),
          onPressed: () {
            addDoctorBottomSheet(context, areas);
          },
          label: const MyTextwidget(
            text: 'Add Doctor',
            fontSize: 16,
          )),
      appBar: const MyAppBar(appBartxt: 'Doctors'),
      body: RefreshIndicator(
        onRefresh: () => _refreshDoctors(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(10)),
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search doctors',
                ),
                onChanged: (value) => setState(() => searchQuery = value),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<AreaModel>(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.location_on_outlined),
                  hintText: 'Filter by area',
                ),
                initialValue: selectedArea,
                items: areas.map((area) {
                  return DropdownMenuItem(
                    value: area,
                    child: MyTextwidget(text: area.areaName),
                  );
                }).toList(),
                onChanged: (AreaModel? area) {
                  setState(() {
                    selectedArea = area;
                  });
                },
              ),
              if (selectedArea != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => setState(() => selectedArea = null),
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear filter'),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    // Display doctors in card
                    return Card(
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.fromLTRB(16, 10, 8, 10),
                        title: MyTextwidget(
                          text: filteredDoctors[index].name ?? 'Unnamed doctor',
                          fontSize: 18,
                        ),
                        subtitle: Text(
                          '${filteredDoctors[index].speciality ?? 'No specialty'}\n${filteredDoctors[index].area ?? 'No area'} • ${filteredDoctors[index].address ?? 'No address'}',
                        ),
                        trailing: Wrap(
                          children: [
                            IconButton(
                              tooltip: 'Edit doctor',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => editDoctorBottomSheet(
                                  context, areas, filteredDoctors[index]),
                            ),
                            IconButton(
                              tooltip: 'Delete doctor',
                              color: Colors.red,
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                showCustomDialog(
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          final navigator =
                                              Navigator.of(context);
                                          await context
                                              .read<DoctorDataProvider>()
                                              .deleteDoctor(
                                                filteredDoctors[index].name ??
                                                    '',
                                                filteredDoctors[index].area ??
                                                    '',
                                              );
                                          navigator.pop();
                                        },
                                        child: const MyTextwidget(
                                          text: 'Delete',
                                        ),
                                      ),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            return;
                                          },
                                          child: const MyTextwidget(
                                              text: 'Cancel'))
                                    ],
                                    context: context,
                                    title: 'Delete this doctor?',
                                    content:
                                        'Are you sure you want to permanently delete this doctor from the database?');
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: filteredDoctors.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> addDoctorBottomSheet(
      BuildContext context, List<AreaModel> areas) {
    return showModalBottomSheet(
      constraints: BoxConstraints.loose(const Size.fromHeight(700)),
      context: context,
      isScrollControlled: true,
      builder: ((context) {
        return GestureDetector(
          onTap: () {
            // dismiss the keyboard when the user taps outside the text fields
            FocusScope.of(context).unfocus();
          },
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  ListTile(
                    title: const Text(
                      'Add New Doctor',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: 'Poppins'),
                    ),
                    subtitle: Column(
                      children: [
                        TextFormField(
                          controller: doctorNameController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please Enter Doctor Name';
                            }
                            return null;
                          },
                          onSaved: (name) {
                            doctorNameController.text = name!;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Enter Doctor Name',
                            contentPadding: EdgeInsets.only(top: 3),
                          ),
                        ),
                        DropdownButtonFormField<AreaModel>(
                          initialValue: selectedArea,
                          validator: (value) {
                            if (value == null) {
                              return 'Please Select Area';
                            }
                            return null;
                          },
                          onChanged: (AreaModel? area) {
                            setState(() {
                              selectedArea = area;
                            });
                          },
                          onSaved: (area) {
                            areaController.text = area!.areaName;
                          },
                          items: areas.map((area) {
                            return DropdownMenuItem(
                              value: area,
                              child: Text(area.areaName),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            hintText: 'Select Area',
                            contentPadding: EdgeInsets.only(top: 3),
                            border: UnderlineInputBorder(),
                          ),
                        ),
                        TextFormField(
                          controller: addressController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please Enter Doctor\'s Address';
                            }
                            return null;
                          },
                          onSaved: (address) {
                            addressController.text = address!;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Enter Address',
                            contentPadding: EdgeInsets.only(top: 3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  ListTile(
                    title: const Text(
                      'Specialization',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    subtitle: Column(
                      children: [
                        TextFormField(
                          controller: specializationController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please Enter Specilization';
                            }
                            return null;
                          },
                          onSaved: (category) {
                            specializationController.text = category!;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Add Speicialization',
                            contentPadding: EdgeInsets.only(top: 3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  MyButton(
                    color: Colors.blue,
                    text: 'Save',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        Provider.of<DoctorDataProvider>(context, listen: false)
                            .addDoctor(
                          doctorNameController.text,
                          areaController.text,
                          addressController.text,
                          specializationController.text,
                        );

                        doctorNameController.clear();
                        areaController.clear();
                        addressController.clear();
                        specializationController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<dynamic> editDoctorBottomSheet(
      BuildContext context, List<AreaModel> areas, DoctorModel doctor) {
    final editNameController = TextEditingController(text: doctor.name ?? '');
    final editAddressController =
        TextEditingController(text: doctor.address ?? '');
    final editSpecializationController =
        TextEditingController(text: doctor.speciality ?? '');
    AreaModel? editSelectedArea = areas
        .where((area) => area.areaName == doctor.area)
        .cast<AreaModel?>()
        .firstOrNull;

    return showModalBottomSheet(
      constraints: BoxConstraints.loose(const Size.fromHeight(700)),
      context: context,
      isScrollControlled: true,
      builder: ((context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                18,
                18,
                18,
                MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Edit Doctor',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: editNameController,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter doctor name'
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Doctor name',
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<AreaModel>(
                      initialValue: editSelectedArea,
                      validator: (value) =>
                          value == null ? 'Please select area' : null,
                      onChanged: (AreaModel? area) {
                        setSheetState(() => editSelectedArea = area);
                      },
                      items: areas.map((area) {
                        return DropdownMenuItem(
                          value: area,
                          child: Text(area.areaName),
                        );
                      }).toList(),
                      decoration: const InputDecoration(labelText: 'Area'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: editAddressController,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter address'
                          : null,
                      decoration: const InputDecoration(labelText: 'Address'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: editSpecializationController,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter specialization'
                          : null,
                      decoration:
                          const InputDecoration(labelText: 'Specialization'),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save Doctor'),
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          final saved = await context
                              .read<DoctorDataProvider>()
                              .editDoctor(
                                doctor.name ?? '',
                                doctor.area ?? '',
                                DoctorModel(
                                  name: editNameController.text.trim(),
                                  area: editSelectedArea!.areaName,
                                  address: editAddressController.text.trim(),
                                  speciality:
                                      editSpecializationController.text.trim(),
                                ),
                              );
                          navigator.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(saved
                                  ? 'Doctor updated'
                                  : 'Could not update doctor'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    ).whenComplete(() {
      editNameController.dispose();
      editAddressController.dispose();
      editSpecializationController.dispose();
    });
  }
}
