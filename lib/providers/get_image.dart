import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../conn/conn_api.dart';

final picker = ImagePicker();

Future getImageFromCamera() async {
  File? _imageFile;
  final pickedFile =
      await picker.getImage(source: ImageSource.camera, imageQuality: 20);

  if (pickedFile != null) {
    _imageFile = File(pickedFile.path);
    List<int> bytesPhoto = _imageFile.readAsBytesSync();
    // _imageFile = FlutterExifRotation.rotateImage(path: pickedFile.path);
  } else {
    print('No image selected.');
  }
  ;

  return _imageFile;
}

// getImageData() {
//   // final prefs = await SharedPreferences.getInstance();
//   String? type;
//   File? _imageFile;
//   double? weightValue;
//   List<Map<String, dynamic>> photoInfo = [];
//   photoInfo
//       .add({'typePhoto': type, 'filename': _imageFile, 'weight': weightValue});
//   return photoInfo;
//   // }
// }
