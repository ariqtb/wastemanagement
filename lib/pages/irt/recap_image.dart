import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:async/async.dart';

import '../../conn/conn_api.dart';
import 'upload_produsen.dart';
import '../../components/alert.dart';
import 'recap_weight.dart';

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
                          Container(
                            margin: EdgeInsets.fromLTRB(30, 5, 30, 0),
                            height: 160,
                            child: Image.file(
                              imageUrl,
                              fit: BoxFit.cover,
                             
                            ),
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
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return RecapWeight(
                      photoList: photoList,
                      wasteData: wasteData,
                    );
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
