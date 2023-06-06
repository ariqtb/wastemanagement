import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../geolocator.dart';

class getIRT {
  String _urlAPI = 'https://waste-management.leeseona25.repl.co/waste/IRT';

  Future<List<dynamic>> _fetchAPI() async {
    final response = await http.get(Uri.parse(_urlAPI));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed getting data');
    }
  }
}

class ShowPickup extends StatefulWidget {
  const ShowPickup({super.key});

  @override
  State<ShowPickup> createState() => _showPickupState();
}

class _showPickupState extends State<ShowPickup> {
  getIRT irtAPI = getIRT();

  List<dynamic> data = [];
  bool load = false;

  @override
  void initState() {
    super.initState();
    _fetchAPI();
  }

  Future<void> _fetchAPI() async {
    try {
      final response = await irtAPI._fetchAPI();
      if (mounted) {
        final availablePick =
            response.where((e) => e['picked_up'] == false).toList();
        setState(() {
          data = availablePick;
          load = true;
        });
      }
      return print(data[0]);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(10),
            child: const Text('Pengambilan terdekat'),
          ),
          load
              ? Flexible(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(5, 10, 5, 5),
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(index.toString()),
                          ),
                          title: Text(data[index]['location']['lat']),
                          subtitle: Row(children: [
                            Text('Status: '),
                            data[index]['picked_up']
                                ? Text('Sudah Diambil')
                                : Text('Belum Selesai')
                          ]),
                          trailing: Icon(Icons.arrow_forward),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return GenerateLocator();
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                )
              : Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(50),
                  child: CircularProgressIndicator(),
                ),
        ],
      ),
    );
  }
}
