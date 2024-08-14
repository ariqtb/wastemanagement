import 'package:flutter/material.dart';
import 'package:namer_app/conn/conn_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController passController = TextEditingController();
  TextEditingController passController2 = TextEditingController();
  String? email;
  bool success = false;
  bool submitted = false;

  bool isPasswordVisible = false;
  bool isPasswordVisible2 = false;

  String? get errorTextPassword {
    final password = passController.value.text;

    if (password.isEmpty) {
      return 'Tidak boleh kosong';
    }
    if (password.length < 6) {
      return 'Password terlalu pendek';
    }

    return null;
  }

  String? get errorTextPassword2 {
    final password2 = passController2.value.text;

    if (password2.isEmpty) {
      return 'Tidak boleh kosong';
    }
    if (password2.length < 6) {
      return 'Password terlalu pendek';
    }

    return null;
  }

  getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email');
    });
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getEmail();
  }

  Future ChangePassword() async {
    try {
      Response response =
          await http.post(Uri.parse("${API_URL}/user/changepassword"), body: {
        "email": email,
        "newpass": passController.value.text,
        "vernewpass": passController2.value.text,
      });
      if (response.statusCode == 200) {
        print(response.body);
        setState(() {
          success = true;
        });
      } else {
        return response.body;
      }
    } catch (err) {
      throw Exception(err);
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
          title: Text('Ubah Password'),
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: const Text(
                    'Email Anda',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'OpenSans',
                    ),
                  )),
              Container(
                alignment: Alignment.centerLeft,
                // height: 50,
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text("${email}"),
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                  child: const Text(
                    'Password Baru',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'OpenSans',
                    ),
                  )),
              Container(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                height: 80,
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
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 5),
                  child: const Text(
                    'Konfirmasi Password Baru',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'OpenSans',
                    ),
                  )),
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                height: 80,
                child: TextFormField(
                  obscureText: !isPasswordVisible2,
                  controller: passController2,
                  decoration: InputDecoration(
                      errorText: submitted ? errorTextPassword2 : null,
                      border: OutlineInputBorder(),
                      labelText: 'Konfirmasi Password',
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isPasswordVisible2 = !isPasswordVisible2;
                            });
                          },
                          icon: isPasswordVisible2
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off))),
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
                    if (errorTextPassword != null ||
                        errorTextPassword2 != null) {
                      return null;
                    }
                    final res = await ChangePassword();
                    if (success == true) {
                      await infoDialog(context, [
                        ...['Sukses', 'Password berhasil diubah']
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
