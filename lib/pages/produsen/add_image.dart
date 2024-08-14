import 'dart:io';
import 'dart:async';
import 'dart:convert';
// import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:namer_app/components/geolocator.dart';
import 'package:namer_app/pages/produsen/home.dart';
import 'package:namer_app/pages/produsen/recap_sort.dart';
import 'package:namer_app/providers/waste_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'handler/produsen.handler.dart';

class ImagePickerScreen extends StatefulWidget {
  // final Map<String, dynamic> datas;
  // ImagePickerScreen({required this.datas});
  const ImagePickerScreen({super.key});

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
  bool isLoading = true;
  bool isLoading2 = false;
  List<int> bytesPhoto = [];
  bool isDone = false;
  Map<String, String> filesInfo = {};
  Map<String, dynamic> wasteData = {};
  List<dynamic> color = [
    Colors.yellow,
    Colors.green,
    Colors.redAccent,
    Colors.grey
  ];

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
  String include = "1";
  String notInclude = "0";

  List<String> page = ['Anorganik', 'Organik', 'B3', 'Residu'];
  int pageSelected = 0;

  int? pageCache;
  String? dataCache;

  Future getPageCache() async {
    final prefs = await SharedPreferences.getInstance();
    
    pageCache = int.tryParse(prefs.getString('produsen-sort-page')!);
    dataCache = prefs.getString('produsen-sort-data')!;

    if(pageCache != null) {
      setState(() {
        pageSelected = pageCache!;
        photoList = List<Map<String,dynamic>>.from(jsonDecode(dataCache!));
        type = page[pageSelected];
      });
    }
      // print("HALO INI PAGE SELECTED ${pageSelected}");
      // print("HALO INI PAGE SELECTED2 ${pageCache}");
      // print(jsonDecode(dataCache!).runtimeType);
  }

  Future<void> getImageData(status) async {
    if (_imageFile != null) {
      // String filename = basename(_imageFile!.path);

      photoList.add(
          {'typePhoto': type, 'filename': _imageFile, 'weight': weightValue});
    } else {
      photoList.add({'typePhoto': type, 'status': status});
    }
    setState(() {
      _imageFile = null;
      weightValue = null;
    });
  }

