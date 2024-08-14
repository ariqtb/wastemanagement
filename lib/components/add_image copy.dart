import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:namer_app/pages/produsen/homepage/homepage.dart';
import '../conn/conn_api.dart';

import 'package:image_picker/image_picker.dart';
import '../providers/waste_class.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:async/async.dart';
import '../components/alert.dart';
import '../providers/get_image.dart';
import '../pages/petugas/homepage.dart';

class AddImage extends StatefulWidget {
  final String idWaste;
  AddImage({super.key, required this.idWaste});

  @override
  State<AddImage> createState() => AddImageState();
}

class AddImageState extends State<AddImage> {
  String? type;
  File? _imageFile;
  double? weightValue;
  int selectedIndex = 0;
  String idWaste = '';
  final picker = ImagePicker();
  bool isLoading = false;
  List<int> bytesPhoto = [];
  bool isDone = false;
  Map<String, String> filesInfo = {};
  Map<String, dynamic> wasteData = {};

  Future getImageFromCamera() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.camera, imageQuality: 20);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        List<int> bytesPhoto = _imageFile!.readAsBytesSync();
        // _imageFile = FlutterExifRotation.rotateImage(path: pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> getImageData() async {
    // final prefs = await SharedPreferences.getInstance();
    // String? type;
    // File? _imageFile;
    // double? weightValue;
    // List<Map<String, dynamic>> photoInfo = [];
    photoList.add(
        {'typePhoto': type, 'filename': _imageFile, 'weight': weightValue});
    setState(() {
      _imageFile = null;
      weightValue = null;
      print('photoList.length');
      print(photoList.length);
      print(photoList);
      // selectedIndex++;
    });
    // }
  }

  List<AnorganikObj> anorganik = [];
  List<OrganikObj> organik = [];
  List<B3Obj> b3 = [];
  List<ResiduObj> residu = [];
  List<Map<String, dynamic>> photoList = [];

  List<String> page = ['Anorganik', 'Organik'];

  void itung(File _imageFile) async {
    final sizeInBytes = await _imageFile.length();
    final sizeInKb = sizeInBytes / 1024;
    print('File size in bytes: $sizeInBytes');
    print('File size in KB: $sizeInKb');
  }

  Future<void> onGetData() async {
    if (type != null && _imageFile != null && weightValue != null) {
      itung(_imageFile!);

      var stream =
          http.ByteStream(DelegatingStream.typed(_imageFile!.openRead()));
      var length = await _imageFile!.length();

      var uri = Uri.parse('${API_URL}/waste/imagesave/${idWaste}');
      var request = http.MultipartRequest("PUT", uri);

      var multipartFile = http.MultipartFile('image', stream, length,
          filename: basename(_imageFile!.path));

      request.files.add(multipartFile);
      request.fields['typePhoto'] = type.toString();
      request.fields['weight'] = weightValue.toString();

      print(request.fields);

      // var response = await request.send();
      photoList
          .add({'typePhoto': type, 'image': _imageFile, 'weight': weightValue});

      setState(() {
        _imageFile = null;
        weightValue = null;
        print('photoList.length');
        selectedIndex++;
      });
      if (selectedIndex == 4) {
        await getImageData();
      }
    }
  }

  Future<http.Response> uploadImages(
      List<File> images, List<int> weights) async {
    var uri = Uri.parse('${API_URL}/waste/imagesave/$idWaste');

    var request = http.MultipartRequest('POST', uri);
    for (int i = 0; i < images.length; i++) {
      var stream = http.ByteStream(images[i].openRead());
      var length = await images[i].length();
      var multipartFile =
          http.MultipartFile('image', stream, length, filename: 'image$i.jpg');
      request.files.add(multipartFile);
      request.fields['weights[$i]'] = weights[i].toString();
    }

    var response = await request.send();
    return await http.Response.fromStream(response);
  }

  Future addImages() async {
    var request = http.MultipartRequest(
        'PUT', Uri.parse('${API_URL}/waste/imagesave/$idWaste'));

    var i = 0;
    for (var fileInfo in photoList) {
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

    for (var getInfo in photoList) {
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
      // return print(jsonEncode(imageMap));
      final response = await request.send();

      // setState(() {
      //   isDone
      // });
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

  @override
  void initState() {
    super.initState();
    idWaste = widget.idWaste;
    // print(idWaste);
    // onEachPage(selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    // while(selectedIndex < 4) {
    //   setState(() {
    //     selectedIndex += 1;
    //   });
    // }
    switch (selectedIndex) {
      case 0:
        type = 'anorganik';
        break;
      case 1:
        type = 'organik';
        break;
      // case 2:
      //   type = 'b3';
      //   break;
      // case 3:
      //   type = 'residu';
      //   break;
      default:
        return Scaffold();
    }
    List<double> items = List<double>.generate(50, (index) => 0.5 + index / 2);

    return WillPopScope(
      onWillPop: () async {
        final pop = await confirmDialog(context, [
          ...['Konfirmasi', 'Apakah anda ingin membatalkan aksi?']
        ]);
        return pop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text('${page[selectedIndex]}'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _imageFile != null
                  ? Image.file(
                      _imageFile!,
                      height: 200,
                    )
                  : Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 3),
                      ),
                      child: Text('Belum ada foto yang dipilih')),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: getImageFromCamera,
                child: Text('Ambil Foto'),
              ),
              SizedBox(
                height: 50,
              ),
              Container(
                child: Text('Masukkan berat'),
              ),
              DropdownButtonHideUnderline(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: DropdownButton<double>(
                    value: weightValue,
                    items: items
                        .map((double value) => DropdownMenuItem<double>(
                              value: value,
                              child: Text('${value} Kg'),
                            ))
                        .toList(),
                    hint: Text('Select weight'),
                    onChanged: (double? value) {
                      setState(() {
                        weightValue = value;
                      });
                      print(weightValue);
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              weightValue != null && selectedIndex < 4 && _imageFile != null
                  ? ElevatedButton(
                      child: Text('Lanjut'),
                      onPressed: () async {
                        // print(photoList.length);
                        // if (photoList.length <= 3) {
                        await getImageData();
                        // photoList.add(getImageData());
                        if (photoList.length >= 2) {
                          print(photoList);
                          // await uploadData(wasteData);
                          await addImages();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return HomepagePetugas();
                              },
                            ),
                          );
                        }
                        if (photoList.length < 4) {
                          setState(() {
                            selectedIndex++;
                          });
                        }
                        // }
                        print('${photoList.length}');
                        // if (photoList.length >= 4) {
                        //   setState(() {
                        //     isDone = true;
                        //   });
                        // }
                      },
                    )
                  : Container(),
              isLoading ? showModal(context) : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
