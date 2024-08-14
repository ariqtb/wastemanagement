import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math' as math;
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

Future getAddressFromLongLat(Position position) async {
  List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
  return placemarks;
  //  setState(() {
  //     address =
  //         '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
  //   });
}

// Calculate the distance between two locations using the Haversine formula
// double getDistance(Location from, Location to) {
//   const earthRadius = 6371; // km
//   final dLat = _toRadians(to.lat - from.lat);
//   final dLng = _toRadians(to.lng - from.lng);
//   final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
//       math.cos(_toRadians(from.lat)) *
//           math.cos(_toRadians(to.lat)) *
//           math.sin(dLng / 2) *
//           math.sin(dLng / 2);
//   final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
//   return earthRadius * c;
// }

// double _toRadians(double degrees) {
//   return degrees * math.pi / 180;
// }

// ############ SISANYA CEK DI CHATGPT ############

Future<Tuple2<double, double>> getLocation() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Position position = await getGeoLocationPosition();
  DateTime now = DateTime.now();

  double latitude;
  double longitude;

  latitude = position.latitude;
  longitude = position.longitude;

  return Tuple2(latitude, longitude);
}

Future isDataDuplicate(listProdusen, location) async {
  Map<String, dynamic> nearestLocation = {};
  int i = 0;
  // if (listProdusen.length == 1 || location.length == 0) {
  //   return nearestLocation = listProdusen[0];
  // }
  for (final datalist in listProdusen) {
    bool isNotIn = false;
    for (final data in location) {
      if (datalist['id_waste_produsen'] ==
          data["produsen_info"]["id_waste_produsen"]) {
        // print("DATADUPIKAT: ${location}");
        isNotIn = true;
        break;
      }
      // if (datalist['lat'] == data["produsen_info"]["lat"] &&
      //     datalist['long'] == data["produsen_info"]["long"]) {
      //   isNotIn = true;
      //   break;
      // }
    }
    // print("DATA: ${location}");
    // print("DATALIST: ${datalist}");
    if (isNotIn == false) {
      return nearestLocation = listProdusen[i];
    }
    i++;
  }
  return nearestLocation;
}

Future<Tuple3<Map<String, dynamic>, List, double>> sortListAndGetDistance(
    listProdusen, location) async {
  Position position = await getGeoLocationPosition();
  Tuple2<double, double> gettinglocation = await getLocation();

  List<dynamic> sortedList = [];
  Map<String, dynamic> produsenData = {};
  double distanceInMeters = 0;
  double new_distance_first_loc;
  double distance_prev_loc;

  double latitude = gettinglocation.item1;
  double longitude = gettinglocation.item2;
  // print('LIST PRODUSEN: ${listProdusen}');
  if (listProdusen.length == 0) {
    distanceInMeters = -1;
    return Tuple3(produsenData, sortedList, distanceInMeters);
  }
  if (listProdusen.length == 1) {
    //Menghitung jarak lokasi awal dengan akhir (pasti hasilnya 0)
    //Karena lokasi awal dihitung dari pengambilan sampah pertama
    distanceInMeters = await Geolocator.distanceBetween(
      double.parse(listProdusen[0]['lat']),
      double.parse(listProdusen[0]['long']),
      latitude,
      longitude,
    );
    listProdusen[0]['distanceInMeters'] = distanceInMeters;
    sortedList.add(distanceInMeters);
    // produsenData = listProdusen[0];
    produsenData = await isDataDuplicate(listProdusen, location);
    if (produsenData['distanceInMeters'] != null) {
      distanceInMeters = produsenData['distanceInMeters'];
    } else {
      distanceInMeters = 0;
    }

    produsenData['distanceInMeters'] = distanceInMeters;
    return Tuple3(produsenData, sortedList, distanceInMeters);
  }
  for (final produsen in listProdusen) {
    double targetLatitude = double.parse(produsen['lat']);
    double targetLongitude = double.parse(produsen['long']);
    distanceInMeters = await Geolocator.distanceBetween(
      latitude,
      longitude,
      targetLatitude,
      targetLongitude,
    );
    produsen['distanceInMeters'] = distanceInMeters;
    sortedList.add(distanceInMeters);
  }

  listProdusen.sort((a, b) {
    double valueA = a['distanceInMeters'];
    double valueB = b['distanceInMeters'];

    return valueA.compareTo(valueB);
  });
  // print(listProdusen);
  sortedList.sort();

  // print("KALEMM: ${listProdusen}");
  // produsenData = listProdusen[0];
  produsenData = await isDataDuplicate(listProdusen, location);
  if (produsenData['distanceInMeters'] != null ) {
    distanceInMeters = produsenData['distanceInMeters'];
  } else {
    distanceInMeters = -1;
  }

  // bool isDuplicate = location.any((item) =>
  //     item['lat'] == produsenData['lat'] &&
  //     item['long'] == produsenData['long']);
  // if (isDuplicate == true) {
  //   produsenData.clear();
  //   sortedList.clear();
  //   distanceInMeters = 0;
  //   return Tuple3(produsenData, sortedList, distanceInMeters);
  // }
  return Tuple3(produsenData, sortedList, distanceInMeters);
}

