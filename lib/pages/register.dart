import 'dart:convert';
import 'package:flutter/material.dart';
import '../conn/conn_api.dart';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:namer_app/main.dart';
import 'package:email_validator/email_validator.dart';

class RegisterRepo {
  Future<http.Response> login(String email, String password) {
    return http.post(Uri.parse("uri"),
        headers: <String, String>{
          'Content-type': "application/json; charset=UTF-8"
        },
        body:
            jsonEncode(<String, String>{'email': email, 'password': password}));
  }
}

class RegisterWidget extends StatefulWidget {
  const RegisterWidget({
    super.key,
  });

  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final password2Controller = TextEditingController();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final handphoneController = TextEditingController();
  final roleController = TextEditingController();
  final jalurController = TextEditingController();
  final roleList = ['IRT', 'Pengepul', 'Petugas TPS'];
  String roleSelected = "Pengepul";

  bool loading = false;
  bool logged = false;
  bool submitted = false;
  bool buttonDisabled = false;
  bool _isPasswordVisible = false;
  bool _isPasswordVisible2 = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    password2Controller.dispose();

    super.dispose();
  }

  String? get _errorText {
    final email = emailController.value.text;
    final password = passwordController.value.text;
    final password2 = password2Controller.value.text;
    final name = nameController.value.text;
    final address = addressController.value.text;
    final handphone = handphoneController.value.text;
    final role = roleController.value.text;
    final jalur = jalurController.value.text;

    if (email.isEmpty || password.isEmpty || password2.isEmpty) {
      return 'Can\'t be empty';
    }
    return null;
  }

  Future<void> registFunc() async {
    // return print(emailController.text.trim());
    final bool isValidEmail =
        EmailValidator.validate(emailController.text.trim());
    if (!isValidEmail) {
      return print('Masukkan email yang benar');
    }
    if (passwordController.text.trim() != password2Controller.text.trim()) {
      return _showDialogError('Password tidak sama!');
    } else {
      try {
        Response response = await post(Uri.parse("${API_URL}/register"), body: {
          'name': nameController.text.trim(),
          'address': addressController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
          'verPassword': password2Controller.text.trim(),
          'handphone': handphoneController.text.trim(),
          'role': roleSelected.toLowerCase(),
          'jalur': jalurController.text.trim(),
        });
        if (response.statusCode == 201) {
          print(response.body);
          print(response.statusCode);
          return _showDialogSuccess();
        } else {
          return _showDialogError(response.body.toString());
        }
      } catch (e) {
        return print(e.toString());
      }
    }
  }

  Future<void> _showDialogSuccess() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Berhasil daftar'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text('Silakan login kembali'),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return MyApp();
                        },
                      ),
                    );
                  },
                  child: Text('Okay'))
            ],
          );
        });
  }

  Future<void> _showDialogError(String status) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Gagal daftar'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  // Text(
                  //     'Silahkan cek kembali email dan password yang terdaftar'),
                  Text(status),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Okay'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
          body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: <Widget>[
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(10,5,10,5),
                  child: const Text(
                    'Waste App',
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                        fontSize: 30),
                  )),
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(10,5,10,5),
                  child: const Text(
                    'Daftar',
                    style: TextStyle(fontSize: 20),
                  )),
              Container(
                padding: const EdgeInsets.fromLTRB(10,20,10,5),
                child: TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(),
                    labelText: 'Nama',
                    // errorText: _errorText,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10,5,10,5),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    // errorText: _errorText,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10,5,10,5),
                child: TextFormField(
                  obscureText: !_isPasswordVisible,
                  controller: passwordController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            icon: _isPasswordVisible
                                ? Icon(Icons.visibility)
                                : Icon(Icons.visibility_off))
                  ),
                ),
              ),
              Container(
                width: 200,
                padding: const EdgeInsets.fromLTRB(10,5,10,5),
                child: TextFormField(
                  obscureText: !_isPasswordVisible2,
                  controller: password2Controller,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(),
                    labelText: 'Konfirmasi Password',
                    suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible2 = !_isPasswordVisible2;
                              });
                            },
                            icon: _isPasswordVisible2
                                ? Icon(Icons.visibility)
                                : Icon(Icons.visibility_off))
                  ),
                ),
              ),
              // Row(
              //   children: [
              //     Container(
              //       // padding: const EdgeInsets.fromLTRB(10,0,10,0),
              //       child: Expanded(
              //         child: TextFormField(
              //           obscureText: !_isPasswordVisible,
              //           controller: passwordController,
              //           decoration: InputDecoration(
              //             border: OutlineInputBorder(),
              //             labelText: 'Password',
              //             suffixIcon: IconButton(
              //               onPressed: () {
              //                 setState(() {
              //                   _isPasswordVisible = !_isPasswordVisible;
              //                 });
              //               },
              //               icon: _isPasswordVisible
              //                   ? Icon(Icons.visibility)
              //                   : Icon(Icons.visibility_off))
              //           ),
              //         ),
              //       ),
              //     ),
              //     SizedBox(
              //       width: 10,
              //     ),
              //     Container(
              //       child: Expanded(
              //         child: TextFormField(
              //           obscureText: !_isPasswordVisible2,
              //           controller: password2Controller,
              //           decoration: InputDecoration(
              //               border: OutlineInputBorder(),
              //               labelText: 'Konfirmasi Password',
              //               suffixIcon: IconButton(
              //                   onPressed: () {
              //                     setState(() {
              //                       _isPasswordVisible2 = !_isPasswordVisible2;
              //                     });
              //                   },
              //                   icon: _isPasswordVisible2
              //                       ? Icon(Icons.visibility)
              //                       : Icon(Icons.visibility_off))),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              Container(
                padding: const EdgeInsets.fromLTRB(10,5,10,5),
                child: TextFormField(
                  controller: handphoneController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(),
                    labelText: 'Nomor HP',
                    // errorText: _errorText,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10,5,10,5),
                child: TextFormField(
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 4,
                  controller: addressController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(),
                    labelText: 'Alamat',
                    // errorText: _errorText,
                  ),
                ),
              ),
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Role'),
                    value: roleSelected,
                    onChanged: (val) {
                      setState(() {
                        roleSelected = val!;
                      });
                    },
                    items: roleList
                        .map((e) => DropdownMenuItem(
                              child: Text(e),
                              value: e,
                            ))
                        .toList(),
                    icon:
                        Icon(Icons.arrow_drop_down_circle, color: Colors.green),
                  )),
              Container(
                margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                ),
                child: Text(
                  "Harap jalur telah disesuaikan atau ditentukan agar IRT dan pengepul mempunyai jalur yang sama",
                  style: TextStyle(fontFamily: 'Opensans', color: Colors.green),
                ),
              ),
              roleSelected == "Petugas TPS"
                  ? Container()
                  : Container(
                      padding: const EdgeInsets.fromLTRB(10,10,10,5),
                      child: TextFormField(
                        controller: jalurController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          border: OutlineInputBorder(),
                          labelText: 'Jalur',
                          // errorText: _errorText,
                        ),
                      ),
                    ),
              Container(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                  height: 65,
                  child: ElevatedButton(
                    child: const Text('Daftar'),
                    onPressed: () async {
                      if (!buttonDisabled) {
                        setState(() {
                          loading = true;
                          buttonDisabled = true;
                        });
                        await registFunc();
                        setState(() {
                          loading = false;
                          logged = true;
                          buttonDisabled = false;
                        });
                      }
                    },
                  )),
              if (loading)
                Container(
                  padding: EdgeInsets.all(25),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                alignment: Alignment.center,
                child: Text('Sudah punya akun?'),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                height: 55,
                child: OutlinedButton(
                  child: Text('Login'),
                  onPressed: () {
                    if (!buttonDisabled) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
