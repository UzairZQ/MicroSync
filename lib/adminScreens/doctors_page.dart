import 'package:flutter/material.dart';
import 'package:micro_pharma/adminScreens/add_doctor.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/userScreens/home_page.dart';
import '../userScreens/login_page.dart';

class DoctorsPage extends StatelessWidget {
  const DoctorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: ((context) => AddDoctor())));
          },
          label: Text('Add Doctor')),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Doctors',
          textAlign: TextAlign.center,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ));
            },
          ),
        ],
      ),

      // appBar: MyAppBar(appBartxt: 'Visited Doctors'),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Padding(padding: EdgeInsets.all(10)),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.blueGrey[900],
                  ),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      8.0,
                    ),
                  ),
                ),
              ),
              // Expanded(child: Container())
            ],
          ),
        ),
      ),
    );
  }
}
