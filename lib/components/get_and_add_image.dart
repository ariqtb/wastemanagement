import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:namer_app/pages/petugas/recap_image2.dart';
import 'package:namer_app/pages/produsen/homepage/homepage.dart';
import '../conn/conn_api.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';
import '../providers/waste_class.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:async/async.dart';
import '../components/alert.dart';
// import '../providers/get_image.dart';
import '../pages/petugas/homepage.dart';
import '../providers/imagePicker.dart';
import '../pages/petugas/recap_image.dart';

File? _imageFile;
List<Map<String, dynamic>> photoList = [];
int mainPageSelected = 0;

class GetAndAddImage extends StatefulWidget {
  final String idWaste;
  GetAndAddImage({super.key, required this.idWaste});

  @override
  State<GetAndAddImage> createState() => GetAndAddImageState();
}

class GetAndAddImageState extends State<GetAndAddImage> {
  String type = 'Organik';
  num? weightValue;
  num weightTotal = 0;
  int selectedIndex = 0;
  String idWaste = '';
  final picker = ImagePicker();
  bool isLoading = false;
  List<int> bytesPhoto = [];
  bool isDone = false;
  Map<String, String> filesInfo = {};
  Map<String, dynamic> wasteData = {};
  int noDetail = 0;

  List<String> page = ['Organik', 'Anorganik', 'B3', 'Residu'];
  List<String> page2 = [
    'Organik',
    'Hewani',
    'Hijauan',
    'Keras',
    'Anorganik',
    'Valuable',
    'Non-Valuable',
    'B3',
    'Residu',
    'selesai'
  ];
  // int pageDetailSelected = 0;
  // bool onDetail = false;

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

  void itung(File _imageFile) async {
    final sizeInBytes = await _imageFile.length();
    final sizeInKb = sizeInBytes / 1024;
    print('File size in bytes: $sizeInBytes');
    print('File size in KB: $sizeInKb');
  }

  List<Map<String, dynamic>> dataCache = [];
  Future getImageData() async {
    final response = await http.get(
        Uri.parse('${API_URL}/waste/getphotodata/${page[mainPageSelected]}'));
    if (response.statusCode == 200) {
    print(response.body);
      List<dynamic> responsedata = json.decode(response.body);
      if (mounted) {
        setState(() {
          // isLoading = true;
          dataCache = responsedata.cast<Map<String, dynamic>>();
          ;
        });
        return 1;
      }
    } else {
      print("Failed to load data. status code:${response.statusCode}");
      return 0;
    }
  }

  Future setImageData() async {
    final response =
        await http.get(Uri.parse('${API_URL}/waste/sendphotodata'));
    if (response.statusCode == 200) {
      if (mounted) {
        List<Map<String, dynamic>> responsedata =
            json.decode(response.body).cast<Map<String, dynamic>>().toList();
        print("${responsedata.runtimeType}");
        // if (json.decode(response.body)['cache'] != null) {
        setState(() {
          photoList = responsedata;
          // isLoading = true;
        });
        // }
      }
    } else {
      print("Failed to load data. status code:${response.statusCode}");
    }
  }

  @override
  void initState() {
    super.initState();
    _imageFile = null;
    photoList = [];
    mainPageSelected = 0;
    idWaste = widget.idWaste;
  }

  final weightController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    List<num> items = List<num>.generate(200, (index) => 0.5 + index / 2);

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
          title: Text('${page[mainPageSelected]}'),
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                child: Text(
                  "Sampah ${page[mainPageSelected]}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(),
              // Container(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(100),
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () async {
                    var setdata = await getImageData();
                    if (setdata == 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Data berhasil diambil')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Data tidak terambil karena kosong')));
                    }
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (BuildContext context) => RecapWeight(
                    //             idWaste: id,
                    //             dataCache: dataCache
                    //           )),
                    // );
                  },
                  child: Container(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // mainPageSelected == 8
                  //     ?
                  Flexible(
                    child: IconButton(
                      iconSize: 110,
                      icon: const Icon(
                        Icons.play_arrow_rounded,
                      ),
                      onPressed: () async {
                        if (mainPageSelected < page.length) {
                          // await addImageList(
                          //     type, _imageFile, weightValue, photoList);
                          // if (mainPageSelected < 8) {
                          if (mainPageSelected + 1 == page.length) {
                            print("HALO SAYA DAPID DISINI");

                            await setImageData();
                            print("INI PHOTO LSIT: ${photoList}");
                            if (photoList.length == 0) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Data gagal diproses karena kosong')));
                              return;
                            }
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) {
                                  return RecapImage2(
                                      photoList: photoList, idWaste: idWaste);
                                },
                              ),
                            );
                          } else {
                            setState(() {
                              weightValue = 0.0;
                              weightController.text = '';
                              mainPageSelected++;
                              _imageFile = null;
                              weightValue = null;
                              type = page[mainPageSelected];
                              weightTotal = 0;
                            });
                          }
                          // }
                        } else {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) {
                                return RecapImage(
                                    photoList: photoList, idWaste: idWaste);
                              },
                            ),
                          );
                        }
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddImageDetail extends StatefulWidget {
  final int noDetail;
  final String idWaste;
  // const AddImageDetail({super.key});
  const AddImageDetail({required this.noDetail, required this.idWaste});

  @override
  State<AddImageDetail> createState() => _AddImageDetailState();
}

