import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:namer_app/pages/irt/upload_produsen.dart';
import '../../conn/conn_api.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:namer_app/pages/history_pickup.dart';
import '../../providers/waste_class.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path/path.dart' as path;
import 'package:async/async.dart';
import 'recap_image.dart';
import '../../components/alert.dart';

class ImagePickerScreen extends StatefulWidget {
  final Map<String, dynamic> datas;
  ImagePickerScreen({required this.datas});

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  String type = 'Anorganik';
  File? _imageFile;
  double? weightValue;
  int selectedIndex = 0;
  late String idWaste;
  final picker = ImagePicker();
  bool isLoading = false;
  bool isLoading2 = false;
  List<int> bytesPhoto = [];
  bool isDone = false;
  Map<String, String> filesInfo = {};
  Map<String, dynamic> wasteData = {};

  Future getImageFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

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

  List<AnorganikObj> anorganik = [];
  List<OrganikObj> organik = [];
  List<B3Obj> b3 = [];
  List<ResiduObj> residu = [];
  List<Map<String, dynamic>> photoList = [];

  List<String> page = ['Anorganik', 'Organik', 'B3', 'Residu'];
  int pageSelected = 0;

  Future<void> getImageData() async {
    if (_imageFile != null) {
      // String filename = basename(_imageFile!.path);

      photoList.add(
          {'typePhoto': type, 'filename': _imageFile, 'weight': weightValue});
    }
    setState(() {
      _imageFile = null;
      weightValue = null;
    });
  }

  Future<void> uploadData(Map<String, dynamic> datas) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('${API_URL}/produsen/save'));

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
      'produsen_sampah': datas['produsen_sampah'],
      'date': datas['date'],
      'jalur': datas['jalur'],
      'location': jsonEncode(datas['location']),
      'image': jsonEncode(imageMap),
      'picked_up': datas['picked_up'].toString()
    });

    final response = await request.send();

    setState(() {
      isDone = true;
    });

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

  Future<http.Response> uploadImages(
      List<File> images, List<int> weights) async {
    var uri = Uri.parse('${API_URL}/waste/imagesave/$idWaste');

    var request = http.MultipartRequest('POST', uri);
    for (int i = 0; i < images.length; i++) {
      var stream = http.ByteStream(images[i].openRead());
      var length = await images[i].length();
      // var multipartFile =
      //     http.MultipartFile('image', stream, length, filename: 'image$i.jpg');
      var multipartFile =
          http.MultipartFile('image', stream, length, filename: 'image$i.jpg');
      request.files.add(multipartFile);
      request.fields['weights[$i]'] = weights[i].toString();
    }

    var response = await request.send();
    return await http.Response.fromStream(response);
  }

  @override
  void initState() {
    super.initState();
    wasteData = widget.datas;
  }

  @override
  Widget build(BuildContext context) {
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
          title: Text('${page[pageSelected]}'),
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
                height: 30,
              ),
              weightValue != null && selectedIndex < 4 && _imageFile != null
                  ? IconButton(
                    iconSize: 110,
                    icon: const Icon(
                            Icons.play_arrow_rounded,
                          ),
                      // child: !isLoading2
                      //     ? Text('Lanjut')
                      //     : SizedBox(
                      //         width: 15,
                      //         height: 15,
                      //         child: CircularProgressIndicator(
                      //             valueColor: AlwaysStoppedAnimation<Color>(
                      //                 Colors.white))),
                      onPressed: () async {
                        if (pageSelected < 4) {
                          await getImageData();
                          print(photoList);
                          if (pageSelected < 3) {
                            setState(() {
                              pageSelected++;
                            });
                          }
                        }
                        setState(() {
                          _imageFile = null;
                          weightValue = null;
                          type = page[pageSelected];
                        });
                        if (photoList.length >= 4) {
                          print(wasteData);
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) {
                                return RecapImage(
                                  photoList: photoList,
                                  wasteData: wasteData,
                                );
                              },
                            ),
                          );
                          // await uploadData(wasteData);
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
