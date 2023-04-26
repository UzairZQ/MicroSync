import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/services/database_service.dart';

class GoogleMapPage extends StatefulWidget {
  static const String id = 'map_page';

  final String userId;

  const GoogleMapPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  late GoogleMapController _controller;
  bool isSatellite = false;
  late StreamSubscription<QuerySnapshot> _subscription;
  LatLng _lastKnownLocation = const LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _subscription = DatabaseService.streamUser().listen(_onLocationUpdate);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _onLocationUpdate(QuerySnapshot snapshot) {
    final userData = snapshot.docs.singleWhere(
      (element) => element.id == widget.userId,
    );
    setState(() {
      _lastKnownLocation = LatLng(
        userData['latitude'] as double,
        userData['longitude'] as double,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(appBartxt: 'User Location'),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: DatabaseService.streamUser(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return GoogleMap(
              mapType: isSatellite ? MapType.satellite : MapType.normal,
              markers: {
                Marker(
                  markerId: const MarkerId('Current User Location'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _lastKnownLocation,
                ),
              },
              initialCameraPosition: CameraPosition(
                target: _lastKnownLocation,
                zoom: 15.00,
              ),
              onMapCreated: (GoogleMapController controller) {
                setState(() {
                  _controller = controller;
                });
              },
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24.0, right: 24.0),
        child: FloatingActionButton.extended(
            onPressed: () {
              setState(() {
                isSatellite = !isSatellite;
              });
            },
            label: const Text(
              'Change Map Type',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            icon: const Icon(Icons.map_outlined),
            backgroundColor: Colors.deepPurple),
      ),
    );
  }
}
