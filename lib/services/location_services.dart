import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:intl/intl.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/geolocator_android.dart';

class LocationServices extends ChangeNotifier {
  Future<void> listenLocation(String uid) async {}

  Future requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
     
    } else if (status.isDenied) {
      requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    notifyListeners();
  }

  String dateTime() {
    DateFormat dateFormat =
        DateFormat('hh:mma dd/MM/yyyy'); // create date format
    String formattedDate =
        dateFormat.format(DateTime.now()); // format current date
    return formattedDate;
  }

  Future<void> getLocation(String uid) async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        String time = dateTime();
        GeolocatorAndroid.registerWith();
        await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          forceAndroidLocationManager: true,
        ).then((position) async {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'update': time,
          }, SetOptions(merge: true));
        });
      }
    } catch (e) {
    print(e);
    }
  }

  stopListening() {}
}
