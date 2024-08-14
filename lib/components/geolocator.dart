import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import '../conn/conn_api.dart';
import '../providers/get_location.dart';

// class Location {
//   String lat;
//   String long;
//   String time;

//   Location({required this.lat, required this.long, required this.time});

//   Map<String, dynamic> location() {
//     return {"lat": lat, "long": long, "time": time};
//   }
// }

List<Map<String, dynamic>> waste = [];
List<Map<String, dynamic>> location = [];

Future<void> addWaste(String currentDate, latitude, longitude) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('email');

  try {
    location.add({"lat": latitude, "long": longitude, "time": currentDate});
    print(location);
    // print(location.runtimeType);
  } catch (e) {
    throw Exception(e);
  }
}

Future<void> stopWaste() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('email');
  try {
    await prefs.setString('location', jsonEncode(location));
    location.clear();
    // print(location.runtimeType);
  } catch (e) {
    throw Exception(e);
  }
}

// Future findUserData() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? email = prefs.getString('email');

//   try {
//     Response response = await http
//         .get(Uri.parse('https://waste.tubagusariq.repl.co/users/${email}'));
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       return "${response.statusCode}";
//     }
//   } catch (err) {
//     return "err ${err}";
//   }
// }

Future wastePOST(String currentDate) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // String? email = prefs.getString('email');
  List<dynamic> data = await findUserData();
  String id_user = data[0]['_id'].toString().toLowerCase();
  // return print(id_user);
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

Future<void> saveLocation(String currentDate) async {
  List<dynamic> data = await findUserData();
  String id_user = data[0]['_id'].toString().toLowerCase();

  Map<String, dynamic> waste = {
    'pengepul': id_user,
    'date': currentDate,
    'location': location,
    'recorded': false
  };
print(location);
  try {
    Response response = await http.post(
        Uri.parse('https://wastemanagement.tubagusariq.repl.co/waste/add'),
        body: {
          'pengepul': id_user,
          'date': currentDate,
          'location': jsonEncode(location),
          'recorded': false.toString()
        });
    // Response response =
    //     await http.post(Uri.parse('${API_URL}/waste/save/location'));
    if (response.statusCode == 200 || response.statusCode == 201) {
      // return json.decode(response.body);
      print(response.body);
      // print(response.statusCode);
    } else {
      return print(response.statusCode);
    }
    String bodyParse = jsonEncode(waste);
    // await prefs.setString('waste', bodyParse);
  } catch (e) {
    throw Exception(e);
  }
}
