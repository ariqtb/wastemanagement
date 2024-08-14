import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:namer_app/pages/petugas/recap_weight.dart';
import 'homepage.dart';
import 'package:http/http.dart' as http;
import '../../conn/conn_api.dart';

class GetDataWaste extends StatefulWidget {
  final String id;
  const GetDataWaste({super.key, required this.id});

  @override
  State<GetDataWaste> createState() => _GetDataWasteState();
}

class _GetDataWasteState extends State<GetDataWaste> {
  String id = '';
  List<dynamic> dataCache = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    id = widget.id;
  }

  Future getImageData() async {
    final response = await http.get(Uri.parse('${API_URL}/waste/getphotodata'));
    if (response.statusCode == 200) {
      if (mounted) {
        // if (json.decode(response.body)['cache'] != null) {
          setState(() {
            // isLoading = true;
            dataCache = json.decode(response.body);
            print(dataCache);
          });
        // }
      }
    } else {
      throw Exception("Failed to load data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kembali"),
      ),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Container(
                //   child: ElevatedButton(
                //     onPressed: () {
                //       Navigator.of(context).pop();
                //     },
                //     child: IntrinsicWidth(
                //       child: Row(
                //         children: [
                //           Icon(
                //             Icons.arrow_back_ios_new_rounded,
                //             size: 16,
                //             color: Colors.black,
                //           ),
                //           SizedBox(
                //             width: 10,
                //           ),
                //           Text(
                //             'Kembali',
                //             style: TextStyle(
                //               color: Colors.black,
                //               fontFamily: 'OpenSans',
                //             ),
                //           )
                //         ],
                //       ),
                //     ),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.white,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(30.0),
                //       ),
                //     ),
                //   ),
                // ),
                Container(),
                Column(children: [
                  Text(
                    'Tekan untuk ambil data',
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
                  SizedBox(
                    height: 35,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(80),
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () async {
                        await getImageData();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => RecapWeight(
                                    idWaste: id,
                                    dataCache: dataCache
                                  )),
                        );
                      },
                      child: Container(),
                    ),
                  )
                ]),
                Container()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
