import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../../components/geolocator_produsen.dart';
import 'image_sorting.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String address = 'Mencari lokasi...';
  late String location;
  late String latitude;
  late String longitude;
  bool isLoading = false;
  bool isEmptyData = false;
  bool isParse = false;
  List<dynamic> data = [];
  String responseData = '';

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    //location service not enabled, don't continue
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location service Not Enabled');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission denied');
      }
    }
    //permission denied forever
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permission denied forever, we cannot access',
      );
    }
    //continue accessing the position of device
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> getAddressFromLongLat(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    // print(placemarks[0].country);
    Placemark place = placemarks[0];
    setState(() {
      address =
          '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    });
  }

  Future<bool?> confirmDialog(context) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Apakah sampah anda siap diambil?'),
            actions: [
              TextButton(
                  onPressed: () async {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (BuildContext context) {
                    //       return ImagePickerProdusen();
                    //     },
                    //   ),
                    // );
                    // Navigator.pop(context, true);
                  },
                  child: Text('Tidak')),
              TextButton(
                  onPressed: () async {
                    DateTime now = DateTime.now();
                    String currentDate = now.toString();

                    Position position = await _getGeoLocationPosition();
                    setState(() {
                      latitude = position.latitude.toString();
                      longitude = position.longitude.toString();
                      location = '${position.latitude}, ${position.longitude}';
                      getAddressFromLongLat(position);
                      addWaste(currentDate, latitude, longitude);
                      // addTrashStatus = !addTrashStatus;
                    });
                    await produsenPOST(currentDate);
                    await clear();
                    await refreshPage();
                    Navigator.pop(context);
                  },
                  child: Text('Ya')),
            ],
          ));

  showModal(context) {
    showModalBottomSheet(
      isDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200.0,
          color: Colors.white,
          child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Data sedang disimpan'),
              SizedBox(
                height: 20,
              ),
              CircularProgressIndicator()
            ]),
          ),
        );
      },
    );
  }

  Future<void> fetchData() async {
    var dataUser = await findUserData();
    String idUser = dataUser[0]['_id'].toString().toLowerCase();
    final response = await http.get(Uri.parse(
        'https://wastemanagement.tubagusariq.repl.co/produsen/${idUser}'));
    {
      if (response.statusCode == 200) {
        setState(() {
          isLoading = true;
          data = json.decode(response.body);
          if (data.length == 0) {
            isEmptyData = true;
          }
          // return print(data);
          data.sort((a, b) =>
              DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
        });
      } else {
        setState(() {
          isEmptyData = true;
        });
      }
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
    findUserData();
  }

  @override
  Widget build(BuildContext context) {
    Widget page;

    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: SizedBox(
            width: 110,
            height: 50,
            child: FloatingActionButton.extended(
              elevation: 0.0,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              label: Text('Tambah'),
              icon: Icon(Icons.add),
              onPressed: () async {
                await confirmDialog(context);
              },
            ),
          ),
          body: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(15),
            // decoration: BoxDecoration(color: Colors.green),
            child: !isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ElevatedButton(
                      //   onPressed: () async {
                      //     await fetchData();
                      //     print(isLoading);
                      //   },
                      //   child: Text('data'),
                      // ),
                      isEmptyData
                          ? Container(
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
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('Riwayat Data',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  height: 500.0,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    elevation: 1,
                                    child: ListView.builder(
                                        itemCount: data.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Container(
                                            padding:
                                                EdgeInsets.fromLTRB(8, 4, 8, 4),
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                              color: Colors.lightGreen[100],
                                              elevation: 2,
                                              child: Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    0, 5, 0, 5),
                                                padding: EdgeInsets.all(8),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "${DateFormat('EEE, dd MMMM yy').format(DateTime.parse(data[index]['date']))}",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                            "${DateFormat('HH:mm').format(DateTime.parse(data[index]['date']))}"),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                ),
                                isParse ? Container() : Container(),
                              ],
                            )
                    ],
                  ),
          ),
        ));
  }
}
