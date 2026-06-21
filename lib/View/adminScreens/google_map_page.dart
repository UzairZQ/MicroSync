import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/services/database_service.dart';

class GoogleMapPage extends StatefulWidget {
  static const String id = 'map_page';

  final String userId;

  const GoogleMapPage({super.key, required this.userId});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  GoogleMapController? _controller;
  bool isSatellite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(appBartxt: 'User Location'),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService.streamUser(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs
              .where((element) => element.id == widget.userId)
              .toList();
          if (docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('This employee could not be found.'),
              ),
            );
          }

          final data = docs.first.data() as Map<String, dynamic>;
          final latitude = (data['latitude'] as num?)?.toDouble();
          final longitude = (data['longitude'] as num?)?.toDouble();
          if (latitude == null || longitude == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No location has been recorded for this employee.'),
              ),
            );
          }

          final location = LatLng(latitude, longitude);
          final name = data['displayName']?.toString() ?? 'Employee';
          final updated = data['update']?.toString() ?? 'No update time';

          return Stack(
            children: [
              GoogleMap(
                mapType: isSatellite ? MapType.satellite : MapType.normal,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers: {
                  Marker(
                    markerId: MarkerId(widget.userId),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure,
                    ),
                    position: location,
                    infoWindow: InfoWindow(
                      title: name,
                      snippet: 'Updated $updated',
                    ),
                  ),
                },
                initialCameraPosition: CameraPosition(
                  target: location,
                  zoom: 15,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                },
              ),
              Positioned(
                left: 16,
                right: 16,
                top: 16,
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_pin_circle_outlined),
                    title: Text(name),
                    subtitle: Text('Location updated $updated'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'mapType',
            tooltip: 'Change map type',
            onPressed: () {
              setState(() {
                isSatellite = !isSatellite;
              });
            },
            child: const Icon(Icons.layers_outlined),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.small(
            heroTag: 'recenter',
            tooltip: 'Recenter',
            onPressed: () async {
              final controller = _controller;
              if (controller == null) {
                return;
              }
              final snapshot = await DatabaseService.streamUser().first;
              final docs = snapshot.docs
                  .where((element) => element.id == widget.userId)
                  .toList();
              if (docs.isEmpty) {
                return;
              }
              final data = docs.first.data() as Map<String, dynamic>;
              final latitude = (data['latitude'] as num?)?.toDouble();
              final longitude = (data['longitude'] as num?)?.toDouble();
              if (latitude == null || longitude == null) {
                return;
              }
              controller.animateCamera(
                CameraUpdate.newLatLngZoom(LatLng(latitude, longitude), 15),
              );
            },
            child: const Icon(Icons.my_location_outlined),
          ),
        ],
      ),
    );
  }
}
