import 'package:flutter/material.dart';
import 'package:namer_app/pages/admin/addUser.dart';
import 'package:namer_app/pages/admin/editUser.dart';
import 'dart:convert';
import 'sidebar.dart';
import '../../components/alert.dart';
import '../../providers/get_user.dart';

import '../../conn/conn_api.dart';
import 'package:http/http.dart' as http;

class Pengepuladmin extends StatefulWidget {
  const Pengepuladmin({super.key});

  @override
  State<Pengepuladmin> createState() => _PengepuladminState();
}

class _PengepuladminState extends State<Pengepuladmin> {
  bool isLoading = false;
  List<Map<String, dynamic>> pengepulData = [];

  // FETCHING DATA
  Future<void> fetchData() async {
    var dataUser = await findUserData();
    List<dynamic> data = [];
    String idUser = dataUser[0]['_id'].toString().toLowerCase();
    print(dataUser);
    final response = await http.get(Uri.parse('${API_URL}/user/pengepul'));
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          isLoading = true;
          data = json.decode(response.body);
          List<Map<String, dynamic>> mapList =
              data.map((item) => item as Map<String, dynamic>).toList();
          pengepulData = mapList;
          print("INI USER: $pengepulData");
          // pengepulData.sort((a, b) =>
          //     DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
        });
      }
    } else {
      throw Exception("Failed to load data");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  @override
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
          title: Text("Pengepul"),
        ),
        drawer: Sidebaradmin(),
        body: Container(
          child: Column(children: [
            // Text('Your Dashboard Content Goes Here'),
            Flexible(
              child: SingleChildScrollView(
                child: PaginatedDataTable(
                  header: Text('Pengepul'),
            
                  // border: TableBorder.all(),
                  columns: [
                    DataColumn(label: Text('Aksi')),
                    DataColumn(label: Text('Name')),
                    // DataColumn(label: Text('Address')),
                    DataColumn(label: Text('Email')),
                  ],
                  source: _DataSource(pengepulData, context),
                  rowsPerPage: 5,
                  columnSpacing: 20,
                  // rows: pengepulData
                  //     .map((item) => DataRow(cells: [
                  //           DataCell(Text(item['name'].toString())),
                  //           DataCell(Text(item['address'].toString())),
                  //           DataCell(Text(item['email'].toString())),
                  //         ]))
                  //     .toList(),
                ),
              ),
            ),
             Container(
              child: ElevatedButton(
                child: Text("Tambah akun"),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return AddUser();
                  }));
                },
              ),
            )
          ]),
        ),
      ),
    );
  }
}

class _DataSource extends DataTableSource {
  final BuildContext context;
  final List<Map<String, dynamic>> pengepulData;

  _DataSource(this.pengepulData, this.context);

  String truncateText(String text, int maxLength) {
    return text.length <= maxLength
        ? text
        : '${text.substring(0, maxLength)}...';
  }

  @override
  DataRow getRow(int index) {
    if (index >= pengepulData.length) {
      return DataRow.byIndex(index: index, cells: []);
    }
    final user = pengepulData[index];
    return DataRow(cells: [
      DataCell(ElevatedButton(
        child: Text("Edit"),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return EditUser(userData: user);
          }));
        },
      )),
      DataCell(Text(truncateText(user['name'].toString(), 10))),
      // DataCell(Text(user['address'].toString())),
      DataCell(Text(truncateText(user['email'].toString(), 15))),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => pengepulData.length;

  @override
  int get selectedRowCount => 0;
}
