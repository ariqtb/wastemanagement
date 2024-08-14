import 'package:flutter/material.dart';

import 'package:namer_app/conn/conn_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class EditUser extends StatefulWidget {
  final dynamic userData;
  EditUser({super.key, this.userData});

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  Map<String, dynamic> userData = {};

  bool isPasswordVisible = false;
  bool success = false;
  bool submitted = false;

  String? get errorTextPassword {
    final password = passController.value.text;

    if (password.length < 6) {
      return 'Password terlalu pendek (minimal 6 huruf/angka)';
    }

    return null;
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController handphoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController jalurController = TextEditingController();

  Future updateUser() async {
    Response response = await http
        .post(Uri.parse("${API_URL}/super/edituser/${userData['_id']}"), body: {
      "name": nameController.value.text,
      "address": addressController.value.text,
      "password": passController.value.text,
      "role": roleController.value.text,
      "handphone": handphoneController.value.text,
      "email": emailController.value.text,
      "jalur": jalurController.value.text,
    });
    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        success = true;
      });
      return "${response.body}";
    } else {
      success = false;
      print(response.body);
      return "${response.body}";
    }
  }

  Future deleteUser() async {
    Response response = await http
        .delete(Uri.parse("${API_URL}/super/deleteuser/${userData['_id']}"));

    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        success = true;
      });
    } else {
      print(response.body);
      setState(() {
        success = false;
      });
    }
  }

  Future<bool?> infoDialog(BuildContext context, msg) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${msg[0]}'),
          content: Text('${msg[1]}'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                // Handle button click
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool?> confirmDelete(BuildContext context, msg) async {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('${msg[0]}'),
              content: Text('${msg[1]}'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: Text('Tidak')),
                TextButton(
                    onPressed: () async {
                      await deleteUser();
                      Navigator.pop(context, true);
                    },
                    child: Text('Ya')),
              ],
            ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userData = widget.userData;
    print(userData);

    nameController.text = userData['name'];
    addressController.text = userData['address'];
    roleController.text = userData['role'];
    handphoneController.text = userData['handphone'].toString();
    if (userData.containsKey('jalur')) {
      jalurController.text = userData['jalur'];
    } else {
      jalurController.text = "0";
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      position: DecorationPosition.background,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.white, Colors.green.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text('Ubah Data Akun'),
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: const Text(
                            'Email: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'OpenSans',
                            ),
                          )),
                      Container(
                        alignment: Alignment.centerLeft,
                        // height: 50,
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Text("${userData['email']}"),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    width: 100,
                    height: 35,
                    child: ElevatedButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete),
                          SizedBox(width: 2),
                          Text('Hapus'),
                        ],
                      ),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.redAccent),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          submitted = true;
                        });

                        final res = await confirmDelete(context,
                            ["Konfirmasi", "Yakin untuk menghapus akun ini?"]);

                        if (success == true) {
                          await infoDialog(context, [
                            ...['Sukses', 'Akun berhasil dibuat']
                          ]);
                          Navigator.of(context).pop();
                        }
                        setState(() {
                          submitted = false;
                          success = false;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 5),
                child: TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(),
                    labelText: 'Nama',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 5),
                child: TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(),
                    labelText: 'Alamat',
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 20, 10, 5),
                child: TextFormField(
                  obscureText: !isPasswordVisible,
                  controller: passController,
                  decoration: InputDecoration(
                      errorText: submitted ? errorTextPassword : null,
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                          icon: isPasswordVisible
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off))),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 5),
                child: TextFormField(
                  controller: roleController,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(),
                    labelText: 'Role',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 5),
                child: TextFormField(
                  controller: handphoneController,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(),
                    labelText: 'Handphone',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 5),
                child: TextFormField(
                  controller: jalurController,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(),
                    labelText: 'Jalur',
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                width: 120,
                height: 45,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      submitted = true;
                    });
                    if (errorTextPassword != null &&
                        !passController.text.trim().isEmpty) {
                      return null;
                    }
                    final res = await updateUser();
                    // final res = await ChangePassword();
                    if (success == true) {
                      await infoDialog(context, [
                        ...['Sukses', '${res}']
                      ]);
                      Navigator.of(context).pop();
                    } else {
                      await infoDialog(context, [
                        ...['Gagal', '${res}']
                      ]);
                    }
                    setState(() {
                      submitted = false;
                      success = false;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 5),
                      Text('Ubah'),
                    ],
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
