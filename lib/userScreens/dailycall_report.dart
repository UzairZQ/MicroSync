import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/models/day_plan_model.dart';
import 'package:micro_pharma/models/dcr_model.dart';
import 'package:micro_pharma/models/product_model.dart';
import 'package:micro_pharma/providers/day_plans_provider.dart';
import 'package:micro_pharma/providers/product_data_provider.dart';
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

  void _addProduct(ProductModel? product, int quantity) {
    setState(() {
      selectedProducts
          .add(SelectedProduct(product: product!, quantity: quantity));
    });
  }

  Widget _buildSelectedProducts(DoctorVisitModel doctorVisitDetails) {
    return Column(
      children: doctorVisitDetails.selectedProducts!.map((selectedProduct) {
        return ListTile(
          tileColor: Colors.amber,
          title: Text(selectedProduct.product.name),
          subtitle: Text('Quantity: ${selectedProduct.quantity}'),
          trailing: IconButton(
            icon: const Icon(
              Icons.remove_circle,
              color: Colors.red,
            ),
            onPressed: () {
              setState(() {
                doctorVisitDetails.selectedProducts!.remove(selectedProduct);
              });
            },
          ),
        );
      }).toList(),
    );
  }

  String dayPlanTime() {
    DateFormat dateFormat = DateFormat('EEEE dd/MM/yyyy');
    String formattedDate = dateFormat.format(currentDayPlan!.date);
    return formattedDate;
  }

  void _removeProduct(SelectedProduct product) {
    setState(() {
      selectedProducts.remove(product);
    });
  }

  Widget _buildProductDropdown(DoctorVisitModel doctorVisitDetails) {
    int selectedQuantity = 1; // Default quantity
    ProductModel? selectedProduct;

    return Row(
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
            onChanged: (selectedProduct) {
              if (selectedProduct != null) {
                setState(() {
                  doctorVisitDetails.selectedProducts!.add(
                    SelectedProduct(
                      product: selectedProduct,
                      quantity: selectedQuantity,
                    ),
                  );
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
                selectedQuantity = selectedQty;
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
              setState(() {
                doctorVisitDetails.selectedProducts!.add(
                  SelectedProduct(
                    product: selectedProduct!,
                    quantity: selectedQuantity,
                  ),
                );
              });
            },
            child: MyTextwidget(text: 'Add'),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard(String doctorName) {
    return Card(
      color: Colors.teal[100],
      child: ListTile(
        title: MyTextwidget(
          text: doctorName,
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
                })
          ],
        ),
        trailing: TextButton(
          child: MyTextwidget(text: 'Add Doctor Info'),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                // Create a new instance of DoctorVisitDetails
                DoctorVisitModel doctorVisitDetails = DoctorVisitModel(
                  name: doctorName,
                  selectedProducts: [],
                  doctorRemarks: '',
                );

                return StatefulBuilder(
                  builder: (context, setState) {
                    return Dialog.fullscreen(
                      backgroundColor: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MyTextwidget(
                              text: 'Add Visit Details',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            const SizedBox(height: 16.0),
                            MyTextwidget(text: 'Samples Provided?'),
                            const SizedBox(height: 16.0),
                            _buildProductDropdown(doctorVisitDetails),
                            const SizedBox(height: 16.0),
                            _buildSelectedProducts(doctorVisitDetails),
                            const SizedBox(height: 16.0),
                            TextField(
                              controller: doctorRemarksController,
                              decoration: const InputDecoration(
                                hintText: 'Add remarks...',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    setState(() {
                                      doctorVisitDetails.selectedProducts!
                                          .clear();
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                TextButton(
                                  child: const Text('Add Information'),
                                  onPressed: () {
                                    // Handle adding the information to the doctor's card
                                    // Perform necessary actions with the selected products,
                                    // samplesProvided value, and remarks entered
                                    setState(() {
                                      doctorVisitDetails.doctorRemarks =
                                          doctorRemarksController
                                              .text; // Get the remarks entered
                                    });

                                    // Add the doctorVisitDetails to the list
                                    setState(() {
                                      doctorVisitDetailsList!
                                          .add(doctorVisitDetails);
                                    });

                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
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
              text:
                  'Doctors According to your today\'s Day Plan: ${dayPlanTime()}',
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (currentDayPlan == null)
            MyTextwidget(
                text:
                    'There\'s No Day Plan for today, please Process to Call Planner and add Day Plan'),
          if (currentDayPlan != null)
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: currentDayPlan!.doctors.length,
                itemBuilder: (context, index) {
                  final dayPlanDoctors = currentDayPlan!.doctors;

                  return _buildDoctorCard(dayPlanDoctors[index]);
                },
              ),
            ),
          MyButton(text: 'Submit Report', onPressed: () {}),
        ],
      ),
    );
  }
}
