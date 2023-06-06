import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:async/async.dart';

import '../conn/conn_api.dart';

Future getImageFromCamera() async {
  final picker = ImagePicker();
  File imageFile;

  final pickedFile =
      await picker.getImage(source: ImageSource.camera, imageQuality: 20);
  if (pickedFile != null) {
    imageFile = File(pickedFile.path);
    return imageFile;
  } else {
    print('No image selected.');
  }
}

Future addImageList(type, imageFile, weight, imageList) async {
  imageList.add({'typePhoto': type, 'filename': imageFile, 'weight': weight});
  print(imageList);
  return imageList;
}

Future uploadImages(idWaste, imageList) async {
   var request = http.MultipartRequest(
        'PATCH', Uri.parse('${API_URL}/waste/imagesave/$idWaste'));

    var i = 0;
    for (var fileInfo in imageList) {
      final file = fileInfo['filename'];
      var stream = http.ByteStream(DelegatingStream(file.openRead()));
      var length = await file.length();
      var multipartFile = http.MultipartFile('photo', stream, length,
          filename: basename(file.path));
      request.files.add(multipartFile);
      i++;
    }

    request.headers['Content-Type'] = 'application/json';
    List<dynamic> imageMap = [];

    for (var getInfo in imageList) {
      String filename = getInfo['filename'].path.split('/').last;
      imageMap.add({
        'typePhoto': getInfo['typePhoto'],
        'filename': filename,
        'weight': getInfo['weight']
      });
    }
      request.fields.addAll({
        'image': jsonEncode(imageMap),
      });
      print(request.fields.runtimeType);
      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
      print('Photos and data uploaded successfully ${response.statusCode}');
      // var responseString = (responseBytes);
      var responseBytes = await http.Response.fromStream(response);
      print(responseBytes.body);
    } else {
      print('Failed to upload photos and data: ${response.statusCode}');
      var responseBytes = await http.Response.fromStream(response);
      print(responseBytes.body);
    }
}


