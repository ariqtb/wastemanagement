import 'package:flutter/material.dart';
import '../geolocator.dart';
import '../components/alert.dart';
// import 'irt/home.dart';
import 'petugas/homepage.dart';
import 'package:http/http.dart';

class MenuPage extends StatefulWidget {
  final String role;
  const MenuPage({super.key, required this.role});

  @override
  State<MenuPage> createState() => MenuPageState();
}

class MenuPageState extends State<MenuPage> {
  late String role = widget.role;

  // Widget page;
  @override
  Widget build(BuildContext context) {
    // if (role == 'pengepul') {
    //   page = GenerateLocator();
    // } else if (role == 'produsen') {
    //   page = HomeIrt();
    // } else if (role == 'petugastps') {
    //   page = HomepagePetugas();
    // } else {
    //   showDialogError(context, [
    //     ...['Gagal masuk', 'Akun tidak terdaftar', '401']
    //   ]);
    // }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
      ),
      home: Scaffold(body: Container()),
    );
  }
}

// class MenuPage extends StatelessWidget {
//   final String role;
//   const MenuPage({super.key, required this.role});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         brightness: Brightness.light,
//         primarySwatch: Colors.green,
//       ),
//       home: Content(),
//     );
//   }
// }

// class Content extends StatefulWidget {
//   const Content({super.key});

//   @override
//   State<Content> createState() => ContentState();
// }

// class ContentState extends State<Content> {
//   @override
//   Widget build(BuildContext context) {
//     Widget page;
//     if (role == 'pengepul') {
//       page = GenerateLocator();
//     } else if (role == 'produsen') {
//       page = HomeIrt();
//     } else if (role == 'petugastps') {
//       page = HomepagePetugas();
//     } else {
//       showDialogError(context, [
//         ...['Gagal masuk', 'Akun tidak terdaftar', '401']
//       ]);
//     }
//     return Container();
//   }
// }
