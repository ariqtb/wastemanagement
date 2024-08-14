import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/show_data_pickup.dart';
import '../pages/history_pickup.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomePageState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.green,
        ),
        home: Dashboard(),
      ),
    );
  }
}

class HomePageState extends ChangeNotifier {
  @override
  var current = [1, 2, 3];
  void getNext() {
    notifyListeners();
  }
}

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var selectedIndex = 0;

  Future<bool> dialog() async {
    AlertDialog(
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text('Tidak')),
        TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text('Ya')),
      ],
    );
    return false;
  }

  Future<bool?> confirmDialog(context) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Apakah anda ingin keluar?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text('Tidak')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                    Navigator.pop(context, true);
                  },
                  child: Text('Ya')),
            ],
          ));

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = showDataPickup();
        break;
      case 1:
        page = HistoryPickup();
        break;
      default:
        throw UnimplementedError('No widget selected');
    }

    return WillPopScope(
      onWillPop: () async {
        final pop = await confirmDialog(context);
        return pop ?? false;
      },
      child: Scaffold(
        body: page,
        bottomNavigationBar: 
        
        NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: Colors.green[100],
            labelTextStyle: MaterialStateProperty.all(
             TextStyle(fontSize: 10, fontWeight: FontWeight.w500) 
            )
          ),
          child: NavigationBar(
              destinations: [
                NavigationDestination(
                    icon: Icon(Icons.home), label: "Daftar Pickup"),
                NavigationDestination(
                    icon: Icon(Icons.history), label: "Riwayat"),
              ],
              // height: 65,
              // labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              }),
        ),
      ),
    );
  }
}
