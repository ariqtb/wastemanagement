import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:namer_app/pages/petugas/homepage.dart';
import 'package:namer_app/providers/imagePicker.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../conn/conn_api.dart';
// import 'upload_produsen.dart';
import '../../components/alert.dart';

class RecapWeight extends StatefulWidget {
  final String idWaste;
  final List<dynamic> dataCache;
  const RecapWeight({super.key, required this.idWaste, required this.dataCache});

  @override
  State<RecapWeight> createState() => _RecapWeightState();
}

class _RecapWeightState extends State<RecapWeight> {
  bool isLoading = false;
  String wasteid = '';
  Map<String, dynamic> wasteData = {};
  List<Map<String, dynamic>> photoList = [];
  List<dynamic> dataCache = [];
  bool upload_status = false;

  Future<void> getData() async {
    final response = await http.get(Uri.parse('${API_URL}/waste/imageupload'));
    if (response.statusCode == 200) {
      if (mounted) {
        if (json.decode(response.body)['cache'] != null) {
          setState(() {
            // isLoading = true;
            dataCache = json.decode(response.body)['cache'];
            print(dataCache);
          });
        }
      }
    } else {
      throw Exception("Failed to load data");
    }
  }

  Future<void> upload() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      setState(() {
        isLoading = true;
      });
      var response = await http.post(Uri.parse('${API_URL}/waste/recordupload'),
          // headers: {'Content-Type': 'application/json'},
          body: {'id': wasteid, 'image': json.encode(dataCache)});
      if (response.statusCode == 200) {
        setState(() {
          upload_status = true;
          isLoading = false;
          print(response.body);
        });
      } else {
        print(response.statusCode);
        print(response.body);
      }
    } catch (err) {
      throw Exception(err);
    }
  }

  Future<void> uploadData(Map<String, dynamic> datas) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('${API_URL}/produsen/save'));

    var i = 0;
    for (var fileInfo in photoList) {
      final file = fileInfo['filename'];
      var stream = http.ByteStream(DelegatingStream(file.openRead()));
      var length = await file.length();
      var multipartFile = http.MultipartFile('photo', stream, length,
          filename: basename(file.path));
      request.files.add(multipartFile);
      i++;
    }

    request.headers['Content-Type'] = 'application/json';
    List<dynamic> imageMap = [];

    for (var getInfo in photoList) {
      String filename = getInfo['filename'].path.split('/').last;
      imageMap.add({
        'typePhoto': getInfo['typePhoto'],
        'filename': filename,
        'weight': getInfo['weight']
      });
    }

    request.fields.addAll({
      'produsen_sampah': datas['produsen_sampah'],
      'date': datas['date'],
      'jalur': datas['jalur'],
      'location': jsonEncode(datas['location']),
      'image': jsonEncode(imageMap),
      'picked_up': datas['picked_up'].toString()
    });

    final response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Photos and data uploaded successfully ${response.statusCode}');
      // var responseString = (responseBytes);
      var responseBytes = await http.Response.fromStream(response);
      print(responseBytes.body);
    } else {
      print('Failed to upload photos and data: ${response.statusCode}');
      var responseBytes = await http.Response.fromStream(response);
      print(responseBytes.body);
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      wasteid = widget.idWaste;
      dataCache = widget.dataCache;
    });
    // getData();
  }

  @override
  Widget build(BuildContext context) {
    return
        // WillPopScope(
        //     onWillPop: () async {
        //       final pop = await confirmDialog(context, [
        //         ...['Konfirmasi', 'Apakah anda ingin membatalkan aksi?']
        //       ]);
        //       return pop ?? false;
        //     },
        //     child:
        Scaffold(
            appBar: AppBar(
              title: Text('Rekap Berat Sampah'),
            ),
            body: Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.fromLTRB(15, 20, 15, 50),
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
                    rows: dataCache.map((e) {
                      int index = dataCache.indexOf(e) + 1;
                      if (e['weight'] == null) {
                        e['weight'] = 0;
                      }
                      return DataRow(cells: [
                        DataCell(Center(child: Text("${index}"))),
                        DataCell(Center(child: Text("${e['typePhoto']}"))),
                        DataCell(Center(child: Text("${e['weight']} Kg"))),
                      ]);
                    }).toList(),
                  ),
                ))),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: SizedBox(
              width: 120,
              height: 70,
              child: FloatingActionButton(
                onPressed: () async {
                  // print(widget.photoList);
                  // await uploadImages(widget.idWaste, widget.photoList);
                  await upload();
                  if (upload_status) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) {
                          return SubmitPage();
                        },
                      ),
                    );
                  }
                },
                backgroundColor: Colors.green,
                child: isLoading
                    ? SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white)))
                    : Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
              ),
              // )
            ));
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
                  'Sampah sudah selesai dipilah, silakan kembali',
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                HomepagePetugas()),
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
