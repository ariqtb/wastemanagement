import 'dart:convert';
import 'package:flutter/material.dart';
import '../../conn/conn_api.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:email_validator/email_validator.dart';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final password2Controller = TextEditingController();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final handphoneController = TextEditingController();
  final roleController = TextEditingController();
  final jalurController = TextEditingController();
  final roleList = ['Produsen', 'Pengepul', 'Petugas TPS'];
  // final roleList = ['Produsen', 'Kolektor', 'Petugas TPS'];
  String roleSelected = "Pengepul";

  bool loading = false;
  bool logged = false;
  bool submitted = false;
  bool buttonDisabled = false;
  bool _isPasswordVisible = false;
  bool _isPasswordVisible2 = false;

  var _text = '';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    password2Controller.dispose();

    super.dispose();
  }

  String? get _errorTextEmail {
    final email = emailController.value.text;

    if (email.isEmpty) {
      return 'Tidak boleh kosong';
    }
    if (EmailValidator.validate(email) == false) {
      return 'Masukan format email dengan benar';
    }
    return null;
  }

  String? get _errorTextPassword {
    final password = passwordController.value.text;

    if (password.isEmpty) {
      return 'Tidak boleh kosong';
    }
    if (password.length < 6) {
      return 'Password terlalu pendek';
    }

    return null;
  }

  String? get _errorTextPassword2 {
    final password2 = password2Controller.value.text;

    if (password2.isEmpty) {
      return 'Tidak boleh kosong';
    }
    if (password2.length < 6) {
      return 'Password terlalu pendek';
    }

    return null;
  }

  String? get _errorTextName {
    final name = nameController.value.text;

    if (name.isEmpty) {
      return 'Tidak boleh kosong';
    }
    return null;
  }

  String? get _errorTextHandphone {
    final handphone = handphoneController.value.text;

    if (handphone.isEmpty) {
      return 'Tidak boleh kosong';
    }
    return null;
  }

  String? get _errorTextAddress {
    final address = addressController.value.text;

    if (address.isEmpty) {
      return 'Tidak boleh kosong';
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
            title: const Text('Sukses'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text('Akun berhasil dibuat'),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
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
    return Scaffold(
        appBar: AppBar(
          title: Text("Tambah Akun"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 5),
                  child: TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      border: OutlineInputBorder(),
                      errorText: submitted ? _errorTextName : null,
                      labelText: 'Nama',
                    ),
                    onChanged: (text) => setState(() {
                      _text;
                    }),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                      errorText: submitted ? _errorTextEmail : null,
                    ),
                    onChanged: (text) => setState(() {
                      _text;
                    }),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: TextFormField(
                    obscureText: !_isPasswordVisible,
                    controller: passwordController,
                    decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(),
                        errorText: submitted ? _errorTextPassword : null,
                        labelText: 'Password',
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            icon: _isPasswordVisible
                                ? Icon(Icons.visibility)
                                : Icon(Icons.visibility_off))),
                    onChanged: (text) => setState(() {
                      _text;
                    }),
                  ),
                ),
                Container(
                  width: 200,
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: TextFormField(
                    obscureText: !_isPasswordVisible2,
                    controller: password2Controller,
                    decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(),
                        errorText: submitted ? _errorTextPassword2 : null,
                        labelText: 'Konfirmasi Password',
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible2 = !_isPasswordVisible2;
                              });
                            },
                            icon: _isPasswordVisible2
                                ? Icon(Icons.visibility)
                                : Icon(Icons.visibility_off))),
                    onChanged: (text) => setState(() {
                      _text;
                    }),
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
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: TextFormField(
                    controller: handphoneController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      border: OutlineInputBorder(),
                      errorText: submitted ? _errorTextHandphone : null,
                      labelText: 'Nomor HP',
                    ),
                    onChanged: (text) => setState(() {
                      _text;
                    }),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 4,
                    controller: addressController,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      border: OutlineInputBorder(),
                      errorText: submitted ? _errorTextAddress : null,
                      labelText: 'Alamat',
                    ),
                    onChanged: (text) => setState(() {
                      _text;
                    }),
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
                      icon: Icon(Icons.arrow_drop_down_circle,
                          color: Colors.green),
                    )),
                // Container(
                //   margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
                //   decoration: BoxDecoration(
                //     color: Colors.green[50],
                //   ),
                //   child: Text(
                //     "Harap jalur telah disesuaikan atau ditentukan agar produsen dan kolektor mempunyai jalur yang sama",
                //     style: TextStyle(fontFamily: 'Opensans', color: Colors.green),
                //   ),
                // ),
                roleSelected == "Petugas TPS"
                    ? Container()
                    : Container(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                        child: TextFormField(
                          controller: jalurController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
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
                      child: const Text('Buat Akun'),
                      onPressed: () async {
                        setState(() {
                          submitted = true;
                        });
                        if (_errorTextEmail != null ||
                            _errorTextPassword != null ||
                            _errorTextPassword2 != null ||
                            _errorTextName != null ||
                            _errorTextHandphone != null ||
                            _errorTextAddress != null) {
                          print(_errorTextEmail);
                          return null;
                        }
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
                            submitted = false;
                          });
                        }
                      },
                    )),
                if (loading)
                  Container(
                    padding: EdgeInsets.all(25),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ));
  }
}
