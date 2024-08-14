import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sidebar.dart';
import '../../components/alert.dart';

class Wrapperadmin extends StatefulWidget {
  const Wrapperadmin({super.key});

  @override
  State<Wrapperadmin> createState() => _WrapperadminState();
}

class _WrapperadminState extends State<Wrapperadmin> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

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
        body: Center(
          child: Text('Your Dashboard Content Goes Here home'),
        ),
      ),
    );
  }
}
