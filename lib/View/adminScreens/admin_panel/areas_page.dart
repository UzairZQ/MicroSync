import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/viewModel/area_provider.dart';
import 'package:provider/provider.dart';

class Areas extends StatefulWidget {
  const Areas({super.key});

  @override
  State<Areas> createState() => _AreasState();
}

class _AreasState extends State<Areas> {
  final TextEditingController areaNameController = TextEditingController();
  final TextEditingController areaCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AreaProvider>().fetchAreas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final areasProvider = Provider.of<AreaProvider>(context);

    return Scaffold(
      appBar: const MyAppBar(appBartxt: 'Areas'),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            isScrollControlled: true,
            constraints: BoxConstraints.loose(const Size.fromHeight(550)),
            context: context,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      ListTile(
                        title: const Center(
                          child: Text(
                            'Area',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        subtitle: Column(
                          children: [
                            TextFormField(
                              controller: areaNameController,
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                      ? 'Please enter area name'
                                      : null,
                              onSaved: (name) {
                                areaNameController.text = name!;
                              },
                              decoration: const InputDecoration(
                                hintText: 'Please Enter Area Name',
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            TextFormField(
                              controller: areaCodeController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter area code';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Please enter a valid code';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                areaCodeController.text = newValue!;
                              },
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Please Enter Area Code',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      MyButton(
                        color: Colors.blue,
                        text: 'Add Area',
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            final messenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);
                            final added = await areasProvider.addAreatoDatabase(
                              areaNameController.text,
                              areaCodeController.text,
                            );
                            if (added) {
                              areaCodeController.clear();
                              areaNameController.clear();
                              navigator.pop();
                            }
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(added
                                    ? 'Area added'
                                    : 'Could not add area'),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        label: const MyTextwidget(
          text: 'Add Area',
          fontSize: 16,
        ),
      ),
      body: ListView.builder(
        itemCount: areasProvider.getAreas.length,
        itemBuilder: (context, index) {
          final area = areasProvider.getAreas[index];

          return Card(
            elevation: 2.0,
            color: Colors.blue[50],
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: ListTile(
              title: MyTextwidget(
                text: area.areaName,
                fontSize: 17,
              ),
              subtitle: Text('${area.areaId}'),
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Color.fromARGB(255, 252, 154, 154),
                ),
                onPressed: () {
                  showCustomDialog(
                      context: context,
                      title: 'Delete Area',
                      content: 'Do you really want to delete this area?',
                      actions: [
                        TextButton(
                          style:
                              TextButton.styleFrom(foregroundColor: Colors.red),
                          onPressed: () async {
                            final deleted = await areasProvider
                                .deleteAreaFromDatabase(area.areaId);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(deleted
                                    ? 'Area deleted'
                                    : 'Could not delete area'),
                              ),
                            );
                          },
                          child: const Text('Delete'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                      ]);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
