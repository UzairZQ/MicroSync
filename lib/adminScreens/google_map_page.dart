// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/services/database.dart';

class GoogleMapPage extends StatefulWidget {
  static const String id = 'map_page';

  final String userId;

  const GoogleMapPage({super.key, required this.userId});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  final db = DataBaseService();
  late GoogleMapController _controller;
  bool _added = false;
  bool isSatellite = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print('disposed google maps');
    // Provider.of<LocationServices>(context).stopListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(appBartxt: 'Map Screen'),
      body: StreamBuilder(
        stream: db.streamUser(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (_added) {
            mymap(snapshot);
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return GoogleMap(
            mapType: isSatellite ? MapType.satellite : MapType.normal,
            markers: {
              Marker(
                markerId: MarkerId('Current User Location'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
                position: LatLng(
                  snapshot.data!.docs.singleWhere(
                      (element) => element.id == widget.userId)['latitude'],
                  snapshot.data!.docs.singleWhere(
                      (element) => element.id == widget.userId)['longitude'],
                ),
              ),
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(
                snapshot.data!.docs.singleWhere(
                    (element) => element.id == widget.userId)['latitude'],
                snapshot.data!.docs.singleWhere(
                    (element) => element.id == widget.userId)['longitude'],
              ),
              zoom: 15.00,
            ),
            onMapCreated: (GoogleMapController controller) async {
              setState(() {
                _controller = controller;
                _added = true;
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            isSatellite = !isSatellite;
          });
        },
        label: const Text(
          'Change Map Type',
          style: TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
        icon: const Icon(Icons.location_on_outlined),
      ),
    );
  }

  Future<void> mymap(AsyncSnapshot<QuerySnapshot> snapshot) async {
    await _controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              snapshot.data!.docs.singleWhere(
                  (element) => element.id == widget.userId)['latitude'],
              snapshot.data!.docs.singleWhere(
                  (element) => element.id == widget.userId)['longitude'],
            ),
            zoom: 15.00)));
  }
}
