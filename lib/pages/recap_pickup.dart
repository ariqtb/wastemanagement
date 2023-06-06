import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:namer_app/pages/image_sorting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class RecapPickup extends StatefulWidget {
  // final Map<dynamic, String> waste;

  // RecapPickup(this.waste);
  const RecapPickup({super.key});

  @override
  State<RecapPickup> createState() => _RecapPickupState();
}

class _RecapPickupState extends State<RecapPickup> {
  Map<String, dynamic>? datas;
  List<Map<String, dynamic>>? wasteData;
  List<Map<String, dynamic>> location = [];

  getRecap() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? getdata = prefs.getString('waste');

    setState(() {
      datas = jsonDecode(getdata!);
    });
    print(datas.runtimeType);
    print(datas);

    wasteData = [datas!].toList();

    // print(wasteData![0]['location']);
    // setState(() {
    //   location = wasteData![0]['location'].map((item) => item as Map<String, dynamic>).toList();
    // });

    // List<Map<String, dynamic>> test = datas!['location'].map((item) => item as Map<String, dynamic>).toList();
    // List<Map<String, dynamic>> test =
    //     datas!['location'].map((item) => item as Map<String, dynamic>).toList();

    List<Map<String, dynamic>> test = [];

    datas!['location'].forEach((item) {
      test.add(Map<String, dynamic>.from(item));
    });

    setState(() {
      location = test;
    });

    // print(test);
    // print(test.runtimeType);
    // print(datas);
    // print(datas!['location'].runtimeType);
    // print(location.runtimeType);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRecap();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> data = [
      {'Name': 'Alice', 'Age': 25, 'Role': 'Developer'},
      {'Name': 'Bob', 'Age': 30, 'Role': 'Manager'},
      {'Name': 'Charlie', 'Age': 35, 'Role': 'Designer'},
    ];

    // print(waste);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Rekap Pengambilan Sampah'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Jumlah: ${location.length}',
              style: TextStyle(
                fontSize: 13,
              ),
            ),
            Container(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Jam')),
                  DataColumn(label: Text('Tanggal')),
                  DataColumn(label: Text('Alamat')),
                ],
                rows: location.map((e) {
                  return DataRow(cells: [
                    DataCell(Text(
                        "${DateFormat('HH:mm').format(DateTime.parse(e['time']))}")),
                    DataCell(Text(
                        "${DateFormat('EEE, dd MMMM yy').format(DateTime.parse(e['time']))}")),
                    DataCell(Text("")),
                  ]);
                }).toList(),
              ),
            ),
            SizedBox(
              height: 100,
            ),
            Container(
              child: IconButton(
                iconSize: 100,
                icon: const Icon(
                  Icons.arrow_circle_right_outlined,
                ),
                onPressed: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return ImagePickerScreen(datas: datas!);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        // child: Table(
        //   border: TableBorder.all(color: Colors.black),
        //   columnWidths: {
        //     0: FixedColumnWidth(50.0),
        //     1: FlexColumnWidth(),
        //     2: FixedColumnWidth(50.0),
        //   },
        //   children: data.map((row) {
        //     return TableRow(
        //       children: row.map((cell) {
        //         return Text(cell);
        //       }).toList(),
        //     );
        //   }).toList(),
        // ),
      ),
    );
  }
}
