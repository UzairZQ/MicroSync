import 'package:flutter/material.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/services/database_service.dart';
import 'google_map_page.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);
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
            return ListView.builder(
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    color: Colors.blue[100],
                    child: ListTile(
                      title: MyTextwidget(
                        text: snapshot.data!.docs[index]['displayName']
                            .toString(),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      subtitle: Row(
                        children: [
                          Flexible(
                            child: MyTextwidget(
                                fontSize: 15,
                                text:
                                    'Location Updated at: ${snapshot.data!.docs[index]['update']}'),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        color: Colors.red,
                        icon: const Icon(
                          Icons.location_pin,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {});
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
