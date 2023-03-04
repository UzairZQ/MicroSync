import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/services/database.dart';
import 'package:micro_pharma/services/location_services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'GoogleMapPage.dart';

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
      appBar: myAppBar(appBartxt: 'Location'),
      body: StreamBuilder(
          stream: DataBaseService().streamUser(),
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
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
                          Text(snapshot.data!.docs[index]['latitude']
                              .toString()),
                          SizedBox(
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
                        icon: Icon(Icons.directions),
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


//ListView(
      //   shrinkWrap: true,
      //   children: [
      //     Card(
      //       elevation: 5.0,
      //       child: ListTile(
      //         tileColor: Colors.grey[300],
      //         title: Text(
      //           'Uzair Zia Qureshi',
      //           style: TextStyle(
      //               fontFamily: 'Poppins', fontWeight: FontWeight.bold),
      //         ),
      //         leading: Icon(
      //           Icons.person_outline,
      //           size: 30.0,
      //         ),
      //         trailing: IconButton(
      //           icon: Icon(
      //             size: 30.0,
      //             Icons.location_pin,
      //             color: Colors.blueGrey,
      //           ),
      //           onPressed: () {
      //             Navigator.pushNamed(context, GoogleMapPage.id);
      //           },
      //         ),
      //       ),
      //     ),
      //   ],
      // ),