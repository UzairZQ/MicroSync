import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:geolocator_android/geolocator_android.dart';
import 'package:location/location.dart' as location;

class LocationServices extends ChangeNotifier {
  // Declare permission status variables

  Future<void> requestPermission() async {
    try {
      print('requested permission');
      PermissionStatus locationPermission = await Permission.location.request();
      if (locationPermission.isGranted) {
        PermissionStatus locationAlwaysPermission =
            await Permission.locationAlways.status;
        if (!locationAlwaysPermission.isGranted) {
          locationPermission = PermissionStatus.granted;
          locationAlwaysPermission = await Permission.locationAlways.request();
        } else {
          locationPermission = PermissionStatus.granted;
          locationAlwaysPermission = PermissionStatus.granted;
          return; // Both permissions are already granted, no further action needed
        }
      } else if (locationPermission.isDenied) {
        await requestPermission();
      } else if (locationPermission.isPermanentlyDenied) {
        openAppSettings();
      }
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  String dateTime() {
    DateFormat dateFormat =
        DateFormat('hh:mma dd/MM/yyyy'); // create date format
    String formattedDate =
        dateFormat.format(DateTime.now()); // format current date
    return formattedDate;
  }

  Future<void> getBackgroundLocation(String uid) async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        String time = dateTime();
        GeolocatorAndroid.registerWith();
        await geolocator.Geolocator.getCurrentPosition(
          desiredAccuracy: geolocator.LocationAccuracy.best,
          forceAndroidLocationManager: true,
        ).then((position) async {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'update': time,
          }, SetOptions(merge: true));
          print('Fetched the location and added it to the database');
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getLocation(String uid) async {
    try {
      print('reached getLocation method');
      if (defaultTargetPlatform == TargetPlatform.android) {
        String time = dateTime();
        location.LocationData currentLocation =
            await location.Location().getLocation();
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'latitude': currentLocation.latitude,
          'longitude': currentLocation.longitude,
          'update': time,
        }, SetOptions(merge: true));
        print('Fetched the location and added it to the database');
      }
    } catch (e) {
      print('error in the getLocation function ::: $e');
    }
  }
}
