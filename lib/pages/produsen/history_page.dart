import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
// import 'package:namer_app/components/geolocator.dart';
import 'package:namer_app/providers/get_user.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:namer_app/conn/conn_api.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'detail_history.dart';
import '../../components/add_image.dart';

class HistoryProdusen extends StatefulWidget {
  const HistoryProdusen({super.key});

  @override
  State<HistoryProdusen> createState() => _HistoryProdusenState();
}

class _HistoryProdusenState extends State<HistoryProdusen> {
  bool isLoading = false;
  bool isEmptyData = false;
  bool isPageLoading = false;

  List<dynamic> data = [];
  List<dynamic> userdata = [];
  bool status = false;

  DateFormat formattedDate = new DateFormat();
  DateFormat formattedTime = new DateFormat();

  Future<void> fetchData() async {
    var dataUser = await findUserData();
    // return print(dataUser);
    var idUser = dataUser[0]['_id'].toString().toLowerCase();
    final response =
        await http.get(Uri.parse('${API_URL}/produsen/history/${idUser}'));
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          isLoading = true;
          data = jsonDecode(response.body);
          userdata = dataUser;
          if (data.length == 0) {
            isEmptyData = true;
          }
          data.sort((a, b) =>
              DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
        });
        // isLoading = false;
      }
      print(data);
      print(userdata);
    } else {
      print('error: ${response.statusCode}');
    }
  }

  sortData(bool status) {
    setState(() {
      data.where((item) => item['picked_up'] == status).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    // sortData(false);

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

  Future<void> refreshData() async {
    // Perform your refresh logic here
    fetchData();
    // Simulate a delay to show the refreshing indicator
    await Future.delayed(Duration(seconds: 2));

    // Set the state to complete the refresh
    setState(() {
      // Update your data here or call a function to fetch new data
    });
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      position: DecorationPosition.background,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.white, Colors.green.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),
      child: Container(
        padding: EdgeInsets.all(20),
        alignment: Alignment.topLeft,
        // child: RefreshIndicator(
        //   onRefresh: refreshData,
        //   child: SingleChildScrollView(
        //     physics: AlwaysScrollableScrollPhysics(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 50, 0, 5),
            child: Text(
              "Daftar riwayat sampah",
              style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.bold),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
          //   child: Text(
          //     "",
          //     // "Klik untuk foto dan itung berat pemilahan sampah",
          //     style: TextStyle(
          //       fontSize: 12,
          //       fontFamily: 'OpenSans',
          //     ),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
          //   child: isLoading
          //       ? Text(
          //           "Jalur: ${userdata[0]['jalur']}",
          //           style: TextStyle(
          //             fontSize: 12,
          //             fontFamily: 'OpenSans',
          //           ),
          //         )
          //       : null,
          // ),
          // Row(
          //   children: [
          //     Container(
          //       margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
          //       child: ElevatedButton(
          //           style: ButtonStyle(
          //               backgroundColor:
          //                   MaterialStateProperty.all(Colors.amber[400]),
          //               shape: MaterialStateProperty.all(RoundedRectangleBorder(
          //                   borderRadius: BorderRadius.circular(20)))),
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //             children: [
          //               Icon(Icons.wifi_protected_setup_sharp),
          //               Text("Proses")
          //             ],
          //           ),
          //           onPressed: () {
          //             sortData(false);
          //             print(data);
          //           }),
          //     ),
          //     ElevatedButton(
          //         style: ButtonStyle(
          //             backgroundColor:
          //                 MaterialStateProperty.all(Colors.green[400]),
          //             shape: MaterialStateProperty.all(RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(20)))),
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //           children: [Icon(Icons.done), Text("Selesai")],
          //         ),
          //         onPressed: () {
          //           sortData(true);
          //           print(data);
          //         })
          //   ],
          // ),
          !isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ['data'].isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return DetailHistoryPickup(
                                        history: data[index],
                                      );
                                    },
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                child: Text(''),
                                backgroundColor: data[index]['picked_up']
                                    ? Colors.green[300]
                                    : Colors.amber[300],
                              ),
                              // data[index]['picked_up'] ? Text(
                              //     'Sudah Diambil') : Text('Belum Diambil'),
                              title: Text(
                                  '${formattedDate.format(DateTime.parse(data[index]['date']))}'),
                              // subtitle: Text("Kode Jalur: ${data[index]['jalur']}"),
                              subtitle: data[index]['image'] == null ||
                                      data[index]['image'].length == 0
                                  ? Text("Dipilah: Tidak")
                                  : Text("Dipilah: Ya "),
                              trailing: Text(
                                  '${formattedTime.format(DateTime.parse(data[index]['date']))}'),
                              // title: Text('${DateFormat('EEE, dd MM yy, HH:mm').format(DateTime.parse(data[index]['date']))}'),
                            ),
                          );
                        },
                      ),
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
        ]),
      ),
      //   ),
      // ),
    );
  }
}
