import 'package:flutter/material.dart';
import 'package:namer_app/geolocator.dart';

class RecapImage extends StatefulWidget {
  final List<Map<String, dynamic>> photoList;
  const RecapImage({super.key, required this.photoList});

  @override
  State<RecapImage> createState() => _RecapImageState();
}

class _RecapImageState extends State<RecapImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rekap Foto'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: GridView.builder(
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemCount: widget.photoList.length,
          itemBuilder: (BuildContext context, int index) {
            final image = widget.photoList[0]['filename'].path;
            return Image.asset(image);
          },
        ),
      ),
    );
  }
}

