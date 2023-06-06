import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class waste_pengepul {
  final String _id;
  final String jalur;
  final String date;
  final bool recorded;

  waste_pengepul(this._id, this.jalur, this.date, this.recorded);

  Map<String, dynamic> toJson() => {
    'pengepul': _id,
    'jalur': jalur,
    'date': date,
    'recorded': recorded,
  };
}

Future<void> postData(waste_pengepul data) async {
  final url = Uri.parse('https://waste-management.leeseona25.repl.co/waste');
  final headers = {'COntent-Type': 'application/json'};
  final jsonData = json.encode(data.toJson());

  try {
    final response = await http.post(url, headers:headers, body: jsonData);
    if(response.statusCode == 200) {
      print('Success');
    } else {
      print('failed');
    }
  } catch(e) {
    throw Exception('Failed');
  }
}
