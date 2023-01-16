import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:micro_pharma/components/constants.dart';
import 'GoogleMapPage.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({Key? key}) : super(key: key);
  static const String id = 'location_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(appBartxt: 'Location'),
      body: ListView(
        shrinkWrap: true,
        children: [
          Card(
            elevation: 5.0,
            child: ListTile(
              tileColor: Colors.grey[300],
              title: Text(
                'Uzair Zia Qureshi',
                style: TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.bold),
              ),
              leading: Icon(
                Icons.person_outline,
                size: 30.0,
              ),
              trailing: IconButton(
                icon: Icon(
                  size: 30.0,
                  Icons.location_pin,
                  color: Colors.blueGrey,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, GoogleMapPage.id);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
