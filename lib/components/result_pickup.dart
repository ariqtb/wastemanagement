import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/user_data_login.dart';

class ResultPickup extends StatefulWidget {

  const ResultPickup({super.key});

  @override
  State<ResultPickup> createState() => _ResultPickupState();
}

class _ResultPickupState extends State<ResultPickup> {
  List<dynamic> data = [];
  bool isLoading = false;

 Future<void> fetchData() async {
    List<dynamic> data_user = await findUserData();
    String id_user = data_user[0]['_id'].toString().toLowerCase();
    final response = await http
        .get(Uri.parse('https://wastemanagement.tubagusariq.repl.co/waste/user/${id_user}'));
    if (response.statusCode == 200) {
      setState(() {
        isLoading = true;
        data = json.decode(response.body);
      });
      // print(data[0]['_id']);
      return data[0]['_id'];
    } else {
      throw Exception("Failed to load data");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hasil Pengambilan Sampah',
      home: Scaffold(
        appBar: AppBar(title: const Text('data')),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Table(
            columnWidths: const <int, TableColumnWidth>{},
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(children: [
                Container(
                  height: 20,
                ),
                Container(
                  height: 20,
                  color: Colors.redAccent,
                ),
                Container(
                  height: 20,
                  color: Colors.yellowAccent,
                ),
              ])
            ],
          ),
        ),
      ),
    );
  }
}
