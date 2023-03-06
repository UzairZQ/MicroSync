import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

class LocationServices extends ChangeNotifier {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? locationSubscription;

  Future<void> listenLocation(String uid) async {
    location.changeSettings(
        interval: 5000, accuracy: loc.LocationAccuracy.balanced);
    locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      locationSubscription?.cancel();
      locationSubscription = null;
      notifyListeners();
    }).listen((loc.LocationData currentlocation) async {
      location.changeSettings(
          interval: 5000, accuracy: loc.LocationAccuracy.balanced);
      location.enableBackgroundMode(enable: true);
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'latitude': currentlocation.latitude,
        'longitude': currentlocation.longitude,
      }, SetOptions(merge: true));
      notifyListeners();
    });
  }

  Future requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('done');
    } else if (status.isDenied) {
      requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    notifyListeners();
  }

  getLocation(String uid) async {
    try {
      final loc.LocationData locationResult = await location.getLocation();
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'latitude': locationResult.latitude,
        'longitude': locationResult.longitude,
      }, SetOptions(merge: true));
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  stopListening() {
    locationSubscription?.cancel();
    locationSubscription = null;
    location.enableBackgroundMode(enable: false);
    notifyListeners();
  }
}
