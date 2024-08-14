import 'package:flutter/material.dart';
import 'dart:convert';
import '../../conn/conn_api.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'detail_history.dart';
import '../../utils/user_data_login.dart';
import 'package:intl/intl.dart';
import '../../providers/waste_class.dart';
import '../image_sorting.dart';

class HistoryPage extends StatefulWidget {
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  bool get wantKeepAlive => true;

  List<dynamic> data = [];
  dynamic _selectedData;

  bool isLoading = false;
  bool isEmptyData = false;
  String date = "";
  String time = "";
  String dateParse = "";
  String idDetail = "";
  dynamic history;
  bool buttonDisabled = false;
  DateFormat formattedDate = new DateFormat();
  DateFormat formattedTime = new DateFormat();

  @override
  void initState() {
    super.initState();
    fetchData();

  // FORMATTING TANGGAL MENJADI INDONESIA
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

// FETCHING DATA
  Future<void> fetchData() async {
    var dataUser = await findUserData();
    String idUser = dataUser[0]['_id'].toString().toLowerCase();
    print(dataUser);
    final response = await http.get(Uri.parse('${API_URL}/waste/recorded'));
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          isLoading = true;
          data = json.decode(response.body);
          print(data);
          if (data.length == 0) {
            isEmptyData = true;
          }
          data.sort((a, b) =>
              DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
        });
      }
    } else {
      throw Exception("Failed to load data");
    }
  }

  void onDetailClicked(dynamic history) {
    if (mounted) {
      setState(() {
        _selectedData = history;
      });
    }
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
            child: Text(
              "Daftar riwayat sampah",
              style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          !isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ['data'].isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                onTap: () {
                                  print("${data[index]}");
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
                                  child:
                                      Text('${data[index]['location'].length}'),
                                  // backgroundColor: data[index]['picked_up']
                                  //     ? Colors.green[300]
                                  //     : Colors.amber[300],
                                ),
                                // data[index]['picked_up'] ? Text(
                                //     'Sudah Diambil') : Text('Belum Diambil'),
                                title: Text(
                                    '${data[index]['pengepulName']}'),
                                // subtitle: Text("Kode Jalur: ${data[index]['jalur']}"),
                                subtitle: Text(
                                    '${formattedDate.format(DateTime.parse(data[index]['date']))}'),
                                trailing: Text(
                                    '${formattedTime.format(DateTime.parse(data[index]['date']))}'),
                                // title: Text('${DateFormat('EEE, dd MM yy, HH:mm').format(DateTime.parse(data[index]['date']))}'),
                              ),
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
