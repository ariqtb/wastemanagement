import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class Location {
  String lat;
  String long;
  String time;

  Location({required this.lat, required this.long, required this.time});

  Map<String, dynamic> location() {
    return {"lat": lat, "long": long, "time": time};
  }
}

List<Map<String, dynamic>> location = [];

Future<void> addWaste(String currentDate, latitude, longitude) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    location.add({"lat": latitude, "long": longitude, "time": currentDate});
    print(location);
  } catch (e) {
    throw Exception(e);
  }
}

Future findUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('email');

  try {
    Response response = await http
        .get(Uri.parse('https://waste.tubagusariq.repl.co/users/${email}'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return "${response.statusCode}";
    }
  } catch (err) {
    return "error: $err";
  }
}

Future produsenPOST(String currentDate) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List<dynamic> data = await findUserData();
  String idUser = data[0]['_id'].toString().toLowerCase();

  try {
    Map<String, dynamic> produsen = {
      'produsen_sampah': idUser,
      'date': currentDate,
      'location': location,
      'picked_up': false
    };
    String bodyParse = jsonEncode(produsen);
    await prefs.setString('produsen', bodyParse);

    Response response = await http.post(
        Uri.parse('https://wastemanagement.tubagusariq.repl.co/produsen/add'),
        headers: {'Content-Type': 'application/json'},
        body: bodyParse);

        if(response.statusCode == 201) {
          return print('sukses');
        } else {
          return print('Gagal menyimpan data: ${response.body} = ${response.statusCode}');
        }
  } catch (err) {
    return "error: {err}";
  }
}

Future<void> clear() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('email');
  try {
    await prefs.setString('location', jsonEncode(location));
    location.clear();
  } catch (e) {
    throw Exception(e);
  }
}
