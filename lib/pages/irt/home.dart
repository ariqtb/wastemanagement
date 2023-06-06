import 'package:flutter/material.dart';
import 'package:namer_app/pages/irt/homepage/homepage.dart';
import '../../components/alert.dart';
import 'sorting_check.dart';
import 'history_page.dart';

class HomeIrt extends StatefulWidget {
  const HomeIrt({Key? key}) : super(key: key);

  @override
  State<HomeIrt> createState() => _HomeIrtState();
}

class _HomeIrtState extends State<HomeIrt> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = Dashboard();
        break;
      case 1:
        page = HistoryProdusen();
        break;
      default:
        throw UnimplementedError('No widget selected');
    }

    return WillPopScope(
        onWillPop: () async {
          final pop = await confirmDialog(context, [
            ...['Konfirmasi', 'Apakah anda ingin keluar?']
          ]);
          return pop ?? false;
        },
        child: Scaffold(
          // appBar: AppBar(
          //   title: Text('Halaman Utama'),
          //   // automaticallyImplyLeading: false,
          // ),
          body: page,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniCenterDocked,
          floatingActionButton: SizedBox(
            width: 110,
            height: 50,
            child: FloatingActionButton.extended(
              elevation: 0.0,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              label: Text('Tambah'),
              icon: Icon(Icons.add),
              onPressed: () async {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return SortingCheck();
                    },
                  ),
                );
                // await confirmDialog(context, [
                //   ...['Konfirmasi', 'Apakah anda ingin keluar?']
                // ]);
              },
            ),
          ),
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
                backgroundColor: Colors.white,
                indicatorColor: Colors.green.shade100,
                labelTextStyle: MaterialStateProperty.all(
                    TextStyle(fontSize: 10, fontWeight: FontWeight.w500))),
            child: NavigationBar(
                destinations: [
                  NavigationDestination(
                      icon: Icon(Icons.home), label: "Halaman Utama"),
                  NavigationDestination(
                      icon: Icon(Icons.history), label: "Riwayat"),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                }),
          ),
        ));
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    final List<PopupMenuEntry<String>> menuItems = [
      PopupMenuItem<String>(
        value: 'Keluar',
        child: Container(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: [
                Icon(Icons.logout_rounded),
                SizedBox(width: 5),
                Text(
                  'Keluar',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    ];
    // final List<String> menuItems = ['Keluar'];
    return DecoratedBox(
      position: DecorationPosition.background,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.white, Colors.green.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),
      child: Container(
        padding: EdgeInsets.fromLTRB(15, 50, 15, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PopupMenuButton<String>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              offset: Offset(45, 5),
              itemBuilder: (BuildContext context) => menuItems,
              onSelected: (String selectedItem) async {
                if (selectedItem == 'Keluar') {
                  print('Selected item: $selectedItem');
                  // Navigator.of(context).pop();
                  final pop = await exitDialog(context, [
                    ...['Konfirmasi', 'Apakah anda ingin keluar']
                  ]);
                }
              },
            ),
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
            //   child: ElevatedButton(
            //     onPressed: () async {
            //       final pop = await exitDialog(context, [
            //         ...['Konfirmasi', 'Apakah anda ingin keluar']
            //       ]);
            //     },
            //     child: IntrinsicWidth(
            //       child: Row(
            //         children: [
            //           Icon(
            //             Icons.arrow_back_ios_new_rounded,
            //             size: 16,
            //           ),
            //           SizedBox(
            //             width: 10,
            //           ),
            //           Text('Keluar')
            //         ],
            //       ),
            //     ),
            //     style: ButtonStyle(
            //       shape: MaterialStateProperty.all(
            //         RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(10),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
              child: Text(
                "Sudahkah anda buang sampah hari ini?",
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'OpenSans',
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 50, 20),
              child: Text(
                "Klik tambah sampah agar petugas dapat mengambil sampah kamu",
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'OpenSans',
                  // fontWeight: FontWeight.bold
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 0.5,
              child: Container(
                alignment: Alignment.topLeft,
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return SortingCheck();
                        },
                      ),
                    );
                  },
                  title: Text('Tambah Sampah'),
                  subtitle: Text('Tambah Sampah'),
                  trailing: Icon(Icons.arrow_forward),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Text(
                      "Artikel hari ini,",
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'OpenSans',
                        // fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 0.5,
                    child: Container(
                      // alignment: Alignment.topLeft,
                      child: ListTile(
                        onTap: () {},
                        title: Text(
                          'Contoh Artikel',
                        ),
                        subtitle: Text('Klik untuk pelajari lebih lanjut'),
                        trailing: Text(
                          'Senin, 27 Apr 2023',
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'OpenSans',
                            // fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