Future<Tuple2<double, double>> getDistanceLocation(
    list, latitude, longitude) async {
  double old_latitude;
  double old_longitude;
  double new_distance_first_loc;
  double distance_prev_loc;
  String rounding_new_distance_first_loc = '';
  String rounding_distance_prev_loc = '';

  if (list.length == 1) {
    //Mengecek apakah data sampah dari irt cuma ada 1 data
    old_latitude =
        list[0]['lat']; //Definisi jarak lokasi awal sama dengan lokasi akhir
    old_longitude = list[0]['long'];

    double distanceInMeters = await Geolocator.distanceBetween(
      //Menghitung jarak lokasi awal dengan akhir (pasti hasilnya 0)
      old_latitude, //Karena lokasi awal dihitung dari pengambilan sampah pertama
      old_longitude,
      latitude,
      longitude,
    );
    // Pembulatan data jarak dengan ukuran decimal 1, dihitung per-meter
    rounding_new_distance_first_loc = distanceInMeters.toStringAsFixed(1);
    rounding_distance_prev_loc = distanceInMeters.toStringAsFixed(1);

    // parsing tipe data ke double
    new_distance_first_loc = double.parse(rounding_new_distance_first_loc);
    distance_prev_loc = double.parse(rounding_distance_prev_loc);
    return Tuple2(new_distance_first_loc, distance_prev_loc);
    // Kalau data sampah irt lebih dari >= 2
  } else if (list.length >= 2) {
    // Definisi lokasi terakhir menjadi old_
    old_latitude = list.last['lat'];
    old_longitude = list.last['long'];
    // Hitung jarak lokasi old_ dengan lokasi terbaru
    double distanceInMeters = await Geolocator.distanceBetween(
      old_latitude,
      old_longitude,
      latitude,
      longitude,
    );
    print("object: ${list.last['distance_first_loc']}");

    // Pembulatan data jarak dengan ukuran decimal 1, dihitung per-meter
    rounding_new_distance_first_loc =
        list.last['distance_first_loc'].toStringAsFixed(1);
    rounding_distance_prev_loc =
        list.last['distance_prev_loc'].toStringAsFixed(1);
    // parsing tipe data ke double
    new_distance_first_loc = double.parse(rounding_new_distance_first_loc);
    distance_prev_loc = double.parse(rounding_distance_prev_loc);
    // Hitung secara keseluruhan jarak dari sampah pertama hingga akhir (Dihitung setiap loop)
    new_distance_first_loc += distanceInMeters;
    // Jarak data lokasi terakhir dengan sebelum terakhir
    distance_prev_loc = distanceInMeters;

    return Tuple2(new_distance_first_loc, distance_prev_loc);
  } else {
    new_distance_first_loc = 0;
    distance_prev_loc = 0;
    // print("object: ${list}");
    return Tuple2(new_distance_first_loc, distance_prev_loc);
  }
}

