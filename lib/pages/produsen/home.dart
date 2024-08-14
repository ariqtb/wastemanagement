import 'package:flutter/material.dart';
import 'package:namer_app/pages/chatmessage.dart';
import 'package:namer_app/pages/chat.dart';
import 'test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/alert.dart';
import 'sorting_check.dart';
import 'history_page.dart';
import '../change_password.dart';
import '../../providers/get_user.dart';

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
              FloatingActionButtonLocation.miniCenterFloat,
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
  String name = '';
  bool isLoading = true;

  getuserdata() async {
    dynamic userdata = await findUserData();
    setState(() {
      name = userdata[0]['name'];
      isLoading = false;
      // print("${userdata}");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getuserdata();
  }

  @override
  Widget build(BuildContext context) {
    final List<PopupMenuEntry<String>> menuItems = [
      PopupMenuItem<String>(
        value: 'Ubahpassword',
        child: Container(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: [
                Icon(Icons.password_outlined),
                SizedBox(width: 5),
                Text(
                  'Ubah Password',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
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
              colors: [Colors.green.shade300, Colors.yellow.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),
      child: Container(
        // padding: EdgeInsets.fromLTRB(15, 50, 15, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(15, 30, 15, 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
                color: Colors
                    .green.shade500, // Ganti dengan warna yang Anda inginkan.
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: isLoading
                        ? CircularProgressIndicator()
                        : Text(
                            "Halo, ${name}",
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'OpenSans',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  Row(
                    children: [
                      Container(
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return ChatApp();
                              }));
                            },
                            child: Icon(Icons.message_rounded,
                                color: Colors.black87),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.green.shade500,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            )),
                      ),
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
                          if (selectedItem == 'Ubahpassword') {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return ChangePassword();
                            }));
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(15, 20, 15, 5),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Text(
                      "Sudahkah anda buang sampah hari ini?",
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'OpenSans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 0.5,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade700,
                              Colors.green.shade400
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        alignment: Alignment.center,
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
                          title: Text(
                            'Tambah Sampah',
                            style: TextStyle(color: Colors.white),
                          ),
                          // subtitle: Text('Tambah Sampah'),
                          trailing: Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
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
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade700,
                                  Colors.green.shade400
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: ListTile(
                              onTap: () {},
                              title: Text(
                                'Artikel',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                '~Dalam Pengembangan~',
                                style: TextStyle(color: Colors.white),
                              ),
                              trailing: Text(
                                'Senin, 27 Apr 2023',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'OpenSans',
                                    color: Colors.white),
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
          ],
        ),
      ),
    );
  }
}
