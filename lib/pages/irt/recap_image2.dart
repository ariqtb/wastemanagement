import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:async/async.dart';

import '../../conn/conn_api.dart';
import 'upload_produsen.dart';
import '../../components/alert.dart';

class RecapImage extends StatefulWidget {
  final List<Map<String, dynamic>> photoList;
  final Map<String, dynamic> wasteData;
  const RecapImage(
      {super.key, required this.photoList, required this.wasteData});

  @override
  State<RecapImage> createState() => _RecapImageState();
}

class _RecapImageState extends State<RecapImage> {
  bool isLoading = false;
  Map<String, dynamic> wasteData = {};
  List<Map<String, dynamic>> photoList = [];

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
      wasteData = widget.wasteData;
      photoList = widget.photoList;
    });
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
          title: Text('Rekap Foto'),
        ),
        body: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: widget.photoList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final imageUrl = widget.photoList[index]['filename'];
                    final imageText = widget.photoList[index]['typePhoto'];
                    final weightText = widget.photoList[index]['weight'];

                    return GridTile(
                      child: ListView(
                        physics: ClampingScrollPhysics(),
                        // padding: EdgeInsets.fromLTRB(10,0,10,0),
                        // child: Stack(
                        children: [
                          Center(child: Text('${imageText}')),
                          Center(child: Text('${weightText} Kg')),
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            height: 150,
                            child: Image.file(imageUrl),
                          ),
                        ],
                        // ),
                      ),
                    );
                  },
                ),
              ),
              
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
          width: 120,
          height: 70,
          child: FloatingActionButton(
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              await uploadData(wasteData);
              setState(() {
                isLoading = false;
              });
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) {
                    return UploadProdusen();
                  },
                ),
              );
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
