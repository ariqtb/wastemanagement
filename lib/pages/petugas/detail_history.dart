import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../utils/user_data_login.dart';
import '../../conn/conn_api.dart';

class DetailHistoryPickup extends StatefulWidget {
  final dynamic history;

  DetailHistoryPickup({super.key, this.history});

  @override
  State<DetailHistoryPickup> createState() => _DetailHistoryPickupState();
}

class _DetailHistoryPickupState extends State<DetailHistoryPickup> {
  List<dynamic> data = [];

  List<dynamic> imageList = [];

  bool buttonDisabled = false;
  DateFormat formattedDate = new DateFormat();
  DateFormat formattedTime = new DateFormat();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeDateFormatting('id', null).then((_) {
      DateTime dateTime = DateTime.now();
      final idLocale = 'id';
      final dateFormat = DateFormat.yMMMMEEEEd(idLocale);
      final timeFormat = DateFormat.Hm(idLocale);
      formattedDate = dateFormat;
      formattedTime = timeFormat;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(history);

    final List<dynamic> imageFilenames = widget.history['image'];
    print(imageFilenames);

    List<Map<String, dynamic>> location =
        widget.history['image'].cast<Map<String, dynamic>>();
    print(location.runtimeType);
    List<DataRow> dataRows = location.map((row) {
      String typePhoto = row['typePhoto'];
      double weight = row['weight'].toDouble();
      int index = location.indexOf(row) + 1;
      return DataRow(cells: [
        DataCell(Center(child: Text('${index}'))),
        DataCell(Center(child: Text('${typePhoto}'))),
        DataCell(Center(child: Text('${weight}'))),
      ]);
    }).toList();

    imageList = widget.history['image'];
    print(widget.history);

    return Scaffold(
      body:
          // DecoratedBox(
          //   position: DecorationPosition.background,
          //   decoration: BoxDecoration(
          //       gradient: LinearGradient(colors: [
          //     Colors.white,
          //     // history['picked_up'] ? Colors.green.shade50 : Colors.amber.shade50
          //   ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          //   child:
          Container(
        padding: EdgeInsets.all(20),
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: ElevatedButton(
                onPressed: () {
                  if (!buttonDisabled) {
                    Navigator.of(context).pop();
                  }
                },
                child: IntrinsicWidth(
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Kembali',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'OpenSans',
                        ),
                      )
                    ],
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                      child: Text(
                        "Detail",
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'OpenSans',
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      child: Text(
                        "${formattedDate.format(DateTime.parse(widget.history['date']))}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.green),
                      ),
                    ),
                    Container(
                      child: Text(
                        "${DateFormat('HH.mm').format(DateTime.parse(widget.history['date']))}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.green),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Text("Status: "),
                    ),
                    Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: widget.history['recorded']
                              ? Colors.green[300]
                              : Colors.amber[300],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          widget.history['recorded']
                              ? "Terdata"
                              : "Belum Terdata",

                          //  "Sukses Diambil",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ],
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: Text("Pemilahan Sampah: "),
            ),
            Expanded(
              child: Container(
                  alignment: Alignment.topCenter,
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.green.shade100, width: 2),
                  ),
                  child: Scrollbar(
                      child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                        columnSpacing: 35.0,
                        columns: [
                          DataColumn(label: Text('No.')),
                          DataColumn(label: Text('Jenis Sampah')),
                          DataColumn(label: Text('Berat Sampah')),
                        ],
                        rows: dataRows),
                  ))),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Text("Foto Sampah: "),
            ),
            Expanded(
              child: Container(
                child: Row(
                  children: imageFilenames.map((image) {
                    int index = imageFilenames.indexOf(image);
                    final imageUrl =
                        "${API_URL}/images/${imageFilenames[index]['filename']}";
                    return Expanded(
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.green.shade100, width: 2),
                            ),
                            margin: EdgeInsets.fromLTRB(5, 5, 5, 0),
                            height: 110,
                            width: 75,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Text(
                            '${imageFilenames[index]['typePhoto']}',
                            style: TextStyle(fontFamily: "Opensans", fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      // ),
    );
  }
}

// Container(
//                       height: 50,
//                       child: ListView.builder(
//                         itemCount: 1,
//                         itemBuilder: (BuildContext context, int index) {
//                           // var location = history['location'][index];
//                           // var item = history[index];
//                           return ListTile(
//                             title: Text("123"),
//                             subtitle: Text("456"),
//                           );
//                         },
//                       ),
//                     )

// class DetailHistoryPickup extends StatelessWidget {
//   DetailHistoryPickup({super.key, required this.idDetail});

//   final String idDetail;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Detail Riwayat'),
//       ),
//       body: Center(child: Text(idDetail)),
//     );
//   }
// }
