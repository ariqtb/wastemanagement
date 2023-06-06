import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../geolocator.dart';

class showDataPickup extends StatefulWidget {
  const showDataPickup({super.key});

  @override
  State<showDataPickup> createState() => _showDataPickupState();
}

class _showDataPickupState extends State<showDataPickup> {
  List<dynamic> data = [];
  bool isLoading = false;

  Future<void> fetchData() async {
    final response = await http
        .get(Uri.parse('https://wastemanagement.tubagusariq.repl.co/produsen'));
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          isLoading = true;
          data = json.decode(response.body);
        });
      }
      print(data[0]['_id']);
    } else {
      throw Exception("Failed to load data");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: Text('Pengambilan Sampah'),
          ),
          body: Center(
            child: !isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      data.isNotEmpty
                          ? Column(
                              children: data
                                  .map(
                                    (item) => ListTile(
                                      leading: CircleAvatar(
                                        child:
                                            Text('${data.indexOf(item) + 1}'),
                                      ),
                                      title: Text("${item['user'][0]['name']}"),
                                      subtitle: Text(item['date']),
                                      trailing: Icon(Icons.arrow_forward),
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (BuildContext context) {
                                              return GenerateLocator();
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                  .toList(),
                            )
                          : Container(
                              color: Colors.grey[100],
                              padding: EdgeInsets.all(15),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                elevation: 1,
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(15),
                                  child: Text('Tidak ada riwayat'),
                                ),
                              ),
                            ),
                    ],
                  ),
          ),
        ),
      ),
    );

    // StreamBuilder(
    //   stream: db.collection('waste').snapshots(),
    //   builder: (BuildContext context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return Center(child: CircularProgressIndicator());
    //     }
    //     if (snapshot.hasError) {
    //       return const Center(
    //         child: Text('Error!'),
    //       );
    //     }

    //     var _data = snapshot.data!.docs;
    //     // _data.first.

    //     return ListView.builder(itemBuilder: (context, index) {
    //       return ListTile(
    //         leading: CircleAvatar(
    //           child: Text(index.toString()),
    //         ),
    //         title: Text(_data[index].data().toString()),
    //         subtitle: Row(children: [
    //           Text('Status: '),
    //           _data[index].data()['picked_up'] ?
    //           Text('Sudah diambil') :
    //           Text('Belum diambil')
    //         ],),
    //       );
    //     });
    //   });
// Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 fetchData();
//               },
//               child: Text('Fetch Data'),
//             ),
//             if (data.isNotEmpty)
//               Column(
//                 children: [
//                   Container()
//                 ]
//               )
//           ],
//         ),
//       );
    // );
    //     Flexible(
    //   child: Container(
    //     padding: EdgeInsets.fromLTRB(5, 10, 5, 5),
    //     child: ListView.builder(
    //       itemCount: data.length,
    //       itemBuilder: (BuildContext context, int index) {
    //         return ListTile(
    //           leading: CircleAvatar(
    //             child: Text(index.toString()),
    //           ),
    //           title: Text(data[index]['location']['lat']),
    //           subtitle: Row(children: [
    //             Text('Status: '),
    //             data[index]['picked_up']
    //                 ? Text('Sudah Diambil')
    //                 : Text('Belum Selesai')
    //           ]),
    //           trailing: Icon(Icons.arrow_forward),
    //           onTap: () {
    //             Navigator.of(context).push(
    //               MaterialPageRoute(
    //                 builder: (BuildContext context) {
    //                   return GenerateLocator();
    //                 },
    //               ),
    //             );
    //           },
    //         );
    //       },
    //     ),
    //   ),
    // );
  }
}
