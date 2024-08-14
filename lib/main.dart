import 'package:flutter/material.dart';
import 'package:namer_app/pages/admin/home.dart';
import 'package:namer_app/pages/petugas/homepage.dart';
import 'pages/login.dart';
import 'pages/distributor/add_location.dart';
import 'pages/produsen/home.dart';
import 'conn/conn_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/get_user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String token = prefs.getString('token') ?? '';
  void isConnected = await connAPI();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'DWMS';

  Future getUserData() async {
    dynamic userdata = await findUserData();
    final prefs = await SharedPreferences.getInstance();
    String? getjalur = await prefs.getString('jalur');
    String? getrole = await prefs.getString('role');
    String? getemail = await prefs.getString('email');

    String? getname = userdata[0]['name'];
    await prefs.setString('username', getname!);
    // print("NAME: ${userdata[0]['name']}");

    if (getjalur != null && getrole != null && getemail != null) {
      return [getrole, getjalur, getemail.toLowerCase()];
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        primaryColor: Colors.amber,
        fontFamily: 'Opensans',
      ),
      home: FutureBuilder(
          future: getUserData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: CircularProgressIndicator());
            } else if (snapshot.hasData && snapshot.data != null) {
              // String userData =snapshot.data;
              print("HHKHHKHKL: ${snapshot.data}");
              if (snapshot.data[0] == 'pengepul' ||
                  snapshot.data[0] == 'kolektor') {
                return Scaffold(body: AddLocation());
              } else if (snapshot.data[0] == 'produsen') {
                return Scaffold(
                  body: HomeIrt(),
                );
              } else if (snapshot.data[0] == 'admin') {
                return Homeadmin();
              } else if (snapshot.data[0] == 'petugastps') {
                return HomepagePetugas();
              } else {
                return Scaffold(body: MyStatefulWidget());
              }
            } else {
              print("HHKHHKHKL: ${snapshot.data}");
              return Scaffold(body: MyStatefulWidget());
            }
          }),
      // home: Scaffold(
      //   body: MyStatefulWidget(),
      // ),
    );
  }
}
