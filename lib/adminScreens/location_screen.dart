import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:micro_pharma/components/constants.dart';
import 'package:micro_pharma/services/database.dart';
import 'GoogleMapPage.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({Key? key}) : super(key: key);
  static const String id = 'location_screen';

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
                  return ListTile(
                    title: Text(
                        snapshot.data!.docs[index]['displayName'].toString()),
                    subtitle: Row(
                      children: [
                        Text(snapshot.data!.docs[index]['latitude'].toString()),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                            snapshot.data!.docs[index]['longitude'].toString()),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.directions),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => GoogleMapPage(
                              userId: snapshot.data!.docs[index].id.toString(),
                            ),
                          ),
                        );
                      },
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