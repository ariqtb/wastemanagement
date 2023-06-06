import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'conn/conn_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.green,
          primaryColor: Colors.amber,
          fontFamily: 'Opensans'),
      home: Scaffold(
        body: MyStatefulWidget(),
      ),
    );
  }
}
