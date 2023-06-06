import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../providers/get_image.dart';


class GetOrganikImage extends StatefulWidget {
  final Map<String, dynamic> datas;
  const GetOrganikImage({super.key, required this.datas});

  @override
  State<GetOrganikImage> createState() => _GetOrganikImageState();
}

class _GetOrganikImageState extends State<GetOrganikImage> {
  String? type;
  double? weightValue;
  File? _imageFile;
  int selectedIndex = 0;
  final picker = ImagePicker();
    bool isLoading = false;
  bool isDone = false;
  List<Map<String, dynamic>> photoList = [];

  @override
  Widget build(BuildContext context) {
    List<double> items = List<double>.generate(50, (index) => 0.5 + index / 2);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('page[selectedIndex]}'),
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
                      if (photoList.length <= 3) {
                        // await getImageData();
                      }
                      print('oy');
                      if (photoList.length >= 4) {
                        // await uploadData(wasteData);
                        // toNextPage(context);
                        setState(() {
                          isDone = true;
                        });
                      }
                    },
                  )
                : Container(),
            isLoading ? Container() : Container(),
          ],
        ),
      ),
    );
  }
}
