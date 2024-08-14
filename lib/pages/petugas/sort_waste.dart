import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:namer_app/pages/produsen/homepage/homepage.dart';
import '../../conn/conn_api.dart';

import 'package:image_picker/image_picker.dart';
import '../../providers/waste_class.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:async/async.dart';
import '../../components/alert.dart';
// import '../providers/get_image.dart';
import '../../pages/petugas/homepage.dart';
import '../../providers/imagePicker.dart';
import '../../pages/petugas/recap_image.dart';

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
  List<File>? imageList = [];

  List<String> titles = [
    'anorganik',
    'organik',
    'b3',
    'residu',
  ];

  Map<String, dynamic> checkboxes = {
    'anorganik': false,
    'organik': false,
    'b3': false,
    'residu': false,
  };

  Map<String, double> weight = {
    'anorganik': 0,
    'organik': 0,
    'b3': 0,
    'residu': 0,
  };
  List<double> weightlist = [
    0.5,0.5,0.5,0.5
  ];

  List<String> page = ['Anorganik', 'Organik', 'B3', 'Residu'];
  int pageSelected = 0;

  Future getImageFromCamera(imageType) async {
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

  bool checked = false;
  bool isExpanded = false;

  List<Map<String, dynamic>> imageData = [];
  List<String> selectedImageTypes = [];
// Checkbox onChanged callback
  void handleCheckboxChange(bool isChecked, String item) {
    if (isChecked) {
      // Add the item to the selectedItems list
      selectedImageTypes.add(item);
      imageData.add({'photoType': item});
    } else {
      // Remove the item from the selectedItems list
      selectedImageTypes.remove(item);
      imageData.removeWhere((data) => data['photoType'] == item);
    }
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
          // title: Text('${page[pageSelected]}'),
        ),
        body: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ExpansionTile(
            //   title: CheckboxListTile(
            //     title: Text(
            //       'Sub title',
            //     ),
            //     value: checked,
            //     onChanged: (bool? value) {
            //       setState(() {
            //         checked = value!;
            //       });
            //     },
            //     controlAffinity: ListTileControlAffinity.leading,
            //   ),
            //   children: <Widget>[
            //     ListTile(
            //       title: Text('data'),
            //     )
            //   ],
            //   onExpansionChanged: (bool expanded) {
            //     setState(() {
            //       isExpanded = expanded;
            //     });
            //   },
            //   initiallyExpanded: isExpanded,
            // ),

            Flexible(
              child: Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                  child: ListView.builder(
                    itemCount: titles.length,
                    itemBuilder: (context, index) {
                      String title = titles[index];
                      bool isChecked = checkboxes[title] ?? false;
                      double? weightVal = weight[index];
                      print("WEIGHT ${weightlist}");
// CheckboxListTile(
//           title: Text(title),
//           value: isChecked,
//           onChanged: onChanged,
//           controlAffinity: ListTileControlAffinity.leading,
//         ),
//         AnimatedContainer(
//           duration: Duration(milliseconds: 200),
//           height: isChecked ? 100 : 0,
//           child: ListView(
//             shrinkWrap: true,
//             children: <Widget>[
//               ListTile(
//                 title: Text('Child 2'),
//               ),
//             ],
//           ),
//         ),
                      return Column(
                        children: [
                          CheckboxListTile(
                            title: Text(title),
                            value: isChecked,
                            onChanged: (value) {
                              setState(() {
                                checkboxes[title] = value!;
                                handleCheckboxChange(value, titles[index]);
                                print(selectedImageTypes);
                                print(imageData);
                              });
                            },
                          ),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            height: isChecked ? 50 : 0,
                            child: ListView(
                              shrinkWrap: true,
                              children: <Widget>[
                                DropdownButtonHideUnderline(
                                  child: SingleChildScrollView(
                                    physics: BouncingScrollPhysics(),
                                    child: DropdownButton<double>(
                                      value: weightVal,
                                      items: items
                                          .map((double value) =>
                                              DropdownMenuItem<double>(
                                                value: value,
                                                child: Text('${value} Kg'),
                                              ))
                                          .toList(),
                                      hint: Text('Select weight'),
                                      onChanged: (double? value) {
                                        setState(() {
                                          weightVal = value;
                                        });
                                        print(weightVal);
                                      },
                                    ),
                                  ),
                                ),
                                ListTile(
                                  title: Text('Child 2'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  )
                  // ListView.builder(
                  //     itemCount: titles.length,
                  //     itemBuilder: (context, index) {
                  //       String title = titles[index];
                  //       bool isExpand = false;
                  //       bool isChecked = checkboxes[title] ?? false;
                  //       return Card(
                  //         child: Column(
                  //           children: [
                  //             CheckboxListTile(
                  //               title: Text('anorganik'),
                  //               value: isChecked,
                  //               onChanged: (bool? value) {
                  //                 setState(() {
                  //                   // checked = value!;
                  //                   isExpand = value!;
                  //                   checkboxes[title] = value;
                  //                 });
                  //               },
                  //               controlAffinity: ListTileControlAffinity.leading,
                  //             ),
                  //             AnimatedContainer(
                  //               duration: Duration(milliseconds: 200),
                  //               height: isExpand ? 100 : 0,
                  //               child: ListView(
                  //                 shrinkWrap: true,
                  //                 children: <Widget>[
                  //                   ListTile(
                  //                     title: Text('Child 1'),
                  //                   ),
                  //                   ListTile(
                  //                     title: Text('Child 2'),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       );
                  //     }),
                  ),
            ),
            Column(
              children: [],
            ),

            // ElevatedButton(
            //   onPressed: () async {
            //     await getImageFromCamera(_imageFile);
            //   },
            //   child: Text('Ambil Foto'),
            // ),
            // ElevatedButton(
            //   onPressed: () async {
            //     await getImageFromCamera(_imageFile);
            //   },
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
            // SizedBox(
            //   height: 30,
            // ),
            weightValue != null && selectedIndex < 4 && _imageFile != null
                ? IconButton(
                    iconSize: 110,
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                    ),
                    onPressed: () {},
                    //     onPressed: () async {
                    //   if (pageSelected < 4) {
                    //     await addImageList(
                    //         type, _imageFile, weightValue, photoList);
                    //     if (pageSelected < 3) {
                    //       setState(() {
                    //         pageSelected++;
                    //       });
                    //     }
                    //   }
                    //   setState(() {
                    //     _imageFile = null;
                    //     weightValue = null;
                    //     type = page[pageSelected];
                    //   });
                    //   // print("pageselected: ${pageSelected}");
                    //   if (photoList.length >= 4) {
                    //     print(photoList);
                    //     Navigator.of(context).push(
                    //       MaterialPageRoute(
                    //         builder: (context) {
                    //           return RecapImage(photoList: photoList, idWaste: idWaste);
                    //         },
                    //       ),
                    //     );
                    //   }
                    // },
                  )
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
                : Container(),
            isLoading ? showModal(context) : Container(),
          ],
        ),
      ),
    );
  }
}

class CheckboxExpansionTile extends StatelessWidget {
  final String title;
  final bool isChecked;
  final ValueChanged<bool?>? onChanged;
  final ValueChanged<bool>? onExpansionChanged;
  final List<Widget>? children;

  CheckboxExpansionTile({
    required this.title,
    required this.isChecked,
    this.onChanged,
    this.onExpansionChanged,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          title: Text(title),
          value: isChecked,
          onChanged: onChanged,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 200),
          height: isChecked ? 100 : 0,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                title: Text('Child 2'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
