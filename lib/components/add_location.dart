import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
// import 'geolocator.dart';
import '../pages/recap_pickup_only.dart';
import '../providers/get_location.dart';
import 'alert.dart';
import '../conn/conn_api.dart';

class AddLocation extends StatefulWidget {
  AddLocation({
    super.key,
  });

  @override
  State<AddLocation> createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  String location = '';
  String address = 'Mencari lokasi...';
  String info = '';
  String infoclone = '';

  bool addTrashStatus = false;
  bool buttonDisabled = false;

  late String lat;
  late String long;
  int count = 0;
  bool loading = false;
  String? getProdusen;
  List<Map<String, dynamic>> listProdusen = [];
  Map<String, dynamic> wasteData = {};
  List<Map<String, dynamic>> locationWaste = [];

  late String currentDate;
  late String latitude;
  late String longitude;
  late double distance_first_loc;
  late double distance_last_loc;

  Future getProdusenList() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      getProdusen = prefs.getString('listpickup');
      listProdusen = List<Map<String, dynamic>>.from(json.decode(getProdusen!));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProdusenList();
    // print(getProdusen);
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
                Icon(
                  Icons.logout_rounded,
                  color: Colors.black87,
                ),
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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Pengambilan Sampah"),
          actions: [
            PopupMenuButton<String>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              offset: Offset(0, 50),
              itemBuilder: (BuildContext context) => menuItems,
              onSelected: (String selectedItem) {
                if (selectedItem == 'Keluar') {
                  // print('Selected itessm: $selectedItem');
                  Navigator.of(context).pop();
                }
                // Handle selected item
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                // "${locationWaste.length}",
                "",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 60,
              ),
              Text(
                info,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              // SizedBox(height: 50),
              loading
                  ? Text(
                      address,
                      textAlign: TextAlign.center,
                    )
                  : Container(),
              // SizedBox(
              //   height: 20,
              // ),
              loading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(),
              addTrashStatus
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          iconSize: 110,
                          icon: const Icon(
                            Icons.rectangle_rounded,
                            size: 80,
                            // color: Colors.redAccent,
                          ),
                          onPressed: () async {
                            // print("wagwgwgwgw: ${locationWaste}");
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return RecapLocationToSave(
                                      location: locationWaste,
                                      listProdusen: listProdusen);
                                },
                              ),
                            );
                            setState(() {
                              info = infoclone;
                              // count = 0;
                              addTrashStatus = false;
                            });
                          },
                        ),
                        IconButton(
                          iconSize: 110,
                          icon: const Icon(
                            Icons.play_arrow_rounded,
                            // color: Colors.green,
                          ),
                          onPressed: () async {
                            // await _showDialogSuccess();
                            setState(() {
                              addTrashStatus = false;
                              info = infoclone;
                            });
                          },
                        )
                      ],
                    )
                  : Container(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(80),
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: !addTrashStatus
                            ? () async {
                                if (!buttonDisabled) {
                                  setState(() {
                                    loading = true;
                                    buttonDisabled = true;
                                  });
                                  // getLocationWaste()
                                  await addLocationWaste(
                                      listProdusen, locationWaste);
                                  locationWaste.forEach((element) {
                                    print("ini: ${element['produsen_info']['status']}");
                                    print("ini: ${element['produsen_info']['distanceInMeters']}");
                                  });
                                  setState(() {
                                    loading = false;
                                    buttonDisabled = false;
                                    addTrashStatus = !addTrashStatus;
                                    count++;
                                    info = 'Sampah berhasil diproses';
                                    // addTrashStatus = !addTrashStatus;
                                  });
                                }
                              }
                            : () {},
                        child: addTrashStatus
                            ? const Text('Sudah ditandai')
                            : const Text('Tandai tempat'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConfirmDone extends StatelessWidget {
  const ConfirmDone({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Konfirmasi selesai'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Klik tombol untuk selesai',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 50,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(80),
                backgroundColor: Colors.green,
              ),
              child: Text('Selesai'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      ),
    );
  }
}
