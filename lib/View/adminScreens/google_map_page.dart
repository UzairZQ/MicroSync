import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'package:micro_pharma/components/constants.dart';

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
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: const MyAppBar(appBartxt: 'Employee Location'),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: firestore
            .collection('employee_locations')
            .doc(widget.userId)
            .snapshots(),
        builder: (context, locationSnapshot) {
          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream:
                firestore.collection('users').doc(widget.userId).snapshots(),
            builder: (context, userSnapshot) {
              if (!locationSnapshot.hasData && !userSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final userData = userSnapshot.data?.data() ?? {};
              final locationData = locationSnapshot.data?.data() ?? {};
              final data = <String, dynamic>{...userData, ...locationData};
              final latitude = (data['latitude'] as num?)?.toDouble();
              final longitude = (data['longitude'] as num?)?.toDouble();

              if (latitude == null || longitude == null) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No location has been recorded for this employee yet.',
                    ),
                  ),
                );
              }

              final location = LatLng(latitude, longitude);
              final name = data['displayName']?.toString() ??
                  userData['displayName']?.toString() ??
                  'Employee';
              final updatedAt = _readTimestamp(data['updatedAt']);
              final updated = data['update']?.toString() ??
                  (updatedAt == null
                      ? 'No update time'
                      : DateFormat('hh:mma dd/MM/yyyy').format(updatedAt));
              final isActive = data['isTrackingActive'] == true ||
                  data['locationTrackingActive'] == true;
              final isStale = updatedAt == null
                  ? !isActive
                  : DateTime.now().difference(updatedAt).inMinutes > 5;
              final accuracy = (data['accuracy'] as num?)?.toDouble() ??
                  (data['locationAccuracy'] as num?)?.toDouble();

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
                          isActive && !isStale
                              ? BitmapDescriptor.hueAzure
                              : BitmapDescriptor.hueOrange,
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
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isActive && !isStale
                                      ? const Color(0xFFE0F2F1)
                                      : const Color(0xFFFFF7ED),
                                  child: Icon(
                                    isActive
                                        ? Icons.location_searching_outlined
                                        : Icons.location_off_outlined,
                                    color: isActive && !isStale
                                        ? const Color(0xFF0F766E)
                                        : const Color(0xFFC2410C),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isActive
                                            ? isStale
                                                ? 'Tracking active, update is stale'
                                                : 'Tracking live'
                                            : 'Day ended / not tracking',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _MapInfoChip(
                                  icon: Icons.schedule_outlined,
                                  label: updated,
                                ),
                                if (accuracy != null)
                                  _MapInfoChip(
                                    icon: Icons.gps_fixed_outlined,
                                    label:
                                        'Accuracy ${accuracy.toStringAsFixed(0)}m',
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
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
              final latest = await FirebaseFirestore.instance
                  .collection('employee_locations')
                  .doc(widget.userId)
                  .get();
              final user = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId)
                  .get();
              final data = <String, dynamic>{
                ...(user.data() ?? {}),
                ...(latest.data() ?? {}),
              };
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

  DateTime? _readTimestamp(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}

class _MapInfoChip extends StatelessWidget {
  const _MapInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}
