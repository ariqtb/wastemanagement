import 'package:flutter/material.dart';
import 'package:namer_app/components/add_image.dart';
// import 'package:namer_app/components/image.dart';
import '../../conn/conn_api.dart';
import '../../components/geolocator.dart';
import '../detail_history_pickup.dart';
import '../image_sorting.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../components/alert.dart';

class HomepagePetugas extends StatefulWidget {
  const HomepagePetugas({Key? key}) : super(key: key);

  @override
  State<HomepagePetugas> createState() => _HomepagePetugasState();
}

class _HomepagePetugasState extends State<HomepagePetugas> {
  var selectedIndex = 0;
  bool isLoading = false;
  bool isEmptyData = false;
  bool buttonDisabled = false;
  List<dynamic> data = [];
  List<dynamic> data2 = [1, 4, 3, 1, 1, 2, 2];

  Future<void> fetchData() async {
    // var dataUser = await findUserData();
    // print(dataUser);
    final response = await http.get(Uri.parse('${API_URL}/waste/unrecorded'));
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

  Future<void> refreshPage() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      fetchData();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final List<PopupMenuEntry<String>> menuItems = [
      PopupMenuItem<String>(
        value: 'Keluar',
        child: Container(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: [
                Icon(Icons.logout_rounded),
                SizedBox(width: 5),
                Text(
                  'Keluar',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    ];
    return WillPopScope(
        onWillPop: () async {
          final pop = await confirmDialog(context, [
            ...['Konfirmasi', 'Apakah anda ingin keluar?']
          ]);
          return pop ?? false;
        },
        child: Scaffold(
          body: DecoratedBox(
            position: DecorationPosition.background,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.white, Colors.green.shade50],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)),
            child: Container(
                child: Container(
              // alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(15, 30, 15, 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PopupMenuButton<String>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    offset: Offset(45, 5),
                    itemBuilder: (BuildContext context) => menuItems,
                    onSelected: (String selectedItem) async {
                      if (selectedItem == 'Keluar') {
                        // print('Selected itessm: $selectedItem');
                        // Navigator.of(context).pop();
                        final pop = await exitDialog(context, [
                          ...['Konfirmasi', 'Apakah anda ingin keluar']
                        ]);
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                    child: Text(
                      "Daftar sampah untuk difoto",
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'OpenSans',
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 20),
                    child: Text(
                      "Klik untuk foto dan itung berat pemilahan sampah",
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'OpenSans',
                        // fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          // print(data);
                          if (!buttonDisabled) {
                            setState(() {
                              isLoading = false;
                              buttonDisabled = true;
                            });
                            await fetchData();
                            setState(() {
                              isLoading = true;
                              buttonDisabled = false;
                            });
                          }
                        },
                        child: Text('Muat Ulang'),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  !isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : data.isNotEmpty
                          ? Expanded(
                              child: Container(
                                margin: EdgeInsets.fromLTRB(5, 10, 5, 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                      color: Colors.green.shade100, width: 2),
                                ),
                                child: Scrollbar(
                                  child: ListView.builder(
                                    itemCount: data.length,
                                    itemBuilder: (context, index) {
                                      return Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: ListTile(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  print(data[index]['_id']);
                                                  return AddImage(
                                                      idWaste: data[index]
                                                          ['_id']);
                                                },
                                              ),
                                            );
                                          },
                                          leading: CircleAvatar(
                                            child: Container(),
                                          ),
                                          // title: data[index]['date'] == null || Text('${data[index]['pengepul']}'),
                                          title:
                                              Text(data[index]['pengepulName']),
                                          subtitle: DateTime.tryParse(
                                                      data[index]['date']) ==
                                                  null
                                              ? Text('Data tidak valid')
                                              : Text(
                                                  '${DateFormat('EEEE, dd MMMM yy').format(DateTime.parse(data[index]['date']))} - ${DateFormat('HH.mm').format(DateTime.parse(data[index]['date']))}'),
                                          trailing: Icon(Icons.arrow_forward),
                                          // title: Text('${DateFormat('EEE, dd MM yy, HH:mm').format(DateTime.parse(data[index]['date']))}'),
                                        ),
                                      );
                                    },
                                  ),
                                ),
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
                ],
              ),
            )),
          ),
        ));
  }
}
