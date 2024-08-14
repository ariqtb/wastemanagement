import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:namer_app/components/geolocator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:namer_app/conn/conn_api.dart';
import 'package:namer_app/pages/distributor/add_location.dart';
import '../../providers/get_user.dart';
import 'getWaste.dart';

class RecapLocationToSave extends StatefulWidget {
  final List<Map<String, dynamic>> location;
  final List<Map<String, dynamic>> listProdusen;

  const RecapLocationToSave(
      {super.key, required this.location, required this.listProdusen});

  @override
  State<RecapLocationToSave> createState() => _RecapLocationToSaveState();
}

class _RecapLocationToSaveState extends State<RecapLocationToSave> {
  Map<String, dynamic>? datas;
  List<Map<String, dynamic>>? wasteData;
  List<Map<String, dynamic>> locationList = [];
  List<Map<String, dynamic>> filteredLocation = [];
  List<Map<String, dynamic>> listProdusen = [];
  late String currentDate;
  bool buttonDisabled = false;

  matchListProdusen(listProdusen, location) {
    List<Map<String, dynamic>> filteredLocation =
        location.where((item) => item['produsen_info']['status'] == 1).toList();

    print("LOCATION: ${filteredLocation}");
    filteredLocation.forEach((element) {
      return print("INI FILTERED: ${element['produsen_info']['status']}");
    });

    List<Map<String, dynamic>> loc = filteredLocation.where((map1) {
      return listProdusen.any((map2) =>
          map2['id_waste_produsen'] ==
          map1['produsen_info']['id_waste_produsen']);
    }).toList();
    // loc.forEach((map1) => print("INI MECING MAP: ${map1['produsen_info']['status']}"));

    listProdusen.forEach((map1) {
      var id = map1['id_waste_produsen'];
      // var matchingMap = filteredLocation.where((map2) => map2['produsen_info']['id_waste_produsen'] == id && map2['produsen_info']['status'] == 1,);
      var matchingMap = filteredLocation.firstWhere(
        (map2) => map2['produsen_info']['id_waste_produsen'] == id,
        orElse: () => {},
      );
      map1['status'] = matchingMap['produsen_info'] == null ? 0 : 1;
      // print("INI MECING MAP: ${map1}");
    });

    return listProdusen;
  }

  Future sortLocationProximity(listProdusen) async {
    Position position = await getGeoLocationPosition();
    double mylatitude;
    double mylongitude;

    mylatitude = position.latitude;
    mylongitude = position.longitude;

    double radians(double degrees) {
      return degrees * (pi / 180);
    }

    double calculateDistance(
        double lat1, double lon1, double lat2, double lon2) {
      const double earthRadius = 6371.0; // Earth's radius in kilometers

      final double dLat = radians(lat2 - lat1);
      final double dLon = radians(lon2 - lon1);

      final double a = sin(dLat / 2) * sin(dLat / 2) +
          cos(radians(lat1)) *
              cos(radians(lat2)) *
              sin(dLon / 2) *
              sin(dLon / 2);

      final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

      return earthRadius * c; // Distance in kilometers
    }

    listProdusen.sort((a, b) {
      final double distancetoA =
          calculateDistance(mylatitude, mylongitude, double.tryParse(a['lat'])!, double.tryParse(a['long'])!);
      final double distancetoB =
          calculateDistance(mylatitude, mylongitude, double.tryParse(b['lat'])!, double.tryParse(b['long'])!);

      return distancetoA.compareTo(distancetoB);
    });
  }

  Future<void> saveLocation() async {
    setState(() {
      buttonDisabled = true;
    });
    DateTime now = DateTime.now();
    currentDate = now.toString();
    List<dynamic> data = await findUserData();
    String id_user = data[0]['_id'].toString().toLowerCase();
    String jalur = data[0]['jalur'].toString().toLowerCase();

    Map<String, dynamic> waste = {
      'pengepul': id_user,
      'date': currentDate,
      'location': locationList,
      'recorded': false,
      'accepted': false
    };
    print("WASTENIH: ${waste}");
    try {
      Response response =
          await http.post(Uri.parse('${API_URL}/waste/savelocation'), body: {
        'pengepul': id_user,
        'date': currentDate,
        'location': jsonEncode(locationList),
        'recorded': false.toString(),
        'jalur': jalur
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(response.body);
      } else {
        print(response.statusCode);
      }
      String bodyParse = jsonEncode(waste);
    } catch (e) {
      throw Exception(e);
    }
    setState(() {
      buttonDisabled = false;
    });
  }

  bool isLoading = true;

  final Set<Marker> _markers = Set<Marker>();
  late GoogleMapController _mapController;
  LatLng? _currentPosition;
  double zoom = 15;
  Set<Circle> circles = {};

  Future getLiveLocation() async {
    Position livePosition = await getGeoLocationPosition();
    setState(() {
      _currentPosition = LatLng(livePosition.latitude, livePosition.longitude);
    });
    print("OYY: ${_currentPosition}");
  }

  void _createMarkers() {
    var index = 0;
    for (var data in listProdusen) {
      final markerId = MarkerId(index.toString());
      final latLng =
          LatLng(double.parse(data['lat']), double.parse(data['long']));

      _markers.add(
        Marker(
            markerId: markerId,
            position: latLng,
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
              title: data['name'],
              snippet: data['address'],
            )
            // Add more properties like icon, info window, etc. if needed
            ),
      );
      index++;
    }

    // return markers;
  }

