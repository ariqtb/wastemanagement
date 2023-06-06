import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../utils/user_data_login.dart';

class DetailHistoryPickup extends StatelessWidget {
  final dynamic history;

  DetailHistoryPickup({super.key, this.history});

  List<dynamic> data = [];

  @override
  Widget build(BuildContext context) {
    List<dynamic> location = history['location'];

    print(location);
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Riwayat"),
      ),
      body: Container(
        color: Colors.grey[200],
        padding: EdgeInsets.all(15),
        child: Container(
          padding: EdgeInsets.all(3),
          child: Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      '${history['location'].length}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 35,
                          color: Colors.green),
                    ),
                  ],
                ),
                Icon(Icons.share_location_outlined),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      '${DateFormat('EEE, dd MMMM yy').format(DateTime.parse(history['date']))}',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    Text(
                        '${DateFormat('HH:mm').format(DateTime.parse(history['date']))}'),
                  ],
                ),
                // ElevatedButton(
                //   onPressed: () {},
                //   child: Container(
                //     padding: const EdgeInsets.all(2),
                //     child: Text(
                //       'Telah diproses',
                //       style: TextStyle(
                //         backgroundColor: Colors.green,
                //         fontSize: 12,
                //         // backgroundColor: Colors.green,
                //       ),
                //     ),
                //   ),
                // ),
                Container(
                  padding: EdgeInsets.fromLTRB(5, 2, 5, 2),
                  decoration: history['recorded']
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.green[100])
                      : BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.redAccent[100]),
                  child: history['recorded']
                      ? Text(
                          'Telah dipilah',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        )
                      : Text(
                          'Belum dipilah',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                ),
                Text("Daftar riwayat data",
                    style: TextStyle(color: Colors.black, fontSize: 14)),
                Divider(
                  color: Colors.grey,
                  thickness: 2,
                  height: 5,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white60,
                    border: Border.all(color: Colors.green, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 250,
                  child: ListView.builder(
                    itemCount: location.length,
                    itemBuilder: (BuildContext context, int index) {
                      var location = history['location'][index];
                      // var item = history[index];
                      return ListTile(
                        title: Text("${location['lat']}"),
                        subtitle: Text("${location['long']}"),
                      );
                    },
                  ),
                )
              ],
            ),
            // SizedBox(width: 20,),
          ),
        ),
      ),
    );
  }
}

// Container(
//                       height: 50,
//                       child: ListView.builder(
//                         itemCount: 1,
//                         itemBuilder: (BuildContext context, int index) {
//                           // var location = history['location'][index];
//                           // var item = history[index];
//                           return ListTile(
//                             title: Text("123"),
//                             subtitle: Text("456"),
//                           );
//                         },
//                       ),
//                     )

// class DetailHistoryPickup extends StatelessWidget {
//   DetailHistoryPickup({super.key, required this.idDetail});

//   final String idDetail;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Detail Riwayat'),
//       ),
//       body: Center(child: Text(idDetail)),
//     );
//   }
// }
