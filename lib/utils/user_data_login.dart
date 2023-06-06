import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future findUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('email');

  try{
    Response response = await http.get(
        Uri.parse('https://waste.tubagusariq.repl.co/users/${email}'));
    if(response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return "${response.statusCode}";
    }
  }catch(err) {
    return "err ${err}";
  }

}