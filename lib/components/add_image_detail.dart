import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
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

class AddImage extends StatefulWidget {
  final String idWaste;
  AddImage({super.key, required this.idWaste});

  @override
  State<AddImage> createState() => AddImageState();
}

class AddImageState extends State<AddImage> {
  String type = 'Anorganik';
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
  List<Map<String, dynamic>> photoList = [];

  List<String> pageDetail = ['Organik', 'Anorganik', 'B3', 'Residu', 'selesai'];
  List<String> page = ['Hewani', 'Hijauan', 'Keras','Valuable', 'Non-Valuable'];
  List<String> pageDetailAnorganik = ['Valuable', 'Non-Valuable'];
  int pageSelected = 0;
  int pageDetailSelected = 0;
  bool onDetail = false;

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

  @override
  void initState() {
    super.initState();
    idWaste = widget.idWaste;
  }

  final weightController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    List<double> items = List<double>.generate(200, (index) => 0.5 + index / 2);

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
          title: Text(
            onDetail ? '${pageDetail[pageDetailSelected]}' : '${page[pageSelected]}' 
            ),
        ),
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
              // SizedBox(
              //   height: 50,
              // ),
              // Row(
              //   children: [
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
                        weightValue = double.parse(value);
                        // weightController.text = value;
                        print(weightValue);
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
                          child: DropdownButton<double>(
                            // value: weightValue,
                            items: items
                                .map((double value) => DropdownMenuItem<double>(
                                      value: value,
                                      child: Text('${value} Kg'),
                                    ))
                                .toList(),
                            hint: Text('Berat/Kg'),
                            onChanged: (double? value) {
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
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              // pageSelected != 0 ? Transform.rotate(
              //   angle: 180 * math.pi / 180,
              //   child: IconButton(
              //     iconSize: 110,
              //     icon: const Icon(
              //       Icons.play_arrow_rounded,
              //     ),
              //     onPressed: () async {
              //         if (pageSelected < 4 && pageSelected > 0 ) {
              //           setState(() {
              //             pageSelected--;
              //           });
              //         }
              //       setState(() {
              //         _imageFile = null;
              //         weightValue = null;
              //         type = page[pageSelected];
              //       });
              //       // print("pageselected: ${pageSelected}");
              //       if (photoList.length >= 4) {
              //         print(photoList);
              //         Navigator.of(context).pushReplacement(
              //           MaterialPageRoute(
              //             builder: (context) {
              //               return RecapImage(
              //                   photoList: photoList, idWaste: idWaste);
              //             },
              //           ),
              //         );
              //       }
              //     },
              //   ),
              // ) : Container(),
              Flexible(
                child: IconButton(
                  iconSize: 110,
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                  ),
                  onPressed: () async {
                    if(pageSelected == 0 && weightValue == null) {
                      setState(() {
                        onDetail = true;
                      });
                      return;
                    }
                    if (pageSelected < 4) {
                      await addImageList(
                          type, _imageFile, weightValue, photoList);
                      if (pageSelected < 3) {
                        setState(() {
                          weightValue = 0.0;
                          weightController.text = '';
                          pageSelected++;
                        });
                      }
                    }
                    setState(() {
                      _imageFile = null;
                      weightValue = null;
                      type = page[pageSelected];
                    });
                    // print("pageselected: ${pageSelected}");
                    if (photoList.length >= 4) {
                      print(photoList);
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
              //   ],
              // ),
              // ElevatedButton(
              //     child: Text('Lanjut'),
              //     onPressed: () async {
              //       if (pageSelected < 4) {
              //         await addImageList(
              //             type, _imageFile, weightValue, photoList);
              //         if (pageSelected < 3) {
              //           setState(() {
              //             pageSelected++;
              //           });
              //         }
              //       }
              //       setState(() {
              //         _imageFile = null;
              //         weightValue = null;
              //         type = page[pageSelected];
              //       });
              //       // print("pageselected: ${pageSelected}");
              //       if (photoList.length >= 4) {
              //         print(photoList);
              //         Navigator.of(context).push(
              //           MaterialPageRoute(
              //             builder: (context) {
              //               return RecapImage(photoList: photoList, idWaste: idWaste);
              //             },
              //           ),
              //         );
              //       }
              //     },
              //   )

              // isLoading ? showModal(context) : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
