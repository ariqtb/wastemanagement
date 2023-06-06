import 'package:flutter/material.dart';

class HomepagePetugas extends StatefulWidget {
  const HomepagePetugas({super.key});

  @override
  State<HomepagePetugas> createState() => _HomepagePetugasState();
}

class _HomepagePetugasState extends State<HomepagePetugas> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton.extended(
            elevation: 0.0,
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            label: Text('Tambah'),
            icon: Icon(Icons.add),
            onPressed: () {},
          ),
          
      ),
    );
  }
}