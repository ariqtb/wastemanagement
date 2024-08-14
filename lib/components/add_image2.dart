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

File? _imageFile;
List<Map<String, dynamic>> photoList = [];
int mainPageSelected = 0;

class AddImage extends StatefulWidget {
  final String idWaste;
  AddImage({super.key, required this.idWaste});

  @override
  State<AddImage> createState() => AddImageState();
}

class AddImageState extends State<AddImage> {
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
              _imageFile != null
                  ? Image.file(
                      _imageFile!,
                      height: 200,
                    )
                  : Column(
                      children: [
                        Container(
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
                      ],
                    ),
              // SizedBox(
              //   height: 50,
              // ),
              // Row(
              //   children: [
              Column(
                children: [
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
                                  print("waduh${weightValue}");
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        child: Icon(
                          Icons.add,
                        ),
                        onPressed: () {
                          setState(() {
                            if (weightController.text.toString() != null) {
                              weightTotal += num.tryParse(
                                  weightController.text.toString())!;
                              weightController.clear();
                              weightValue = weightTotal;
                            }
                            print("KACAW: ${weightTotal}");
                            print("KACAW: ${weightValue}");
                          });
                        },
                      )
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Total Berat: ",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              "${weightTotal}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          child: Icon(Icons.refresh),
                          onPressed: () {
                            setState(() {
                              weightTotal = 0;
                            });
                          },
                        )
                      ],
                    ),
                  ),
                ],
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
                        if (weightValue != null && _imageFile == null) {
                            await alertDialog(context, [
                              ...[
                                'Peringatan',
                                'Ambil foto terlebih dahulu'
                              ]
                            ]);
                            return;
                          }
                        if (mainPageSelected < page.length) {
                          await addImageList(type, _imageFile,
                              weightValue, photoList);
                          // if (mainPageSelected < 8) {
                          if (mainPageSelected + 1 == page.length) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) {
                                  return RecapImage(
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
                              weightTotal =0;
                            });
                          }
                          // }
                        }
                        // setState(() {});
                        // num valOrganik = 0;
                        // num valAnorganik = 0;
                        // print(" VALUEEE ${photoList.runtimeType}");
                        // for (int i = 0; i < photoList.length; i++) {
                        //   Map<String, dynamic> data = photoList[i];
                        //   String typephoto = data['typePhoto'];
                        //   // num weight = data['weight'];

                        //   if (typephoto == 'Hewani' ||
                        //       typephoto == 'Hijauan' ||
                        //       typephoto == 'Keras') {
                        //     valOrganik += data['weight']!;
                        //     print(
                        //         'aaaaa ${photoList[0]['weight'] = valOrganik}');
                        //   }
                        //   if (typephoto == 'Valuable' ||
                        //       typephoto == 'Non-Valuable') {
                        //     valAnorganik += data['weight']!;
                        //     print(
                        //         'bbbb ${photoList[4]['weight'] = valAnorganik}');
                        //   }
                        // }
                        // print(" VALUEEEorganik ${valOrganik}");
                        // print(" VALUEEEanorganik ${valAnorganik}");
                        // setState(() {
                        //   mainPageSelected = 0;
                        // });
                        else {
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
                  // : Flexible(
                  //     child: IconButton(
                  //       iconSize: 110,
                  //       icon: const Icon(
                  //         Icons.play_arrow_rounded,
                  //       ),
                  //       onPressed: () async {
                  //         // if (num.tryParse(weightController.text) != null &&
                  //         print("halo ${weightValue}");
                  //         print("halo2 ${_imageFile}");
                  //         if (weightValue != null && _imageFile == null) {
                  //           await alertDialog(context, [
                  //             ...[
                  //               'Peringatan',
                  //               'Ambil foto terlebih dahulu'
                  //             ]
                  //           ]);
                  //           return;
                  //         }
                  //         if (mainPageSelected == 0 &&
                  //             num.tryParse(weightController.text) != null) {
                  //           setState(() {
                  //             mainPageSelected = 3;
                  //           });
                  //           print("2object");
                  //         }
                  //         if (mainPageSelected == 4 &&
                  //             num.tryParse(weightController.text) != null) {
                  //           setState(() {
                  //             mainPageSelected = 6;
                  //           });
                  //           print("object");
                  //         }
                  //         if (mainPageSelected < 9) {
                  //           await addImageList(
                  //               type,
                  //               _imageFile,
                  //               num.tryParse(weightController.text),
                  //               photoList);
                  //           if (mainPageSelected < 8) {
                  //             setState(() {
                  //               weightValue = 0.0;
                  //               weightController.text = '';
                  //               mainPageSelected++;
                  //             });
                  //           }
                  //         }
                  //         setState(() {
                  //           _imageFile = null;
                  //           weightValue = null;
                  //           type = page[mainPageSelected];
                  //         });
                  //         // print("pageselected: ${pageSelected}");
                  //         if (photoList.length >= 9) {
                  //           Navigator.of(context).pushReplacement(
                  //             MaterialPageRoute(
                  //               builder: (context) {
                  //                 return RecapImage(
                  //                     photoList: photoList,
                  //                     idWaste: idWaste);
                  //               },
                  //             ),
                  //           );
                  //         }
                  //       },
                  //     ),
                  //   ),
                  // mainPageSelected == 0 || mainPageSelected == 1
                  //     ? Flexible(
                  //         child: IconButton(
                  //         iconSize: 70,
                  //         icon: const Icon(
                  //           Icons.menu_open_outlined,
                  //         ),
                  //         onPressed: () async {
                  //           await addImageList(type, _imageFile,
                  //               num.tryParse(weightController.text), photoList);
                  //           Navigator.of(context).push(
                  //             MaterialPageRoute(
                  //               builder: (context) {
                  //                 return AddImageDetail(
                  //                     noDetail: noDetail,
                  //                     idWaste: widget.idWaste);
                  //               },
                  //             ),
                  //           );
                  //           // setState(() {
                  //           //   mainPageSelected++;
                  //           // });
                  //           // print("object11111111 ${mainPageSelected}");
                  //         },
                  //       ))
                  //     : SizedBox()
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
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(Colors.lightGreen)),
                onPressed: getImageFromCamera,
                child: Text('Ambil Foto'),
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
                                  return AddImage(idWaste: widget.idWaste);
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
