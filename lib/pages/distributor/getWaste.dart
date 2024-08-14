import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:namer_app/conn/conn_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

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

Future<Tuple2<double, double>> getLocation() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    Position position = await getGeoLocationPosition();
    DateTime now = DateTime.now();

    double latitude;
    double longitude;

    latitude = position.latitude;
    longitude = position.longitude;

  return Tuple2(latitude, longitude);
  } catch (err) {
    return Tuple2(-1, -1);;
  }

}

Future isDataDuplicate(wasteProdusen, listPickup) async {
  if (listPickup.length != 0) {
    for (final index in listPickup) {
      if (index['produsen_info']['id_waste_produsen'] == null) {
        return true;
      }
      if (index['produsen_info']['id_waste_produsen'] ==
          wasteProdusen['id_waste_produsen']) {
        return true;
      }
    }
    return false;
  } else {
    return false;
  }
}

Future addLocationWaste(listProdusen, listPickup) async {
  Tuple2<double, double> getLocationWaste = await getLocation();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if(getLocationWaste.item1 == -1 && getLocationWaste.item2 == -1) {
    throw Error();
  }

  double latitude = getLocationWaste.item1;
  double longitude = getLocationWaste.item2;

  double? produsenlong;
  double? produsenlat;

  for (final index in listProdusen) {
    if (index['lat'] is! String || index['long'] is! String) {
      listPickup.add({
        "lat": latitude,
        "long": longitude,
      });
      continue;
    }
    produsenlat = double.parse(index['lat']);
    produsenlong = double.parse(index['long']);

    double distanceInMeters = await Geolocator.distanceBetween(
      produsenlat,
      produsenlong,
      latitude,
      longitude,
    );

    final isDuplicate = await isDataDuplicate(index, listPickup);

    if (distanceInMeters >= 0 &&
        distanceInMeters <= 50 &&
        isDuplicate == false) {
      Map<String, dynamic> produsen_info = {};
      produsen_info['distance'] = distanceInMeters;
      produsen_info['id_waste_produsen'] = index['id_waste_produsen'];
      produsen_info['status'] = 1;

      listPickup.add(
          {"lat": latitude, "long": longitude, "produsen_info": produsen_info});
    }
  }
  // print("HALOOOOO ${isDuplicate}");
  // print(listProdusen[0]['lat']);
}
