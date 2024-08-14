import 'package:flutter/material.dart';
import 'dart:convert';

import 'sidebar.dart';
import '../../components/alert.dart';
import '../change_password.dart';
import '../../conn/conn_api.dart';

import 'package:http/http.dart' as http;

class Homeadmin extends StatefulWidget {
  const Homeadmin({super.key});

  @override
  State<Homeadmin> createState() => _HomeadminState();
}

class _HomeadminState extends State<Homeadmin> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  List<Map<String, dynamic>> weightList = [];
  List<Map<String, dynamic>> weightListToday = [];
  List<Map<String, dynamic>> userList = [];
  
  bool recapWeightLoading = false;

  Future recapWeight() async {
    setState(() {
      recapWeightLoading = true;
    });
    final response = await http.get(Uri.parse('${API_URL}/admin/getweight'));
    if (response.statusCode == 200) {
      if (mounted) {
        Map<String, dynamic> responsedata = json.decode(response.body);
        List<Map<String, dynamic>> mapList = [];
        responsedata.forEach((key, value) {
          Map<String, dynamic> modifiedMap = {
            'name': key,
            'value': value,
          };
          if (modifiedMap['name'] == 'Anorganik' || modifiedMap['name'] == 'Organik' || modifiedMap['name'] == 'B3' || modifiedMap['name'] == 'Residu') {
            mapList.add(modifiedMap);
          }
        });
        print("${mapList}");
        // if (json.decode(response.body)['cache'] != null) {
        setState(() {
          weightList = mapList;
          recapWeightLoading = false;
          // isLoading = true;
        });
        // }
      }
    } else {
      print("Failed to load data. status code:${response.statusCode}");
    }
  }

  Future recapWeightToday() async {
    setState(() {
      recapWeightLoading = true;
    });
    final response = await http.get(Uri.parse('${API_URL}/admin/getweight/today'));
    if (response.statusCode == 200) {
      if (mounted) {
        Map<String, dynamic> responsedata = json.decode(response.body);
        List<Map<String, dynamic>> mapList = [];
        responsedata.forEach((key, value) {
          Map<String, dynamic> modifiedMap = {
            'name': key,
            'value': value,
          };
          if (modifiedMap['name'] == 'Anorganik' || modifiedMap['name'] == 'Organik' || modifiedMap['name'] == 'B3' || modifiedMap['name'] == 'Residu') {
            mapList.add(modifiedMap);
          }
        });
        print("${mapList}");
        // if (json.decode(response.body)['cache'] != null) {
        setState(() {
          weightListToday = mapList;
          recapWeightLoading = false;
          // isLoading = true;
        });
        // }
      }
    } else {
      print("Failed to load data. status code:${response.statusCode}");
    }
  }
  
  Future totalUser() async {
    final response = await http.get(Uri.parse('${API_URL}/admin/gettotaluser'));
     if (response.statusCode == 200) {
      if (mounted) {
        List<dynamic> responsedata = json.decode(response.body);
        // userList = responsedata.values.toList();
        // print(userList);
        setState(() {
          userList = responsedata.cast<Map<String, dynamic>>();
          recapWeightLoading = false;
          // isLoading = true;
        });
        // }
      }
    } else {
      print("Failed to load data. status code:${response.statusCode}");
    }
  }
  
  List<Map<String, dynamic>> listRecapData = [
    {'title': 'Total Users', 'value': 150},
    {'title': 'Active Users', 'value': 120},
    {'title': 'Inactive Users', 'value': 30},
    {'title': 'Total Revenue', 'value': '\$5000'},
  ];

  // Simulated grid recap data
  List<Map<String, dynamic>> gridRecapData = [
    {'title': 'Sales', 'value': 120},
    {'title': 'Expenses', 'value': 80},
    {'title': 'Profit', 'value': 40},
    {'title': 'Loss', 'value': 20},
    {'title': 'Recap 1', 'value': 20},
    {'title': 'Recap 2', 'value': 20},
  ];

  Future<void> refreshData() async {
    // Simulate fetching new data
    await recapWeight();
    await totalUser();
    // await Future.delayed(Duration(seconds: 2));
    // Add logic here to refresh your data
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recapWeight();
    recapWeightToday();
    totalUser();
  }

  @override
  Widget build(BuildContext context) {
    
    return WillPopScope(
      onWillPop: () async {
        final pop = await confirmDialog(context, [
          ...['Konfirmasi', 'Apakah anda ingin keluar?']
        ]);
        return pop ?? false;
      },
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              scaffoldKey.currentState!.openDrawer();
            },
          ),
          title: Text("Admin Dashboard"),
        ),
        drawer: Sidebaradmin(),
        body: RefreshIndicator(
          onRefresh: refreshData,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Rekap Sampah',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    recapWeightLoading ?
                     Center(child: CircularProgressIndicator()) :
                     GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: weightList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 3,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(weightList[index]['name'], style: TextStyle(  fontSize: 14),),
                                Text(
                                  "${weightList[index]['value'].toString()} kg",
                                  style: TextStyle(fontWeight: FontWeight.bold,),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Sampah Harian',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    recapWeightLoading ?
                     Center(child: CircularProgressIndicator()) :
                     GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: weightListToday.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 3,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(weightListToday[index]['name'], style: TextStyle(  fontSize: 14),),
                                Text(
                                  "${weightListToday[index]['value'].toString()} kg",
                                  style: TextStyle(fontWeight: FontWeight.bold,),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Divider(),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'List Pengguna',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: userList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(userList[index]['title']),
                          trailing: Text(
                            userList[index]['value'].toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
