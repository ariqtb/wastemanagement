import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

Future<WasteData> _fetchData() async {
  bool generateData = true;
  List _dataIRT = [];

  final response = await http
      .get(Uri.parse('https://waste-management.leeseona25.repl.co/waste/IRT'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data;
    // return print('berhasil');
  } else {
    throw Exception('Failed Fetching');
  }
}

class WasteData {
  final String id;
  final String lat;
  final String long;
  final String address;
  final String produsen_id;
  final bool picked_up;

  const WasteData({
    required this.id,
    required this.lat,
    required this.long,
    required this.address,
    required this.produsen_id,
    required this.picked_up,
  });

  factory WasteData.fromJson(Map<String, dynamic> json) {
    return WasteData(
        id: json['id'],
        lat: json['lat'],
        long: json['long'],
        address: json['address'],
        produsen_id: json['produsen_id'],
        picked_up: json['picked_up']);
  }

  // void _setPickedVal(bool newVal) {
  //   picked_up = newVal;
  //   notifyListeners();
  // }

  // Future<void> togglePickedStatus() async {
  //   final oldStatus = picked_up;
  //   picked_up = !picked_up;
  //   notifyListeners();
  //   final url = "https://waste-management.leeseona25.repl.co/waste/IRT";
  // }
}
