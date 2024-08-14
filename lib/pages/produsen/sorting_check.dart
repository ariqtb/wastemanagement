import 'dart:math';

import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'upload_produsen.dart';
import 'handler/produsen.handler.dart';
import 'add_image.dart';

class SortingCheck extends StatefulWidget {
  const SortingCheck({super.key});

  @override
  State<SortingCheck> createState() => _SortingCheckState();
}

class _SortingCheckState extends State<SortingCheck> {
  bool isLoading = false;
  bool isLoading2 = false;
  bool buttonDisabled = false;
  bool locationPermission = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

      // Show the BottomSheet when the page is loaded.
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        showMyBottomSheet(context);
      });
    // checkLocationPermission();
  }

  Future checkLocationPermission() async {
    final loc.Location location = loc.Location();
    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;

    // Check if location service is enabled
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        // Location service is still not enabled
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Izin akses lokasi ditolak, perizinan lokasi dibutuhkan untuk mengakses ini'))
        );
        setState(() {
          locationPermission = false;
        });
        return false;
      }
    }
      print(_serviceEnabled);

    // Check location permission status
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        // Location permission is denied
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Izin akses lokasi ditolak, perizinan lokasi dibutuhkan untuk mengakses pengambilan sampah.'))
        );
        Navigator.pop(context);
        setState(() {
          locationPermission = false;
        });
        return false;
      }
    }

    // Location permission is granted
    // print("Location permission is granted.");
  }

  void showMyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.fromLTRB(15, 20, 15, 20),
          child: Wrap(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: Text(
                  "Izin Akses Lokasi",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(40, 10, 40, 20),
                child: Image.asset("assets/location_design.png"),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  "Kami meminta lokasi anda agar pengambil sampah dapat mengambil sampah sesuai dengan tempat dan lokasi sampah anda.",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                alignment: Alignment.center,
                child: Text(
                  "Kami tidak akan menyalahgunakan lokasi anda demi kepentingan satu pihak.",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                alignment: Alignment.center,
                child: ElevatedButton(
                  child: Text("Beri Izin"),
                  onPressed: () {
                    // Handle delete action.
                    Navigator.pop(context);
                    checkLocationPermission();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
          child: Container(
            padding: EdgeInsets.fromLTRB(15, 50, 15, 50),
            // alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
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
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Kembali',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'OpenSans',
                          ),
                        )
                      ],
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                 Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Image.asset("assets/waste_design.png"),
              ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                      child: Text(
                        "Apakah anda sudah memilah sampah?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'OpenSans',
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if(await checkLocationPermission() == false){
                            // Navigator.of(context).pop();
                            return;
                          }
                          if (!buttonDisabled) {
                            setState(() {
                              isLoading2 = true;
                              buttonDisabled = true;
                            });
                            // Map<String, dynamic> location = await addLocation();
                            setState(() {
                              isLoading2 = false;
                              buttonDisabled = false;
                            });
                            print(location);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) {
                                  // return UploadProdusen();
                                  return ImagePickerScreen(
                                      // datas: location,
                                      );
                                },
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: isLoading2
                            ? SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white)))
                            : Text(
                                'Ya',
                                style: TextStyle(
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if(await checkLocationPermission() == false){
                            // Navigator.of(context).pop();
                            return;
                          }
                          if (!buttonDisabled) {
                            setState(() {
                              isLoading = true;
                              buttonDisabled = true;
                            });
                            await uploadProdusenData();
                            setState(() {
                              isLoading = false;
                              buttonDisabled = true;
                            });
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) {
                                  return UploadProdusen();
                                },
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator())
                            : Text(
                                'Tidak',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
