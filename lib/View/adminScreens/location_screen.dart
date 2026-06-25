import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/components/widgets/production_widgets.dart';
import 'package:micro_pharma/services/database_service.dart';
import 'google_map_page.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});
  static const String id = 'location_screen';

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(appBartxt: 'Location'),
      body: StreamBuilder(
          stream: DatabaseService.streamUser(),
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data?.docs.isEmpty ?? true) {
              return const EmptyState(
                icon: Icons.location_off_outlined,
                title: 'No employees found',
                message: 'Add employees before using live tracking.',
              );
            }
            return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (context, index) {
                  final userData =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  final isActive = userData['locationTrackingActive'] == true;
                  final accuracy =
                      (userData['locationAccuracy'] as num?)?.toDouble();
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                      leading: CircleAvatar(
                        backgroundColor: isActive
                            ? const Color(0xFFE0F2F1)
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        child: Icon(
                          isActive
                              ? Icons.location_searching_outlined
                              : Icons.person_pin_circle_outlined,
                          color: isActive
                              ? const Color(0xFF0F766E)
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      title: MyTextwidget(
                        text: snapshot.data!.docs[index]['displayName']
                            .toString(),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      subtitle: MyTextwidget(
                        fontSize: 13,
                        text: [
                          isActive ? 'Tracking live' : 'Not tracking',
                          'Updated: ${userData['update'] ?? 'Not available'}',
                          if (accuracy != null)
                            'Accuracy ${accuracy.toStringAsFixed(0)}m',
                        ].join(' • '),
                      ),
                      trailing: IconButton(
                        tooltip: 'Open map',
                        icon: const Icon(
                          Icons.map_outlined,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => GoogleMapPage(
                                userId: snapshot.data!.docs[index]['uid']
                                    .toString(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                });
          }),
    );
  }
}
