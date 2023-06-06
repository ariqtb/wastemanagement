import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

import '../conn/conn_api.dart';

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
