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
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                      leading: const Icon(Icons.person_pin_circle_outlined),
                      title: MyTextwidget(
                        text: snapshot.data!.docs[index]['displayName']
                            .toString(),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      subtitle: MyTextwidget(
                        fontSize: 13,
                        text:
                            'Updated: ${userData['update'] ?? 'Not available'}',
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
