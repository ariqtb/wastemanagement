import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../conn/conn_api.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:namer_app/pages/history_pickup.dart';
import '../providers/waste_class.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path/path.dart' as path;
import 'package:async/async.dart';
import 'petugas/recap_image.dart';
import '../components/alert.dart';

class ImagePickerScreen extends StatefulWidget {
  final Map<String, dynamic> datas;
  ImagePickerScreen({required this.datas});

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  String? type;
  File? _imageFile;
  double? weightValue;
  int selectedIndex = 0;
  late String idWaste;
  final picker = ImagePicker();
  bool isLoading = false;
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

  Future<void> getImageData() async {
    if (_imageFile != null) {
      // String filename = basename(_imageFile!.path);

      photoList.add(
          {'typePhoto': type, 'filename': _imageFile, 'weight': weightValue});
    }
    setState(() {
      _imageFile = null;
      weightValue = null;
      print('photoList.length');
      print(photoList.length);
      print(photoList);
      // selectedIndex++;
    });
  }

  Future<void> uploadData(Map<String, dynamic> datas) async {
    // return print(datas['recorded']);
    // try {
    //   var response = await post(
    //       Uri.parse("https://wastemanagement.tubagusariq.repl.co/waste/save"),
    //       body: jsonEncode(datas));
    //   if (response.statusCode == 200) {
    //     print(response.body);
    //     print(response.statusCode);
    //     // return _showDialogSuccess();
    //   } else {
    //     print('error deh ${response.statusCode}');
    //   }
    // } catch (e) {
    //   return print(e.toString());
    // }
    var request =
        http.MultipartRequest('POST', Uri.parse('${API_URL}/waste/save'));

    // request.fields['pengepul'] = datas['pengepul'];
    // request.fields['date'] = datas['date'];
    // String location = jsonEncode(datas['location']);
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
    ;

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
      'pengepul': datas['pengepul'],
      'date': datas['date'],
      'location': jsonEncode(datas['location']),
      'image': jsonEncode(imageMap),
      'recorded': datas['recorded'].toString()
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

  showModal(context) {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    showModalBottomSheet(
      isDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200.0,
          color: Colors.white,
          child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Data sedang disimpan'),
              SizedBox(
                height: 20,
              ),
              CircularProgressIndicator()
            ]),
          ),
        );
      },
    );
  }

  toNextPage(context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return SubmitPage();
        },
      ),
    );
  }

  Future<void> onEachPage(int index) async {
    if (index >= 3) {
      print('dah selesai semua');
    }
  }

  @override
  void initState() {
    super.initState();
    wasteData = widget.datas;
    // print(idWaste);
    onEachPage(selectedIndex);
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
      case 2:
        type = 'b3';
        break;
      case 3:
        type = 'residu';
        break;
      // case 4:
      //   type = 'done';
      //   break;
      default:
        // throw UnimplementedError('No Page Anymore');
        return Scaffold();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return SubmitPage();
            },
          ),
        );
      // selectedIndex = 0;
      // break;
    }
    // type = 'anorganik';
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
                        if (photoList.length == 4) {
                          await uploadData(wasteData);
                          toNextPage(context);
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
