// import 'package:example/change_settings.dart';
// import 'package:example/enable_in_background.dart';
import 'package:flutter/material.dart';
// import 'package:location/location.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

// Request location permissions
Future<void> requestLocationPermission() async {
  final status = await Permission.location.request();
    print("SUCCESS ${status}");
  if (status == PermissionStatus.granted) {
    print("SUCCESS3 ${loc.PermissionStatus.granted}");
    // Permission granted, you can now access location.
    getLocation();

  } else {
    print("SUCCESS22 ${status}");
    // Permission denied, handle accordingly.
  }
}

Future<void> getLocation() async {
  final location = loc.Location();
  try {
    var currentLocation = await location.getLocation();
    print('Latitude: ${currentLocation.latitude}');
    print('Longitude: ${currentLocation.longitude}');
  } catch (e) {
    print('Error getting location: $e');
  }
}

const _url = 'https://github.com/Lyokone/flutterlocation';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title});
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final loc.Location location = loc.Location();

  Future<void> _showInfoDialog() {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Demo Application'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Created by Guillaume Bernos'),
                InkWell(
                  child: const Text(
                    _url,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('widget.title'),
          // actions: <Widget>[
          //   IconButton(
          //     icon: const Icon(Icons.info_outline),
          //     onPressed: _showInfoDialog,
          //   )
          // ],
        ),
        body: Container(
          child: ElevatedButton(
            onPressed: () {
              requestLocationPermission();
            },
            child: Text('Get Location'),
          ),
        ));
  }
}