Future<void> addLocationWaste(listProdusen, location) async {
  // print("ini isi location: ${list}");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Position position = await getGeoLocationPosition();
  Tuple2<double, double> getLocationWaste = await getLocation();
  // List<Map<String, dynamic>> listProdusen =
  //     List<Map<String, dynamic>>.from(json.decode(list!));

  DateTime now = DateTime.now();
  String? email = prefs.getString('email');
  String? pickupList = prefs.getString('listpickup');

  Map<String, dynamic> closestLocation = {};
  double? closestDistance;

  String currentDate;
  double latitude;
  double longitude;
  double old_latitude;
  double old_longitude;
  String rounding_new_distance_first_loc = '';
  String rounding_distance_prev_loc = '';
  List sortedList = [];
  double? distanceInMeters;

  currentDate = now.toString();
  latitude = getLocationWaste.item1;
  longitude = getLocationWaste.item2;

  Tuple2<double, double> getDistance =
      await getDistanceLocation(location, latitude, longitude);
  double new_distance_first_loc = getDistance.item1;
  double distance_prev_loc = getDistance.item2;

  if (listProdusen.length != 0) {
    Tuple3<Map<String, dynamic>, List, double> sortList =
        await sortListAndGetDistance(listProdusen, location);
    closestLocation = sortList.item1;
    sortedList = sortList.item2;
    distanceInMeters = sortList.item3;
    closestDistance = sortedList[0];
    // print('MASUKSINI');
  } else {
    distanceInMeters = -1;
    closestDistance = -1;
  }
  print(latitude);
  print(longitude);
  print(closestLocation);
  if (distanceInMeters == -1) {
    closestLocation["info"] = "Data sampah tidak terdaftar";
    closestLocation['status'] = 0;
  } else if (distanceInMeters > 5) {
    print("KEJAUHAN");
    // closestLocation.clear();
    closestLocation["info"] =
        "Data IRT terlalu jauh, berjarak ${distanceInMeters} meter dari lokasi terdekat";
    closestLocation["distance"] = distanceInMeters;
    closestLocation['status'] = 0;
  } else if (distanceInMeters <= 5 && distanceInMeters > 0) {
    closestLocation["info"] = "Data sampah terdaftar";
    closestLocation["distance"] = distanceInMeters;
    closestLocation['status'] = 1;
    // print("distanceInMeters: ${distanceInMeters}");
  } else{
    closestLocation["info"] = "Data sampah terdaftar";
    closestLocation["distance"] = distanceInMeters;
    closestLocation['status'] = 1;

  }
  // print("INI CLOSEST LOCATION: ${closestLocation}");
  try {
    location.add({
      "lat": latitude,
      "long": longitude,
      "time": currentDate,
      "distance_first_loc": new_distance_first_loc,
      "distance_prev_loc": distance_prev_loc,
      "produsen_info": closestLocation,
    });
    // print(listProdusen);
  } catch (e) {
    throw Exception(e);
  }

  // print("INI LOCATION: ${location}");
  // List<Map<String, dynamic>> list =
  //     List<Map<String, dynamic>>.from(json.decode(listProdusen!));

  // Mengecek apabila ada data sampah irt
  // if (list.length != 0) {
  //   int indexToDelete = 0;
  //   bool trueToDelete = true;
  //   String roundingDouble = '';

  // kalau jarak pengepul dengan sampah irt 0 meter atau kurang
  // if (closestDistance == 0 || distanceInMeters < closestDistance) {
  //   trueToDelete = true;
  //   roundingDouble = distanceInMeters.toStringAsFixed(1);
  //   closestDistance = double.parse(roundingDouble);
  //   // print("${closestDistance}");
  //   if (distanceInMeters <= 5) {
  //     closestLocation = locationprodusen;
  //     indexToDelete = list.indexWhere((element) =>
  //         element["lat"] == locationprodusen["lat"] &&
  //         element["long"] == locationprodusen["long"] &&
  //         element["produsen_sampah"] ==
  //             locationprodusen["produsen_sampah"]);
  //   } else {
  //     trueToDelete = false;
  //     closestLocation["info"] =
  //         "Data IRT terlalu jauh, berjarak ${closestDistance} meter dari lokasi terdekat";
  //   }
  // }
  // if (trueToDelete) {
  //   print('MASUK KE SINI');
  //   list.removeAt(indexToDelete);
  //   // await prefs.setString('listpickup', jsonEncode(list));
  //   closestLocation["distance_from_pickup"] = closestDistance;
  // }
  // } else {
  //   closestLocation["info"] = "Data sampah tidak terdaftar";
  // }
  //   for (final locationprodusen in list) {
  //     double targetLatitude = double.parse(locationprodusen['lat']);
  //     double targetLongitude = double.parse(locationprodusen['long']);
  //     double distanceInMeters = await Geolocator.distanceBetween(
  //       latitude,
  //       longitude,
  //       targetLatitude,
  //       targetLongitude,
  //     );
  //     // kalau jarak pengepul dengan sampah irt 0 meter atau kurang
  //     if (closestDistance == 0 || distanceInMeters < closestDistance) {
  //       trueToDelete = true;
  //       roundingDouble = distanceInMeters.toStringAsFixed(1);
  //       closestDistance = double.parse(roundingDouble);
  //       // print("${closestDistance}");
  //       if (distanceInMeters <= 5) {
  //         closestLocation = locationprodusen;
  //         indexToDelete = list.indexWhere((element) =>
  //             element["lat"] == locationprodusen["lat"] &&
  //             element["long"] == locationprodusen["long"] &&
  //             element["produsen_sampah"] ==
  //                 locationprodusen["produsen_sampah"]);
  //       } else {
  //         trueToDelete = false;
  //         closestLocation["info"] =
  //             "Data IRT terlalu jauh, berjarak ${closestDistance} meter dari lokasi terdekat";
  //       }
  //     }
  //   }
  //   if (trueToDelete) {
  //     print('MASUK KE SINI');
  //     list.removeAt(indexToDelete);
  //     // await prefs.setString('listpickup', jsonEncode(list));
  //     closestLocation["distance_from_pickup"] = closestDistance;
  //   }
  // } else {
  //   closestLocation["info"] = "Data sampah tidak terdaftar";
  // }
}

