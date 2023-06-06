import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:namer_app/components/geolocator.dart';
import 'package:namer_app/conn/conn_api.dart';
import 'package:namer_app/pages/image_sorting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../components/add_location.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class RecapLocationToSave extends StatefulWidget {
  final List<Map<String, dynamic>> location;
  final List<Map<String, dynamic>> listProdusen;

  const RecapLocationToSave(
      {super.key, required this.location, required this.listProdusen});

  @override
  State<RecapLocationToSave> createState() => _RecapLocationToSaveState();
}

class _RecapLocationToSaveState extends State<RecapLocationToSave> {
  Map<String, dynamic>? datas;
  List<Map<String, dynamic>>? wasteData;
  List<Map<String, dynamic>> locationList = [];
  List<Map<String, dynamic>> filteredLocation = [];
  List<Map<String, dynamic>> listProdusen = [];
  late String currentDate;
  bool buttonDisabled = false;

  matchListProdusen(listProdusen, location) {
    // print("LOCATIONBEFORE: ${location}");
    // print("LOCATIONBEFORE: ${listProdusen}");
    // List<Map<String, dynamic>> filteredLocation = location.where((item) => item['produsen_info']['status'] == 1).toList();
    List<Map<String, dynamic>> filteredLocation = location.where((item) => item['produsen_info']['status'] == 1).toList();
    // List<Map<String, dynamic>> getListProdusen = listProdusen;

    print("LOCATION: ${filteredLocation}");
    filteredLocation.forEach((element) {
      return print("INI FILTERED: ${element['produsen_info']['status']}");
    });

    List<Map<String, dynamic>> loc = filteredLocation.where((map1) {
     return  listProdusen.any((map2) => map2['id_waste_produsen'] == map1['produsen_info']['id_waste_produsen']);
    }).toList();
    // loc.forEach((map1) => print("INI MECING MAP: ${map1['produsen_info']['status']}"));
      


    listProdusen.forEach((map1) {
      var id = map1['id_waste_produsen'];
      // var matchingMap = filteredLocation.where((map2) => map2['produsen_info']['id_waste_produsen'] == id && map2['produsen_info']['status'] == 1,);
      var matchingMap = filteredLocation.firstWhere((map2) => map2['produsen_info']['id_waste_produsen'] == id, orElse: () => {},);
      map1['status'] = matchingMap['produsen_info'] == null ? 0 : 1;
      // print("INI MECING MAP: ${map1}");
    });

    return listProdusen;
  }

  Future<void> saveLocation() async {
    setState(() {
      buttonDisabled = true;
    });
    DateTime now = DateTime.now();
    currentDate = now.toString();
    List<dynamic> data = await findUserData();
    String id_user = data[0]['_id'].toString().toLowerCase();
    String jalur = data[0]['jalur'].toString().toLowerCase();

    Map<String, dynamic> waste = {
      'pengepul': id_user,
      'date': currentDate,
      'location': locationList,
      'recorded': false
    };
    print(waste);
    try {
      Response response =
          await http.post(Uri.parse('${API_URL}/waste/savelocation'), body: {
        'pengepul': id_user,
        'date': currentDate,
        'location': jsonEncode(locationList),
        'recorded': false.toString(),
        'jalur': jalur
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(response.body);
      } else {
        print(response.statusCode);
      }
      String bodyParse = jsonEncode(waste);
    } catch (e) {
      throw Exception(e);
    }
    setState(() {
      buttonDisabled = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getRecap();
    locationList = widget.location;
    locationList = matchListProdusen(widget.listProdusen, widget.location);
    listProdusen = widget.listProdusen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: Text('Rekap Pengambilan Sampah'),
      ),
      body: Container(
        // padding: EdgeInsets.all(10),
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Text(
                'Jumlah: ${locationList.length}',
                style: TextStyle(
                    fontSize: 13,
                    fontFamily: "Opensans",
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              // padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.green.shade100, width: 2),
                ),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,

                    child: DataTable(
                      columnSpacing: 20.0,
                      dataRowHeight: 100,
                      columns: [
                        DataColumn(label: Text('Jam')),
                        DataColumn(label: Text('Tanggal')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: listProdusen.map((e) {
                        int index = listProdusen.indexOf(e) + 1;
                        return DataRow(cells: [
                          // DataCell(Text(
                          //     "${DateFormat('HH:mm').format(DateTime.parse(e['time']))}")),
                          DataCell(Container(
                              constraints:
                                  BoxConstraints(maxWidth: 35, maxHeight: 200),
                              child: Text("${index}",
                                  overflow: TextOverflow.ellipsis))),
                          DataCell(Container(
                            constraints: BoxConstraints(maxWidth: 200),
                            child: Text(e['address'],
                                overflow: TextOverflow.ellipsis, maxLines: 10),
                          )),
                          DataCell(Container(
                              constraints:
                                  BoxConstraints(maxWidth: 50, maxHeight: 200),
                              child: Container(
                                  child: e['status'] == 1 ? Center(child: Icon(Icons.check)) : Center(child: Text("-"))
                                  // child: Text(e['status'] == 1 ? "Oke" : "Tidak",
                                  //     overflow: TextOverflow.fade)
                                      ))),
                          // DataCell(Text(
                          //     "${DateFormat('HH:mm').format(DateTime.parse(e['time']))}")),
                          // DataCell(Container(
                          //   constraints:
                          //       BoxConstraints(maxWidth: 150),
                          //   child: Text(e['produsen_info']['name'] != null ?
                          //     "${e['produsen_info']['address']}" : "Tidak Terdaftar",
                          //     overflow: TextOverflow.ellipsis,
                          //     maxLines: 10
                          //   ),
                          // )),
                          // DataCell(
                          //   Container(
                          //       constraints: BoxConstraints(
                          //           maxWidth: 50, maxHeight: 300),
                          //       child: Container(
                          //         child: e['produsen_info']['name'] != null
                          //           ? Text("${e['produsen_info']['name']}",
                          //               overflow: TextOverflow.fade)
                          //           : Text('-',
                          //               overflow: TextOverflow.ellipsis)),
                          //       )
                          // ),
                        ]);
                      }).toList(),
                    ),
                    // ),
                  ),
                ),
              ),
            ),
            Container(
              child: IconButton(
                iconSize: 100,
                icon: const Icon(
                  Icons.arrow_circle_right_outlined,
                ),
                onPressed: () async {
                  if (buttonDisabled == true) {
                    null;
                  } else {
                    await saveLocation();
                    location.clear();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return SubmitPage();
                        },
                      ),
                    );
                    // Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        ),
        // child: Table(
        //   border: TableBorder.all(color: Colors.black),
        //   columnWidths: {
        //     0: FixedColumnWidth(50.0),
        //     1: FlexColumnWidth(),
        //     2: FixedColumnWidth(50.0),
        //   },
        //   children: data.map((row) {
        //     return TableRow(
        //       children: row.map((cell) {
        //         return Text(cell);
        //       }).toList(),
        //     );
        //   }).toList(),
        // ),
      ),
    );
  }
}

class SubmitPage extends StatelessWidget {
  const SubmitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          'Selesai',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
            alignment: Alignment.center,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(80),
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(''),
            )),
      ],
    ));
  }
}
