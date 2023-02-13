// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/services/database.dart';
import 'package:micro_pharma/services/location_services.dart';
import 'package:provider/provider.dart';

import 'package:location/location.dart' as loc;

class GoogleMapPage extends StatefulWidget {
  static const String id = 'map_page';

  final String userId;

  GoogleMapPage({required this.userId});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  bool _added = false;

  // static const CameraPosition _atdPosition =
  //     CameraPosition(target: LatLng(34.1688, 73.2215), zoom: 14.4746);
  // final Completer<GoogleMapController> _controller = Completer();
  // final List<Marker> _markers = <Marker>[
  //   const Marker(
  //     markerId: MarkerId('1'),
  //     position: LatLng(34.1688, 73.2215),
  //     infoWindow: InfoWindow(title: 'Initial Location'),
  //   ),
  // ];

  // Future<Position> getUserCurrentLocation() async {
  //   await Geolocator.requestPermission()
  //       .then((value) {})
  //       .onError((error, stackTrace) {
  //     print('error' + error.toString());
  //   });

  //   return await Geolocator.getCurrentPosition();
  // }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print('disposed google maps');
    // Provider.of<LocationServices>(context).stopListening();
    LocationServices().stopListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(appBartxt: 'Map Screen'),

      // title: Text(
      //   'Map Screen',
      //   style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
      // ),
      // leading:

      body: StreamBuilder(
        stream: DataBaseService().streamUser(),
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
            mapType: MapType.normal,
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
              zoom: 14.47,
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
          LocationServices().getLocation(widget.userId);
        },
        label: const Text(
          'Get User Location',
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
            zoom: 14.47)));
  }
}




// GoogleMap(
//         initialCameraPosition: _atdPosition,
//         markers: Set<Marker>.of(_markers),
//         zoomControlsEnabled: false,
//         mapType: MapType.normal,
//         onMapCreated: (GoogleMapController controller) {
//           _controller.complete(controller);
//         },
//       ),



//  getUserCurrentLocation().then(
//             (value) async {
//               print('my current locaton');
//               print(
//                   value.latitude.toString() + " " + value.longitude.toString());

//               _markers.add(
//                 Marker(
//                   markerId: const MarkerId('2'),
//                   position: LatLng(value.latitude, value.longitude),
//                   infoWindow: const InfoWindow(title: 'Current User Location'),
//                 ),
//               );

//               CameraPosition cameraPosition = CameraPosition(
//                   target: LatLng(value.latitude, value.longitude), zoom: 18);

//               final GoogleMapController controller = await _controller.future;
//               controller.animateCamera(
//                   CameraUpdate.newCameraPosition(cameraPosition));
//               setState(() {});
//             },
//           );