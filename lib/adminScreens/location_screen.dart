import 'package:flutter/cupertino.dart';
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
      body: Material(
        elevation: 5.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: kbuttonstyle(
            color: Colors.blue,
            text: 'Get Location',
            onPressed: () => Navigator.pushNamed(context, GoogleMapPage.id),
          ),
        ),
      ),
    );
  }
}
