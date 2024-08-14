import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../conn/conn_api.dart';
import 'handler/produsen.handler.dart';
import 'home.dart';
import '../../components/alert.dart';

class RecapSort extends StatefulWidget {
  final photoList;
  const RecapSort({super.key, required this.photoList});

  @override
  State<RecapSort> createState() => _RecapSortState();
}

class _RecapSortState extends State<RecapSort> {
  List<Map<String, dynamic>> photoList = [];
  Map<String, dynamic> wasteData = {};
  bool isLoading = false;

  Future<void> uploadFormRequest(wasteData) async {
    List<Map<String, dynamic>> photoListCopy = photoList;

    Map<String, dynamic> wasteData = await addLocation();
    wasteData['image'] = photoListCopy;

    var request =
        http.MultipartRequest('POST', Uri.parse('${API_URL}/produsen/save2'));

    request.fields.addAll({
      'produsen_sampah': wasteData['produsen_sampah'],
      'date': wasteData['date'],
      'jalur': wasteData['jalur'],
      'location': jsonEncode(wasteData['location']),
      'image': jsonEncode(wasteData['image']),
      'picked_up': wasteData['picked_up'].toString()
    });

    final response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Photos and data uploaded successfully ${response.statusCode}');
      var responseBytes = await http.Response.fromStream(response);
      print(responseBytes.body);
    } else {
      print('Failed to upload photos and data: ${response.statusCode}');
      var responseBytes = await http.Response.fromStream(response);
      print(responseBytes.body);
    }
    
    photoList.removeWhere((item) => item['status'] == 0);
    photoList = photoList.map((item) {
      item.remove('status');
      return item;
    }).toList();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    photoList = widget.photoList;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final pop = await confirmDialog(context, [
          ...['Konfirmasi', 'Apakah anda ingin membatalkan aksi?']
        ]);
        return pop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Rekap Pemilahan Sampah'),
        ),
        body: Container(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Container(
              //   alignment: Alignment.center,
              //   margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              //   child: Text(
              //     'Rekap Pemilahan Sampah',
              //     style: TextStyle(
              //         fontSize: 13,
              //         fontFamily: "Opensans",
              //         fontWeight: FontWeight.bold),
              //   ),
              // ),
              Expanded(
                // padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                // child: Container(
                // alignment: Alignment.center,
                // padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                // margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(10.0),
                //   border:
                //       Border.all(color: Colors.green.shade100, width: 2),
                // ),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      // columnSpacing: 30.0,
                      dataRowMaxHeight: 80,
                      columns: [
                        DataColumn(
                            label: Text('No.', style: TextStyle(fontSize: 16))),
                        DataColumn(
                            label: Text('Jenis Sampah',
                                style: TextStyle(fontSize: 16))),
                        DataColumn(
                            label:
                                Text('Status', style: TextStyle(fontSize: 16))),
                      ],
                      rows: photoList.map((e) {
                        int index = photoList.indexOf(e) + 1;
                        int index2 = photoList.indexOf(e);
                        return DataRow(
                          cells: [
                            DataCell(GestureDetector(
                              child: Container(
                                  constraints: BoxConstraints(
                                      maxWidth: 35, maxHeight: 200),
                                  child: Text("${index}",
                                      style: TextStyle(fontSize: 16),
                                      overflow: TextOverflow.ellipsis)),
                            )),
                            DataCell(Container(
                              constraints: BoxConstraints(maxWidth: 200),
                              child: Text(e['typePhoto'],
                                  style: TextStyle(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 10),
                            )),
                            DataCell(Container(
                                constraints: BoxConstraints(
                                    maxWidth: 50, maxHeight: 200),
                                child: Container(
                                    child: e['status'] == 1
                                        ? Center(child: Icon(Icons.check))
                                        : Center(child: Text("-"))
                                    // child: Text(e['status'] == 1 ? "Oke" : "Tidak",
                                    //     overflow: TextOverflow.fade)
                                    ))),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // ),
                // ),
              ),
              isLoading
                  ? Center(
                      child: Container(
                        height: 40,
                        width: 40,
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Container(
                      child: IconButton(
                        iconSize: 100,
                        icon: Icon(
                          Icons.arrow_circle_right_outlined,
                        ),
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          await uploadFormRequest(wasteData);
                          final prefs = await SharedPreferences.getInstance();
                          prefs.remove('produsen-sort-page');
                          prefs.remove('produsen-sort-data');
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) {
                                return SubmitPage();
                              },
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class SubmitPage extends StatelessWidget {
  const SubmitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        position: DecorationPosition.background,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.white, Colors.green.shade200],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)),
        child: Center(
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 50, 20, 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Selesai',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.green,
                      fontFamily: 'OpenSans',
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Sampah kamu sudah siap dan menunggu diambil petugas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'OpenSans',
                      fontSize: 14),
                ),
                SizedBox(
                  height: 35,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) {
                            return HomeIrt();
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Text(
                      'Kembali',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
