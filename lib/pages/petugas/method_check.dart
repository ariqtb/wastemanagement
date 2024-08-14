import 'package:flutter/material.dart';
import 'package:namer_app/components/add_image2.dart';
import 'package:namer_app/components/get_and_add_image.dart';
import 'package:namer_app/pages/petugas/get_data_view.dart';

class MethodCheck extends StatefulWidget {
  final id;
  const MethodCheck({super.key, required this.id});

  @override
  State<MethodCheck> createState() => _MethodCheckState();
}

class _MethodCheckState extends State<MethodCheck> {
  bool isLoading = false;
  bool isLoading2 = false;
  bool buttonDisabled = false;
  String? id;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    id = widget.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Metode Pemilahan"),
      ),
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
                // Container(
                //   child: ElevatedButton(
                //     onPressed: () {
                //       if (!buttonDisabled) {
                //         Navigator.of(context).pop();
                //       }
                //     },
                //     child: IntrinsicWidth(
                //       child: Row(
                //         children: [
                //           Icon(
                //             Icons.arrow_back_ios_new_rounded,
                //             size: 16,
                //             color: Colors.black,
                //           ),
                //           SizedBox(
                //             width: 10,
                //           ),
                //           Text(
                //             'Kembali',
                //             style: TextStyle(
                //               color: Colors.black,
                //               fontFamily: 'OpenSans',
                //             ),
                //           )
                //         ],
                //       ),
                //     ),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.white,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(30.0),
                //       ),
                //     ),
                //   ),
                // ),
                Container(),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                      child: Text(
                        "Pilih metode pemilahan sampah",
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
                            // setState(() {
                            //   isLoading2 = true;
                            //   buttonDisabled = true;
                            // });
                            // Map<String, dynamic> location = await addLocation();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  // return GetDataWaste(id: id!);
                                  return GetAndAddImage(idWaste: id!);
                                  // return AddImage(
                                  //     idWaste: data[index]
                                  //         ['_id']);
                                },
                              ),
                            );
                            // setState(() {
                            //   isLoading2 = false;
                            //   buttonDisabled = false;
                            // });
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
                                'Otomatis',
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
                            // setState(() {
                            //   isLoading = true;
                            //   buttonDisabled = true;
                            // });
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  // return GetDataWaste(id: id!);
                                  return AddImage(
                                      idWaste: id!);
                                },
                              ),
                            );
                            // setState(() {
                            //   isLoading = false;
                            //   buttonDisabled = true;
                            // });
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
                                'Manual',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                Container()
              ],
            ),
          )),
    );
  }
}
