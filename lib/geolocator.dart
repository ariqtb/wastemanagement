import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/geolocator.dart';
import 'pages/recap_pickup.dart';
import 'providers/get_location.dart';
import 'components/alert.dart';

class GenerateLocator extends StatefulWidget {
  GenerateLocator({
    super.key,
  });

  @override
  State<GenerateLocator> createState() => _GenerateLocatorState();
}

class _GenerateLocatorState extends State<GenerateLocator> {
  String location = '(Belum Mendapatkan kode lokasi, Silahkan tekan button)';
  String address = 'Mencari lokasi...';
  String info = 'Tekan tombol untuk menandai pengambilan sampah';
  String infoclone = 'Tekan tombol untuk menandai pengambilan sampah';

  bool addTrashStatus = false;

  late String lat;
  late String long;
  int count = 0;
  bool loading = false;
  Map<dynamic, String>? wasteData;

  late String currentDate;
  late String latitude;
  late String longitude;
  late double distance_first_loc;
  late double distance_last_loc;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final pop = await confirmDialog(context, [
          ...['Konfirmasi', 'Apakah anda ingin keluar?']
        ]);
        return pop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Pengambilan Sampah"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                count.toString(),
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
              SizedBox(height: 50),
              loading
                  ? Text(
                      address,
                      textAlign: TextAlign.center,
                    )
                  : const SizedBox(
                      height: 20,
                    ),
              SizedBox(
                height: 20,
              ),
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
                            Icons.cancel_outlined,
                            // color: Colors.redAccent,
                          ),
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            setState(() {
                              loading = true;
                            });
                            Map<dynamic, String>? waste;
                            if (waste == null) {
                              waste =
                                  await wastePOST(DateTime.now().toString());
                            }
                            await stopWaste();
                            setState(() {
                              loading = false;
                            });

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return RecapPickup();
                                },
                              ),
                            );
                            setState(() {
                              info = infoclone;
                              count = 0;
                              addTrashStatus = false;
                            });
                          },
                        ),
                        IconButton(
                          iconSize: 110,
                          icon: const Icon(
                            Icons.arrow_circle_right_outlined,
                            // color: Colors.green,
                          ),
                          onPressed: () async {
                            // await _showDialogSuccess();
                            setState(() {
                              addTrashStatus = false;
                              info = infoclone;
                            });

                            // Navigator.of(context).push(
                            //   MaterialPageRoute(
                            //     builder: (BuildContext context) {
                            //       return HomePage();
                            //     },
                            //   ),
                            // );
                          },
                        )
                      ],
                    )
                  : Container(
                      padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(80),
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: !addTrashStatus
                            ? () async {
                                setState(() {
                                  loading = true;
                                });
                                DateTime now = DateTime.now();
                                currentDate = now.toString();

                                Position position =
                                    await getGeoLocationPosition();
                                setState(() {
                                  latitude = position.latitude.toString();
                                  longitude = position.longitude.toString();
                                  loading = false;
                                  addTrashStatus = !addTrashStatus;
                                  location =
                                      '${position.latitude}, ${position.longitude}';
                                  getAddressFromLongLat(position);
                                  addWaste(currentDate, latitude, longitude);
                                  count++;
                                  info = 'Sampah berhasil diproses';
                                  // addTrashStatus = !addTrashStatus;
                                });
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
