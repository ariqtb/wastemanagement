import 'package:flutter/material.dart';
import 'upload_produsen.dart';
import 'handler/produsen.handler.dart';
import 'add_image.dart';

class SortingCheck extends StatefulWidget {
  const SortingCheck({super.key});

  @override
  State<SortingCheck> createState() => _SortingCheckState();
}

class _SortingCheckState extends State<SortingCheck> {
  bool isLoading = false;
  bool isLoading2 = false;
  bool buttonDisabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
          position: DecorationPosition.background,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.white, Colors.green.shade200],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          child: Container(
            padding: EdgeInsets.fromLTRB(15, 50, 15, 50),
            // alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (!buttonDisabled) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: IntrinsicWidth(
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Kembali',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'OpenSans',
                          ),
                        )
                      ],
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                      child: Text(
                        "Apakah anda memilah sampah anda?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'OpenSans',
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!buttonDisabled) {
                            setState(() {
                              isLoading2 = true;
                              buttonDisabled = true;
                            });
                            Map<String, dynamic> location = await addLocation();
                            setState(() {
                              isLoading2 = false;
                              buttonDisabled = false;
                            });
                            print(location);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) {
                                  // return UploadProdusen();
                                  return ImagePickerScreen(
                                    datas: location,
                                  );
                                },
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: isLoading2
                            ? SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white)))
                            : Text(
                                'Ya',
                                style: TextStyle(
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!buttonDisabled) {
                            setState(() {
                              isLoading = true;
                              buttonDisabled = true;
                            });
                            await uploadProdusenData();
                            setState(() {
                              isLoading = false;
                              buttonDisabled = true;
                            });
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) {
                                  return UploadProdusen();
                                },
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator())
                            : Text(
                                'Tidak',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
