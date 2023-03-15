import 'package:flutter/material.dart';

import 'package:micro_pharma/components/constants.dart';

import 'package:micro_pharma/services/database.dart';

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
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(appBartxt: 'Location'),
      body: StreamBuilder(
          stream: DataBaseService().streamUser(),
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5,
                    color: Colors.grey[290],
                    child: ListTile(
                      title: Text(
                          snapshot.data!.docs[index]['displayName'].toString()),
                      subtitle: Row(
                        children: [
                          // Text('Location Updated at: $time'),
                          Text(snapshot.data!.docs[index]['latitude']
                              .toString()),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(snapshot.data!.docs[index]['longitude']
                              .toString()),
                          // TextButton(
                          //   onPressed: () async {

                          //     await LocationServices().getLocation(
                          //         snapshot.data!.docs[index]['uid']);
                          //   },
                          //   child: Text('Refresh Location'),
                          // ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.directions),
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
