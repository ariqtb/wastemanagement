import 'package:location/location.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

// Request location permissions
Future<void> requestLocationPermission() async {
  final status = await Permission.location.request();
  if (status == loc.PermissionStatus.granted) {
    // Permission granted, you can now access location.
    getLocation();
  } else {
    // Permission denied, handle accordingly.
  }
}

Future<void> getLocation() async {
  final location = Location();
  try {
    var currentLocation = await location.getLocation();
    print('Latitude: ${currentLocation.latitude}');
    print('Longitude: ${currentLocation.longitude}');
  } catch (e) {
    print('Error getting location: $e');
  }
}
