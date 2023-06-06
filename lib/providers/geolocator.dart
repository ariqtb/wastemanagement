import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

Future<Position> getGeoLocationPosition() async {
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

Future getAddressFromLongLat(Position position) async {
  List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
  if (placemarks != null && placemarks.isNotEmpty) {
    Placemark placemark = placemarks[0];
    String address =
        '${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.postalCode}, ${placemark.country}';
    return address;
  }
  return null;
  //  setState(() {
  //     address =
  //         '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
  //   });
}
