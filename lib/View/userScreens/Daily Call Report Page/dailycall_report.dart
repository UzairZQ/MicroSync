import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/models/day_plan_model.dart';
import 'package:micro_pharma/models/dcr_model.dart';
import 'package:micro_pharma/models/product_model.dart';
import 'package:micro_pharma/models/user_model.dart';
import 'package:micro_pharma/viewModel/daily_call_report_provider.dart';
import 'package:micro_pharma/viewModel/day_plans_provider.dart';
import 'package:micro_pharma/viewModel/product_data_provider.dart';
import 'package:micro_pharma/viewModel/user_data_provider.dart';
import 'package:micro_pharma/View/userScreens/Call%20Planner%20Page/call_planner.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/doctor_visit_model.dart';

class DailyCallReportScreen extends StatefulWidget {
  const DailyCallReportScreen({Key? key}) : super(key: key);

  @override
  State<DailyCallReportScreen> createState() => _DailyCallReportScreenState();
}

class _DailyCallReportScreenState extends State<DailyCallReportScreen> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  late List<ProductModel> products;
  late List<ProductModel>? userAssignedProducts;
  late UserModel? userData;
  DayPlanModel? currentDayPlan;
  List<DoctorVisitModel>? doctorVisitDetailsList = [];
  List<bool>? visitedDoctor = [];
  bool samplesProvided = false;
  ProductModel? selectedProduct;
  TextEditingController doctorRemarksController = TextEditingController();
  List<SelectedProduct> selectedProducts = [];
  bool isReportSubmitted = false;
  bool _isSharedPrefsInitialized = false;

  late SharedPreferences _sharedPrefs;

  void submitReport() async {
    setState(() {
      isReportSubmitted = true;
    });

    // Store the current date as the last submitted date
    final now = DateTime.now();
    await _sharedPrefs.setString('lastSubmittedDate', now.toString());
  }

  @override
  void initState() {
    super.initState();

    _initializeSharedPrefs().then((_) {
      _isSharedPrefsInitialized = true;
      _checkReportSubmission();
    });
    Provider.of<ProductDataProvider>(context, listen: false)
        .fetchProductsList();
    Provider.of<DayPlanProvider>(context, listen: false).fetchDayPlans();
    currentDayPlan = Provider.of<DayPlanProvider>(context, listen: false)
        .getCurrentDayPlan();
    Provider.of<UserDataProvider>(context, listen: false).fetchUserData(userId);
    userData =
        Provider.of<UserDataProvider>(context, listen: false).getUserData;
    userAssignedProducts = userData?.assignedProducts;
    products =
        Provider.of<ProductDataProvider>(context, listen: false).productsList;
    visitedDoctor =
        initializeVisitedDoctorList(currentDayPlan?.doctors.length ?? 5);
  }

  Future<void> _initializeSharedPrefs() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  List<bool> initializeVisitedDoctorList(int length) {
    return List<bool>.generate(
        length, (index) => false); // Initialize with false for all doctors
  }

  void _checkReportSubmission() {
    final lastSubmittedDate = _sharedPrefs.getString('lastSubmittedDate');

    if (lastSubmittedDate != null) {
      final lastSubmittedDateTime = DateTime.parse(lastSubmittedDate);
      final currentDateTime = DateTime.now();

      if (lastSubmittedDateTime.day != currentDateTime.day ||
          lastSubmittedDateTime.month != currentDateTime.month ||
          lastSubmittedDateTime.year != currentDateTime.year) {
        setState(() {
          isReportSubmitted = false;
        });
      } else {
        setState(() {
          isReportSubmitted = true;
        });
      }
    }
  }

  String dayPlanTime() {
    DateFormat dateFormat = DateFormat('EEEE dd/MM/yyyy');
    String formattedDate = dateFormat.format(currentDayPlan!.date);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    if (isReportSubmitted) {
      return Scaffold(
        appBar: const MyAppBar(appBartxt: 'Daily Call Report'),
        body: Center(
          child: MyTextwidget(
            text: 'The report has been submitted for today.',
            fontSize: 20,
          ),
        ),
      );
    } else {
      return Scaffold(
        floatingActionButton: currentDayPlan == null
            ? FloatingActionButton(
                child: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                })
            : FloatingActionButton.extended(
                onPressed: () {
                  final List<DoctorVisitModel> allDoctorVisitDetails = [];

                  for (String doctor in currentDayPlan!.doctors) {
                    DoctorVisitModel? visitDetails = doctorVisitDetailsList!
                        .firstWhereOrNull((visit) => visit.name == doctor);

                    if (visitDetails != null) {
                      allDoctorVisitDetails.add(visitDetails);
                    } else {
                      DoctorVisitModel visitDetails = DoctorVisitModel(
                        name: doctor,
                        visited: false,
                        selectedProducts: [],
                        doctorRemarks: '',
                      );
                      allDoctorVisitDetails.add(visitDetails);
                    }
                  }

                  final DailyCallReportModel dailyCallReportModel =
                      DailyCallReportModel(
                    area: currentDayPlan!.area,
                    date: currentDayPlan!.date,
                    doctorVisits: allDoctorVisitDetails,
                    submittedBy: userData!.displayName!,
                  );

                  Provider.of<DailyCallReportProvider>(context, listen: false)
                      .saveReport(dailyCallReportModel);
                  submitReport();

                  showCustomDialog(
                    context: context,
                    title: 'Report Submitted',
                    content: 'Today\'s Report has been successfully submitted',
                  );
                },
                label: MyTextwidget(text: 'Submit Report'),
                icon: const Icon(Icons.assignment_turned_in),
              ),
        appBar: const MyAppBar(appBartxt: 'Daily Call Report'),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MyTextwidget(
                text: currentDayPlan != null
                    ? 'Doctors According to your today\'s Day Plan: \n ${dayPlanTime()} for ${currentDayPlan!.area} \n Shift : ${currentDayPlan!.shift}'
                    : 'No Plan found!',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (currentDayPlan == null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    MyTextwidget(
                      text:
                          'It seems like there\'s no Day Plan for today, please Proceed to Call Planner Screen and add a Day Plan for today.',
                      fontSize: 16,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    MyButton(
                        text: 'Go to Call Planner',
                        onPressed: () {
                          Navigator.pushNamed(context, CallPlanner.id);
                        })
                  ],
                ),
              ),
            if (currentDayPlan != null)
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: currentDayPlan!.doctors.length,
                  itemBuilder: (context, index) {
                    final dayPlanDoctors = currentDayPlan!.doctors;

                    return Card(
                      color: Colors.teal[100],
                      child: ListTile(
                        title: MyTextwidget(
                          text: dayPlanDoctors[index],
                          fontSize: 16,
                        ),
                        // subtitle: MyTextwidget(text:dayPlanDoctors[index] ,),
                        trailing: TextButton(
                          child: MyTextwidget(text: 'Add Doctor Info'),
                          onPressed: () {
                            doctorDetailsDialog(context, dayPlanDoctors, index);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            // if (currentDayPlan != null)
          ],
        ),
      );
    }
  }

  Future<dynamic> doctorDetailsDialog(
      BuildContext context, List<String> dayPlanDoctors, int index) {
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        int selectedQuantity = 1;
        // Default quantity
        selectedProduct = userAssignedProducts!.isNotEmpty
            ? userAssignedProducts?.first
            : products.first;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog.fullscreen(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyTextwidget(
                        text: 'Add Visit Details for ${dayPlanDoctors[index]}',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          MyTextwidget(text: 'Visited this doctor?'),
                          Checkbox(
                            value: visitedDoctor?[index] ?? false,
                            onChanged: (isVisited) {
                              setState(() {
                                visitedDoctor?[index] = isVisited!;
                              });
                            },
                          )
                        ],
                      ),
                      if (visitedDoctor![index])
                        Row(children: [
                          MyTextwidget(text: 'Samples Provided?'),
                          Checkbox(
                            value: samplesProvided,
                            onChanged: (ifsamples) {
                              setState(() {
                                samplesProvided = ifsamples!;
                              });
                            },
                          ),
                        ]),
                      const SizedBox(height: 16.0),
                      if (samplesProvided)
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<ProductModel>(
                                isExpanded: true,
                                items: userAssignedProducts?.map((product) {
                                      return DropdownMenuItem<ProductModel>(
                                        value: product,
                                        child: Text(product.name),
                                      );
                                    }).toList() ??
                                    products.map((product) {
                                      return DropdownMenuItem<ProductModel>(
                                        value: product,
                                        child: Text(product.name),
                                      );
                                    }).toList(),
                                onChanged: (selectedproduct) {
                                  if (selectedproduct != null) {
                                    setState(() {
                                      selectedProduct = selectedproduct;
                                    });
                                  }
                                },
                                value: selectedProduct,
                                decoration: const InputDecoration(
                                  labelText: 'Select Product',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                items: List.generate(10, (index) => index + 1)
                                    .map((quantity) => DropdownMenuItem<int>(
                                          value: quantity,
                                          child: Text('$quantity'),
                                        ))
                                    .toList(),
                                onChanged: (selectedQty) {
                                  if (selectedQty != null) {
                                    setState(() {
                                      selectedQuantity = selectedQty;
                                    });
                                  }
                                },
                                value: selectedQuantity,
                                decoration: const InputDecoration(
                                  labelText: 'Quantity',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  if (selectedProduct != null) {
                                    setState(() {
                                      SelectedProduct myselectedProduct =
                                          SelectedProduct(
                                              productName:
                                                  selectedProduct!.name,
                                              quantity: selectedQuantity);
                                      selectedProducts.add(myselectedProduct);
                                    });
                                  }
                                },
                                child: MyTextwidget(text: 'Add'),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16.0),
                      Column(
                        children: selectedProducts.map((selectedProduct) {
                          return ListTile(
                            tileColor: Colors.amber[100],
                            title: Text(selectedProduct.productName),
                            subtitle:
                                Text('Quantity: ${selectedProduct.quantity}'),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedProducts.remove(selectedProduct);
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16.0),
                      Flexible(
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please Enter Remarks';
                            }
                            return null;
                          },
                          controller: doctorRemarksController,
                          decoration: const InputDecoration(
                            hintText: 'Add remarks...',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              setState(() {
                                doctorRemarksController.clear();
                                selectedProducts.clear();
                              });
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: const Text('Add Visit Details'),
                            onPressed: () {
                              setState(() {
                                DoctorVisitModel doctorVisitDetails =
                                    DoctorVisitModel(
                                  name: dayPlanDoctors[index],
                                  selectedProducts: List.from(
                                      selectedProducts), // Make a copy of the list
                                  doctorRemarks: doctorRemarksController.text,
                                  visited: visitedDoctor?[index] ?? false,
                                );
                                doctorVisitDetailsList!.add(doctorVisitDetails);
                                // for (DoctorVisitModel doctorvisits
                                //     in doctorVisitDetailsList!) {
                                //   print(doctorvisits.name);
                                //   print(doctorvisits.doctorRemarks);
                                //   print(doctorvisits.selectedProducts);
                                // }
                                doctorRemarksController.clear();
                                selectedProducts =
                                    []; // Clear the original list, not the copied one
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