Future<void> deleteAndSetLocationToSession(location) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    await prefs.setString('location', jsonEncode(location));
    location.clear();
  } catch (e) {
    throw Exception(e);
  }
}

Future findUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('email');

  try {
    Response response = await http
        .get(Uri.parse('${API_URL}/user/${email}'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return "${response.statusCode}";
    }
  } catch (err) {
    return "err ${err}";
  }
}

Future getFullWasteData(location) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  DateTime now = DateTime.now();
  List<dynamic> data = await findUserData();

  String currentDate;
  String id_user;

  id_user = data[0]['_id'].toString().toLowerCase();
  currentDate = now.toString();

  try {
    Map<String, dynamic> waste = {
      'pengepul': id_user,
      'date': currentDate,
      'location': location,
      'recorded': false
    };

    String bodyParse = jsonEncode(waste);
    await prefs.setString('waste', bodyParse);
  } catch (e) {
    throw Exception(e);
  }
}

getClosestLocation(mylocation, targetlocation) async {
  double myLatitude = mylocation.latitude;
  double myLongitude = mylocation.longitude;
  double targetLatitude = mylocation.latitude;
  double targetLongitude = mylocation.longitude;

  Location closestLocation;
  double? closestDistance;

  for (final location in targetlocation) {
    double distance = await Geolocator.distanceBetween(
      myLatitude,
      myLongitude,
      targetLatitude,
      targetLongitude,
    );
    // final distance = distanceLocation(mylocation, targetlocation);
    if (closestDistance == null || distance < closestDistance) {
      closestLocation = location;
      closestDistance = distance;
    }
  }
}
