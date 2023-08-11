import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../components/constants.dart';
import '../../../services/location_services.dart';

Future<void> showPrivacyConsentDialog(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasShownConsent = prefs.getBool('hasShownConsent') ?? false;

    if (!hasShownConsent) {
      await showDialog(
        context: navigatorKey.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            title: MyTextwidget(text: 'Privacy Consent'),
            content: MyTextwidget(
              text:
                  'By using this app, you consent to the collection and use of your location data for the purpose of sales force automation and tracking your work activities in the field. Your location data will be securely stored and used in accordance with our privacy policy.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  prefs.setBool('hasShownConsent', true);
                  Navigator.of(context).pop();
                  userLocation(uid);
                },
                child: const Text('I Agree'),
              ),
            ],
          );
        },
      );
    } else {
      userLocation(uid);
    }
  }

  void userLocation(uid) async {
    await LocationServices().requestPermission();
    await LocationServices().getLocation(uid);
    SharedPreferences userId = await SharedPreferences.getInstance();
    userId.setString('userId', uid);
  }