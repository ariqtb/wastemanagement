import 'package:flutter/material.dart';
import 'package:namer_app/pages/admin/home.dart';
import 'package:namer_app/pages/admin/pengepul.dart';
import 'package:namer_app/pages/admin/petugas.dart';
import 'package:namer_app/pages/admin/produsen.dart';
import '../../components/alert.dart';
import '../change_password.dart';

class Sidebaradmin extends StatelessWidget {
  const Sidebaradmin({super.key});

  void showDetailAccountPopupMenu(BuildContext context) async {
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

    PopupMenuButton<String>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      offset: Offset(45, 5),
      itemBuilder: (BuildContext context) => menuItems,
      onSelected: (String selectedItem) async {
        if (selectedItem == 'Keluar') {
          final pop = await exitDialog(context, [
            ...['Konfirmasi', 'Apakah anda ingin keluar']
          ]);
        } else {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return ChangePassword();
          }));
        }
      },
    );

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, 0, 0),
      items: [
        PopupMenuItem(
          child: Text('Ubah Password'),
          value: 'ubahpassword',
        ),
        PopupMenuItem(
          child: Text('Logout'),
          value: 'logout',
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value != null) {
        // Handle popup menu item selection
        switch (value) {
          case 'ubahpassword':
            // Handle profile selection
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return ChangePassword();
            }));
            break;
          case 'logout':
            // Handle logout selection
            final pop = exitDialog(context, [
              ...['Konfirmasi', 'Apakah anda ingin keluar']
            ]);
            break;
          default:
            break;
        }
      }
    });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text('Your Name'),
            accountEmail: Text('your@email.com'),
            // currentAccountPicture: CircleAvatar(
            //   backgroundImage: AssetImage('assets/profile_image.jpg'),
            // ),
            onDetailsPressed: () {
              print("HALO");
              showDetailAccountPopupMenu(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () {
              // Navigate to the home page
              Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (context) {
                return Homeadmin();
              }));
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Produsen'),
            onTap: () {
              // Navigate to the dashboard page
              Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (context) {
                return Produsenadmin();
              }));
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Pengepul'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (context) {
                return Pengepuladmin();
              }));
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Petugas TPS'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (context) {
                return Petugasadmin();
              }));
            },
          ),
        ],
      ),
    );
  }
}
