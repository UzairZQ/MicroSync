import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/models/day_plan_model.dart';
import 'package:micro_pharma/models/dcr_model.dart';
import 'package:micro_pharma/models/product_model.dart';
import 'package:micro_pharma/providers/daily_call_report_provider.dart';
import 'package:micro_pharma/providers/day_plans_provider.dart';
import 'package:micro_pharma/providers/product_data_provider.dart';
import 'package:micro_pharma/userScreens/call_planner.dart';
import 'package:provider/provider.dart';

class SelectedProduct {
  final ProductModel product;
  int quantity;

  SelectedProduct({required this.product, required this.quantity});
}

class DailyCallReportScreen extends StatefulWidget {
  const DailyCallReportScreen({Key? key}) : super(key: key);

  @override
  State<DailyCallReportScreen> createState() => _DailyCallReportScreenState();
}

class _DailyCallReportScreenState extends State<DailyCallReportScreen> {
  late List<ProductModel> products;
  DayPlanModel? currentDayPlan;
  List<DoctorVisitModel>? doctorVisitDetailsList = [];

  bool visitedDoctor = false;
  // bool samplesProvided = false;
  List<SelectedProduct> selectedProducts = [];
  ProductModel? selectedProduct;
  TextEditingController doctorRemarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<ProductDataProvider>(context, listen: false)
        .fetchProductsList();
    products =
        Provider.of<ProductDataProvider>(context, listen: false).productsList;
    Provider.of<DayPlanProvider>(context, listen: false).fetchDayPlans();
    currentDayPlan = Provider.of<DayPlanProvider>(context, listen: false)
        .getCurrentDayPlan();
  }

  void _addProduct(DoctorVisitModel doctorVisitDetails, ProductModel? product,
      int quantity) {
    setState(() {
      List<SelectedProduct> updatedList =
          List.from(doctorVisitDetails.selectedProducts ?? []);
      updatedList.add(SelectedProduct(
        product: product!,
        quantity: quantity,
      ));
      doctorVisitDetails.selectedProducts = updatedList;
    });
  }

  String dayPlanTime() {
    DateFormat dateFormat = DateFormat('EEEE dd/MM/yyyy');
    String formattedDate = dateFormat.format(currentDayPlan!.date);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(appBartxt: 'Daily Call Report'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MyTextwidget(
              text: currentDayPlan != null
                  ? 'Doctors According to your today\'s Day Plan: ${dayPlanTime()}'
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
                      subtitle: Row(
                        children: [
                          MyTextwidget(text: 'Visited?'),
                          Checkbox(
                            value: visitedDoctor,
                            onChanged: (visited) {
                              setState(() {
                                visitedDoctor = visited!;
                              });
                            },
                          ),
                        ],
                      ),
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
          if (currentDayPlan != null)
            MyButton(
                text: 'Submit Report',
                onPressed: () {
                  final DailyCallReportModel dailyCallReportModel =
                      DailyCallReportModel(
                          date: currentDayPlan!.date,
                          doctorsVisited: doctorVisitDetailsList!);
                  Provider.of<DailyCallReportProvider>(context)
                      .saveReport(dailyCallReportModel);
                }),
        ],
      ),
    );
  }

  Future<dynamic> doctorDetailsDialog(
      BuildContext context, List<String> dayPlanDoctors, int index) {
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        DoctorVisitModel doctorVisitDetails = DoctorVisitModel(
          name: dayPlanDoctors[index],
          selectedProducts: [],
          doctorRemarks: doctorRemarksController.text,
        );
        int selectedQuantity = 1; // Default quantity
        selectedProduct = products.isNotEmpty ? products.first : null;
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
                        text: 'Add Visit Details',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 16.0),
                      MyTextwidget(text: 'Samples Provided?'),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<ProductModel>(
                              items: products.map((product) {
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
                                    _addProduct(doctorVisitDetails,
                                        selectedProduct, selectedQuantity);
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
                        children: doctorVisitDetails.selectedProducts!
                            .map((selectedProduct) {
                          return ListTile(
                            tileColor: Colors.amber[100],
                            title: Text(selectedProduct.product.name),
                            subtitle:
                                Text('Quantity: ${selectedProduct.quantity}'),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  doctorVisitDetails.selectedProducts!
                                      .remove(selectedProduct);
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
                              });
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: const Text('Add Information'),
                            onPressed: () {
                              setState(() {
                                doctorVisitDetailsList!.add(doctorVisitDetails);
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