class _AddImageDetailState extends State<AddImageDetail> {
  String type = '';
  num? weightValue;
  int selectedIndex = 0;
  String idWaste = '';
  final picker = ImagePicker();
  bool isLoading = false;
  List<int> bytesPhoto = [];
  List<dynamic> page = [];
  bool isDone = false;
  Map<String, String> filesInfo = {};
  Map<String, dynamic> wasteData = {};
  List<num> items = List<num>.generate(200, (index) => 0.5 + index / 2);
  final weightController = TextEditingController();
  int detailPageSelected = 0;

  List<String> pageOrganik = [
    'Hewani',
    'Hijauan',
    'Keras',
  ];
  List<String> pageAnorganik = [
    'Valuable',
    'Non-Valuable',
  ];

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("NODETAIL: ${widget.noDetail}");
    print("LIST: ${photoList}");
    if (widget.noDetail == 0) {
      page = pageOrganik;
    } else {
      page = pageAnorganik;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final pop = await confirmDialog(context, [
          ...['Konfirmasi', 'Apakah anda ingin membatalkan aksi?']
        ]);
        if (pop! == true) {
          photoList.removeAt(widget.noDetail);
          return pop;
        } else if (pop == false) {
          return pop;
        } else {
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: true,
            backgroundColor: Colors.lightGreen,
            title: widget.noDetail == 0
                ? Text('${pageOrganik[detailPageSelected]}')
                : Text('${pageAnorganik[detailPageSelected]}')),
        body: Padding(
          padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
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
                        border: Border.all(color: Colors.lightGreen, width: 3),
                      ),
                      child: Text('Belum ada foto yang dipilih')),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: weightController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Berat Sampah',
                      ),
                      onChanged: (value) {
                        // print(value);
                        print(
                            "controller: ${weightController.text.toString()}");
                        print(
                            "controller: ${num.tryParse(weightController.text).runtimeType}");
                        //     setState(() {
                        // weightValue =
                        //     num.parse(weightController.text.toString());

                        //     });
                        // weightController.text = value;
                      },
                    ),
                  ),
                  Column(
                    children: [
                      // Container(
                      //   child: Text('Masukkan berat'),
                      // ),
                      DropdownButtonHideUnderline(
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: DropdownButton<num>(
                            // value: weightValue,
                            items: items
                                .map((num value) => DropdownMenuItem<num>(
                                      value: value,
                                      child: Text('${value} Kg'),
                                    ))
                                .toList(),
                            hint: Text('Berat/Kg'),
                            onChanged: (num? value) {
                              setState(() {
                                weightValue = value;
                                weightController.text = value.toString();
                              });
                              print(weightValue);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              detailPageSelected == 8
                  ? Flexible(
                      child: IconButton(
                        iconSize: 110,
                        icon: const Icon(
                          Icons.play_arrow_rounded,
                        ),
                        onPressed: () async {},
                      ),
                    )
                  : Flexible(
                      child: IconButton(
                        iconSize: 110,
                        icon: const Icon(
                          Icons.play_arrow_rounded,
                        ),
                        onPressed: () async {
                          if (detailPageSelected == page.length - 1) {
                            // setState(() {
                            //   mainPageSelected++;
                            // });
                            // print('WAKWAWWWWW');
                            return Navigator.pop(context);
                            await Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) {
                                  return GetAndAddImage(
                                      idWaste: widget.idWaste);
                                },
                              ),
                            );
                          }
                          await addImageListDetail(
                              type: page[detailPageSelected],
                              imageFile: _imageFile,
                              weight: num.tryParse(weightController.text),
                              imageList: photoList,
                              index: widget.noDetail);
                          setState(() {
                            _imageFile = null;
                            weightController.text = '';
                            detailPageSelected++;
                            type = page[detailPageSelected];
                          });
                        },
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