  Future<void> uploadFormRequest(wasteData) async {
    Map<String, dynamic> wasteData = await addLocation();
    wasteData['image'] = photoList;

    var request =
        http.MultipartRequest('POST', Uri.parse('${API_URL}/produsen/save2'));

    request.fields.addAll({
      'produsen_sampah': wasteData['produsen_sampah'],
      'date': wasteData['date'],
      'jalur': wasteData['jalur'],
      'location': jsonEncode(wasteData['location']),
      'image': jsonEncode(wasteData['image']),
      'picked_up': wasteData['picked_up'].toString()
    });

    final response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Photos and data uploaded successfully ${response.statusCode}');
      var responseBytes = await http.Response.fromStream(response);
      print(responseBytes.body);
    } else {
      print('Failed to upload photos and data: ${response.statusCode}');
      var responseBytes = await http.Response.fromStream(response);
      print(responseBytes.body);
    }
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
      String filename = getInfo['filename']!.path.split('/').last;
      imageMap.add({
        'typePhoto': getInfo['typePhoto'],
        'filename': filename,
        'weight': getInfo['weight']!
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
    getPageCache();
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
    // wasteData = widget.datas;
  }

  @override
  Widget build(BuildContext context) {
    List<double> items = List<double>.generate(50, (index) => 0.5 + index / 2);
return isLoading
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(), // Display a loading indicator
            ),
          )
        :
     WillPopScope(
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // _imageFile != null
              //     ? Image.file(
              //         _imageFile!,
              //         height: 200,
              //       )
              //     : Container(
              //         padding: EdgeInsets.all(20),
              //         decoration: BoxDecoration(
              //           border: Border.all(color: Colors.green, width: 3),
              //         ),
              //         child: Text('Belum ada foto yang dipilih')),
              // SizedBox(
              //   height: 20,
              // ),
              // ElevatedButton(
              //   onPressed: getImageFromCamera,
              //   child: Text('Ambil Foto'),
              // ),
              // SizedBox(
              //   height: 50,
              // ),
              // Container(
              //   child: Text('Masukkan berat'),
              // ),
              // DropdownButtonHideUnderline(
              //   child: SingleChildScrollView(
              //     physics: BouncingScrollPhysics(),
              //     child: DropdownButton<double>(
              //       value: weightValue,
              //       items: items
              //           .map((double value) => DropdownMenuItem<double>(
              //                 value: value,
              //                 child: Text('${value} Kg'),
              //               ))
              //           .toList(),
              //       hint: Text('Select weight'),
              //       onChanged: (double? value) {
              //         setState(() {
              //           weightValue = value;
              //         });
              //         print(weightValue);
              //       },
              //     ),
              //   ),
              // ),
              Text(
                "${page[pageSelected]}",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
                child: ElevatedButton(
                    // style: ElevatedButton.styleFrom(
                    //   shape: CircleBorder(),
                    //   padding: EdgeInsets.all(80),
                    //   backgroundColor: Colors.redAccent,
                    // ),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        CircleBorder(),
                      ),
                      padding: MaterialStateProperty.all(EdgeInsets.all(80)),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(color[pageSelected]),
                    ),
                    onPressed: () async {
                      // print("ini yg baru${pageSelected}");
                      await getImageData(1);
                      print(photoList);
                      if (page.length != pageSelected + 1) {
                        pageSelected++;
                        print(wasteData);
                        setState(() {
                          type = page[pageSelected];
                        });
                      } else {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) {
                              return SubmitDone(photoList: photoList);
                            },
                          ),
                        );
                      }
                    },
                    child: Container()),
              ),
              // weightValue != null && selectedIndex < 4 && _imageFile != null
              //     ?
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    iconSize: 100,
                    icon: const Icon(Icons.rectangle),
                    onPressed: () async {
                      final pop = await confirmDialog(context, [
                        ...['Konfirmasi', 'Apakah anda ingin menunda aksi?']
                      ]);
                      final prefs = await SharedPreferences.getInstance();
                      if (pop == true) {
                        // prefs.remove('produsen-sort-page');
                        // prefs.remove('produsen-sort-data');
                        prefs.setString(
                            'produsen-sort-page', "${pageSelected}");
                        dataCache = jsonEncode(photoList);
                        prefs.setString(
                            'produsen-sort-data', "${dataCache}");
                        Navigator.of(context).pop();
                      } else {
                        false;
                      }
                      // return pop ?? false;
                      // await getImageData(0);
                      // if (page.length != pageSelected + 1) {
                      //   pageSelected++;
                      //   setState(() {
                      //     type = page[pageSelected];
                      //   });
                      // } else {
                      //   Navigator.of(context).pushReplacement(
                      //     MaterialPageRoute(
                      //       builder: (context) {
                      //         return SubmitDone(photoList: photoList);
                      //       },
                      //     ),
                      //   );
                      // }
                    },
                  ),
                  IconButton(
                    iconSize: 110,
                    icon: const Icon(
                      Icons.play_arrow,
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
                      await getImageData(0);
                      print(photoList);
                      if (page.length != pageSelected + 1) {
                        pageSelected++;
                        print(wasteData);
                        setState(() {
                          type = page[pageSelected];
                        });
                      } else {
                        // await uploadFormRequest(wasteData);
                        // Navigator.of(context).pushReplacement(
                        //   MaterialPageRoute(
                        //     builder: (context) {
                        //       return SubmitPage();
                        //     },
                        //   ),
                        // );
                        // print("WAHWAH ${photoList}");
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) {
                              return SubmitDone(photoList: photoList);
                            },
                          ),
                        );
                      }
                      // if (pageSelected < 4) {
                      //   await getImageData();
                      //   print(photoList);
                      //   if (pageSelected < 3) {
                      //     setState(() {
                      //       pageSelected++;
                      //     });
                      //   }
                      // }
                      // setState(() {
                      //   _imageFile = null;
                      //   weightValue = null;
                      //   type = page[pageSelected];
                      // });
                      // if (photoList.length >= 4) {
                      //   print(wasteData);
                      //   Navigator.of(context).pushReplacement(
                      //     MaterialPageRoute(
                      //       builder: (context) {
                      //         return SubmitPage();
                      //       },
                      //     ),
                      //   );
                      // Navigator.of(context).pushReplacement(
                      //   MaterialPageRoute(
                      //     builder: (context) {
                      //       return RecapImage(
                      //         photoList: photoList,
                      //         wasteData: wasteData,
                      //       );
                      //     },
                      //   ),
                      // );
                      // await uploadData(wasteData);
                      // }
                      // }
                      print('${photoList.length}');
                      // if (photoList.length >= 4) {
                      //   setState(() {
                      //     isDone = true;
                      //   });
                      // }
                    },
                  )
                ],
              ),
              //     : Container(),
              // isLoading ? showModal(context) : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

class SubmitDone extends StatefulWidget {
  final photoList;
  const SubmitDone({super.key, required this.photoList});

  @override
  State<SubmitDone> createState() => _SubmitDoneState();
}

class _SubmitDoneState extends State<SubmitDone> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final pop = await confirmDialog(context, [
          ...['Konfirmasi', 'Apakah anda ingin membatalkan aksi?']
        ]);
        return pop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 50, 20, 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                Container(
                  child: Text(
                    'Data Berhasil Diproses',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      // color: Colors.green,
                      fontFamily: 'OpenSans',
                      fontSize: 40,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      iconSize: 100,
                      icon: const Icon(Icons.rectangle),
                      onPressed: () {
                        // Navigator.of(context).pushReplacement(
                        //   MaterialPageRoute(
                        //     builder: (context) {
                        //       return RecapSort(photoList: widget.photoList);
                        //     },
                        //   ),
                        // );
                      },
                    ),
                    IconButton(
                      iconSize: 100,
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) {
                              return RecapSort(photoList: widget.photoList);
                            },
                          ),
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubmitPage extends StatelessWidget {
  const SubmitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 50, 20, 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Selesai',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.green,
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Sampah kamu sudah siap dan menunggu diambil petugas',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black, fontFamily: 'OpenSans', fontSize: 14),
              ),
              SizedBox(
                height: 35,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) {
                          return HomeIrt();
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text(
                    'Kembali',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
