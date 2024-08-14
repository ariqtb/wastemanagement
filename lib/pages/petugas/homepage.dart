import 'package:flutter/material.dart';
import 'package:namer_app/pages/petugas/get_data_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:namer_app/components/add_image.dart';
import 'package:namer_app/pages/petugas/add_unregistered_user.dart';
import '../../conn/conn_api.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../components/alert.dart';
import 'history_page.dart';
import '../change_password.dart';
import 'method_check.dart';

class HomepagePetugas extends StatefulWidget {
  const HomepagePetugas({super.key});

  @override
  State<HomepagePetugas> createState() => _HomepagePetugasState();
}

class _HomepagePetugasState extends State<HomepagePetugas> {
  int currentIndex = 0;
  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        children: [
          HomePetugas(),
          Page2(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
            pageController.animateToPage(index,
                duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Daftar Terima Sampah'),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera), label: 'Daftar Foto Sampah'),
        ],
      ),
    );
  }
}

class HomePetugas extends StatefulWidget {
  const HomePetugas({Key? key}) : super(key: key);

  @override
  State<HomePetugas> createState() => _HomePetugasState();
}

class _HomePetugasState extends State<HomePetugas> {
  var selectedIndex = 0;
  bool isLoading = false;
  bool isEmptyData = false;
  bool buttonDisabled = false;
  List<dynamic> data = [];
  List<dynamic> data2 = [1, 4, 3, 1, 1, 2, 2];
  DateFormat formattedDate = new DateFormat();
  DateFormat formattedTime = new DateFormat();

  // FETCH DATA
  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('${API_URL}/waste/notaccept'));
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
      setState(() {
        isLoading = true;
      });
      // throw Exception("Failed to load data");
    }
  }

  Future<void> acceptedWaste(id) async {
    final response = await http
        .post(Uri.parse('${API_URL}/waste/accepted'), body: {'id': id});
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          isLoading = true;
          data = json.decode(response.body);
          // print("UNACCEPTED");
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

  @override
  Widget build(BuildContext context) {
    final List<PopupMenuEntry<String>> menuItems = [
      PopupMenuItem<String>(
        value: 'Ubahpassword',
        child: Container(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: [
                Icon(Icons.password_outlined),
                SizedBox(width: 5),
                Text(
                  'Ubah Password',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
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
                        final pop = await exitDialog(context, [
                          ...['Konfirmasi', 'Apakah anda ingin keluar']
                        ]);
                      } else {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return ChangePassword();
                        }));
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                    child: Text(
                      "Daftar penerimaan sampah",
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'OpenSans',
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 20),
                    child: Text(
                      "Klik untuk menerima sampah",
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'OpenSans',
                        // fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  // Row(
                  //   children: [
                  //     ElevatedButton(
                  //       onPressed: () async {
                  //         Navigator.of(context).push(
                  //           MaterialPageRoute(
                  //             builder: (context) {
                  //               return HistoryPage();
                  //             },
                  //           ),
                  //         );
                  //       },
                  //       child: Row(
                  //         children: [
                  //           Icon(Icons.history_rounded),
                  //           SizedBox(width: 5),
                  //           Text('Riwayat'),
                  //         ],
                  //       ),
                  //       style: ButtonStyle(
                  //         shape: MaterialStateProperty.all(
                  //           RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(20),
                  //           ),
                  //         ),
                  //       ),
                  //     )
                  //   ],
                  // ),
                  !isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : data.isNotEmpty
                          ? Expanded(
                              child: Container(
                                margin: EdgeInsets.fromLTRB(5, 10, 5, 40),
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
                                              return SubmitPage(
                                                  idWaste: data[index]['_id']);
                                            }));
                                            // Navigator.of(context).push(
                                            //   MaterialPageRoute(
                                            //     builder: (context) {
                                            //       print(data[index]['_id']);
                                            //       return AddImage(
                                            //           idWaste: data[index]
                                            //               ['_id']);
                                            //     },
                                            //   ),
                                            // );
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
                                                  '${formattedDate.format(DateTime.parse(data[index]['date']))} - ${formattedTime.format(DateTime.parse(data[index]['date']))}'),
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
                                  child: Text('Tidak ada data'),
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

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  var selectedIndex = 0;
  bool isLoading = false;
  bool isEmptyData = false;
  bool buttonDisabled = false;
  List<dynamic> data = [];
  List<dynamic> data2 = [1, 4, 3, 1, 1, 2, 2];
  DateFormat formattedDate = new DateFormat();
  DateFormat formattedTime = new DateFormat();

  // FETCH DATA
  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('${API_URL}/waste/accepted'));
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

  @override
  Widget build(BuildContext context) {
    final List<PopupMenuEntry<String>> menuItems = [
      PopupMenuItem<String>(
        value: 'Ubahpassword',
        child: Container(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: [
                Icon(Icons.password_outlined),
                SizedBox(width: 5),
                Text(
                  'Ubah Password',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
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
                        final pop = await exitDialog(context, [
                          ...['Konfirmasi', 'Apakah anda ingin keluar']
                        ]);
                      } else {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return ChangePassword();
                        }));
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
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return HistoryPage();
                              },
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Icon(Icons.history_rounded),
                            SizedBox(width: 5),
                            Text('Riwayat'),
                          ],
                        ),
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
                                margin: EdgeInsets.fromLTRB(5, 10, 5, 40),
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
                                            // Navigator.of(context).push(
                                            //     MaterialPageRoute(
                                            //         builder: (context) {
                                            //   return SubmitPage(
                                            //     idWaste: data[index]['_id'],
                                            //   );
                                            // }));
                                            // Navigator.of(context).push(
                                            //   MaterialPageRoute(
                                            //     builder: (context) {
                                            //       print(data[index]['_id']);
                                            //       return GetDataWaste(id:data[index]['_id']);
                                            //       // return AddImage(
                                            //       //     idWaste: data[index]
                                            //       //         ['_id']);
                                            //     },
                                            //   ),
                                            // );
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  print(data[index]['_id']);
                                                  return MethodCheck(id:data[index]['_id']);
                                                  // return AddImage(
                                                  //     idWaste: data[index]
                                                  //         ['_id']);
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
                                                  '${formattedDate.format(DateTime.parse(data[index]['date']))} - ${formattedTime.format(DateTime.parse(data[index]['date']))}'),
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

class SubmitPage extends StatelessWidget {
  final String idWaste;
  const SubmitPage({super.key, required this.idWaste});

  Future<void> acceptedWaste(id) async {
    final response = await http
        .post(Uri.parse('${API_URL}/waste/accepted'), body: {'id': id});
    if (response.statusCode == 200) {
      print("OKE: ${response.body}");
    } else {
      throw Exception("Failed to load data");
    }
  }

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
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(80),
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () async {
                      await acceptedWaste(idWaste);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                HomepagePetugas()),
                      );
                    },
                    child: Container(),
                    // style: ElevatedButton.styleFrom(
                    //   backgroundColor: Colors.green,
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(30.0),
                    //   ),
                    // ),
                    // child: ElevatedButton(
                    //   style: ElevatedButton.styleFrom(
                    //     shape: CircleBorder(),
                    //     padding: EdgeInsets.all(80),
                    //     backgroundColor: Colors.redAccent,
                    //   ),
                    //   onPressed: (){ },
                    //   child: Text(''),
                    // ),
                    // child: Text(
                    //   'Kembali',
                    //   style: TextStyle(
                    //     color: Colors.white,
                    //     fontFamily: 'OpenSans',
                    //   ),
                    // ),
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
