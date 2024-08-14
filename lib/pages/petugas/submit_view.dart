import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SubmitFinal extends StatefulWidget {
  final String id;
  final List<Map<String, dynamic>> dataWaste;
  SubmitFinal({super.key, required this.id, required this.dataWaste});

  @override
  State<SubmitFinal> createState() => _SubmitFinalState();
}

class _SubmitFinalState extends State<SubmitFinal> {
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
        child: Center(
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 50, 20, 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tekan untuk ambil data',
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
                SizedBox(
                  height: 35,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(80),
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () async {
                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (BuildContext context) =>
                      //           RecapWeight(idWaste: id,)),
                      // );
                    },
                    child: Container(),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}