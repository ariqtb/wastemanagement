import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:namer_app/geolocator.dart';
import '../../providers/imagePicker.dart';
import '../../components/alert.dart';
import 'recap_weight.dart';

class RecapImage extends StatefulWidget {
  final List<Map<String, dynamic>> photoList;
  final String idWaste;
  const RecapImage({super.key, required this.photoList, required this.idWaste});

  @override
  State<RecapImage> createState() => _RecapImageState();
}

class _RecapImageState extends State<RecapImage> {
  bool isLoading = false;
  String wasteid = '';
  List<Map<String, dynamic>> photoList = [];

    @override
  void initState() {
    super.initState();
    setState(() {
      wasteid = widget.idWaste;
      photoList = widget.photoList;
    });
  }

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
        appBar: AppBar(
          title: Text('Rekap Foto'),
        ),
        body: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: widget.photoList.length,
            itemBuilder: (BuildContext context, int index) {
              // final image = photoList[0]['filename'].path;
              // print(photoList);
              final imageUrl = widget.photoList[index]['filename'];
              final imageText = widget.photoList[index]['typePhoto'];
              final weightText = widget.photoList[index]['weight'];
    
              // return Image.file(image);
              return GridTile(
                child: ListView(
                  physics: ClampingScrollPhysics(),
                  // child: Stack(
                  children: [
                    // Positioned(
                    //   top: 50.0,
                    //   left: 0.0,
                    Center(child: Text('${imageText}')),
                    Container(
                      margin: EdgeInsets.fromLTRB(30, 5, 30, 0),
                            height: 170,
                      // decoration: BoxDecoration(
                      //   border: Border.all(
                      //     color: Colors.green.shade100,
                      //     width: 2.0,
                      //   ),
                      // ),
                      child: Image.file(imageUrl,fit: BoxFit.cover),
                    ),
                  ],
                  // ),
                ),
              );
            },
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
          width: 120,
          height: 70,
          child: FloatingActionButton(
            onPressed: () async {
               Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return RecapWeight(
                      photoList: photoList,
                      idWaste: wasteid,
                    );
                  },
                ),
              );
              // setState(() {
              //   isLoading = true;
              // });
              // await uploadImages(widget.idWaste, widget.photoList);
              // setState(() {
              //   isLoading = false;
              // });
              // Navigator.of(context).pushReplacement(
              //   MaterialPageRoute(
              //     builder: (context) {
              //       return SubmitPage();
              //     },
              //   ),
              // );
            },
            backgroundColor: Colors.green,
            child: isLoading
                ? SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                : Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
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
        body: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          'Selesai',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
            alignment: Alignment.center,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(80),
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(''),
            )),
      ],
    ));
  }
}