  void _updateCameraPosition(index) {
    LatLng position = LatLng(double.parse(listProdusen[index]['lat']),
        double.parse(listProdusen[index]['long']));
    setState(() {
      _currentPosition = position;
      zoom = 18;
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(position, zoom),
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getRecap();
    locationList = widget.location;
    listProdusen = widget.listProdusen;
    listProdusen = matchListProdusen(widget.listProdusen, widget.location);
    print("LOCATIONLISTT: ${locationList}");
    sortLocationProximity(listProdusen);
    // if(listProdusen.length != 0){
    // _currentPosition = LatLng(double.parse(listProdusen[0]['lat']),
    //     double.parse(listProdusen[0]['long']));
    // }
    _createMarkers();
    getLiveLocation();
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(), // Display a loading indicator
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text('Rekap Pengambilan Sampah'),
            ),
            body: Container(
              alignment: Alignment.topCenter,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 200,
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                        setState(() {
                          circles.add(
                            Circle(
                              circleId:
                                  CircleId('circleId'), // Unique circle id
                              center: _currentPosition!, // Center of the circle
                              radius: 50, // Radius in meters
                              strokeWidth: 2,
                              strokeColor: Colors.blue,
                              fillColor: Colors.blue.withOpacity(0.1),
                            ),
                          );
                        });
                      },
                      circles: circles,
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition!,
                        zoom: zoom,
                      ),
                      myLocationEnabled: true,
                      compassEnabled: true,
                      markers: _markers, // Create markers for locations
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Text(
                      'Jumlah: ${locationList.length}',
                      style: TextStyle(
                          fontSize: 13,
                          fontFamily: "Opensans",
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    // padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border:
                            Border.all(color: Colors.green.shade100, width: 2),
                      ),
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,

                          child: DataTable(
                            columnSpacing: 20.0,
                            dataRowHeight: 100,
                            columns: [
                              DataColumn(label: Text('No.')),
                              DataColumn(label: Text('Tanggal')),
                              DataColumn(label: Text('Status')),
                            ],
                            rows: listProdusen.map((e) {
                              int index = listProdusen.indexOf(e) + 1;
                              int index2 = listProdusen.indexOf(e);
                              return DataRow(
                                cells: [
                                  DataCell(GestureDetector(
                                    child: Container(
                                        constraints: BoxConstraints(
                                            maxWidth: 35, maxHeight: 200),
                                        child: Text("${index}",
                                            overflow: TextOverflow.ellipsis)),
                                  )),
                                  DataCell(Container(
                                    constraints: BoxConstraints(maxWidth: 200),
                                    child: Text(e['address'],
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
                                onLongPress: () {
                                  _updateCameraPosition(index2);
                                  ;
                                  print('HALO');
                                },
                              );
                            }).toList(),
                          ),
                          // ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: IconButton(
                      iconSize: 100,
                      icon: const Icon(
                        Icons.arrow_circle_right_outlined,
                      ),
                      onPressed: () async {
                        print("button: ${buttonDisabled}");
                        if (buttonDisabled == true) {
                          null;
                        } else {
                          await saveLocation();
                          location.clear();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return SubmitPage();
                              },
                            ),
                          );
                          // Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),
                ],
              ),
              // child: Table(
              //   border: TableBorder.all(color: Colors.black),
              //   columnWidths: {
              //     0: FixedColumnWidth(50.0),
              //     1: FlexColumnWidth(),
              //     2: FixedColumnWidth(50.0),
              //   },
              //   children: data.map((row) {
              //     return TableRow(
              //       children: row.map((cell) {
              //         return Text(cell);
              //       }).toList(),
              //     );
              //   }).toList(),
              // ),
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
                // Navigator.of(context).pop();
                // Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => AddLocation()),
                );
              },
              child: Text(''),
            )),
      ],
    ));
  }
}
