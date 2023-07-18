import 'package:flutter/material.dart';
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
    Provider.of<AreaProvider>(context, listen: false).fetchAreas();
    Provider.of<DoctorDataProvider>(context, listen: false).fetchDoctors();
    super.initState();
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
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add_outlined),
          onPressed: () {
            addDoctorBottomSheet(context, areas);
          },
          label: MyTextwidget(
            text: 'Add Doctor',
            fontSize: 16,
          )),
      appBar: const MyAppBar(appBartxt: 'Docotors'),
      body: RefreshIndicator(
        onRefresh: () => _refreshDoctors(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(10)),
              Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.blueGrey[900],
                          ),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      )),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Expanded(
                    child: DropdownButton<AreaModel>(
                        hint: const Text('Select Area'),
                        value: selectedArea,
                        items: areas.map((area) {
                          return DropdownMenuItem(
                            value: area,
                            child: Text(area.areaName),
                          );
                        }).toList(),
                        onChanged: (AreaModel? area) {
                          setState(() {
                            selectedArea = area;
                          });
                        }),
                  ),
                ],
              ),
              Flexible(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    // Filter doctors based on selected area and search query
                    final filteredDoctors = selectedArea != null
                        ? doctors
                            .where((doctor) =>
                                doctor.area == selectedArea!.areaName &&
                                doctor.name!
                                    .toLowerCase()
                                    .contains(searchQuery.toLowerCase()))
                            .toList()
                        : doctors
                            .where((doctor) => doctor.name!
                                .toLowerCase()
                                .contains(searchQuery.toLowerCase()))
                            .toList();

                    // Display doctors in card
                    return Card(
                      color: Colors.blue[100],
                      child: ListTile(
                        title: MyTextwidget(
                          text: filteredDoctors[index].name!,
                          fontSize: 18,
                        ),
                        subtitle: Text(filteredDoctors[index].speciality!),
                        trailing: Text(filteredDoctors[index].address!),
                      ),
                    );
                  },
                  itemCount: selectedArea != null
                      ? doctors
                          .where(
                              (doctor) => doctor.area == selectedArea!.areaName)
                          .toList()
                          .length
                      : doctors.length,
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
      context: context,
      isScrollControlled: true,
      builder: ((context) {
        return GestureDetector(
          onTap: () {
            // dismiss the keyboard when the user taps outside the text fields
            FocusScope.of(context).unfocus();
          },
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 1.2,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    ListTile(
                      title: const Text(
                        'Name & Area',
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
                            value: selectedArea,
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
                              doctorNameController.text = address!;
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
                                return 'Please Enter Phone Number';
                              }
                              return null;
                            },
                            onSaved: (category) {
                              doctorNameController.text = category!;
                            },
                            decoration: const InputDecoration(
                              hintText: 'Select Category',
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
                          DoctorDataProvider.addDoctor(
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
          ),
        );
      }),
    );
  }
}
