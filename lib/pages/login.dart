import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:namer_app/components/geolocator.dart';
import '../conn/conn_api.dart';
import '../components/alert.dart';

import 'package:http/http.dart' as http;
import 'package:namer_app/pages/irt/home.dart';
import 'package:namer_app/pages/petugas/homepage.dart';
import 'package:namer_app/pages/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'package:namer_app/geolocator.dart';
import 'menu.dart';
import '../components/add_location.dart';

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  bool loading = false;
  bool logged = false;
  bool buttonDisabled = false;
  bool _isPasswordVisible = false;

  String role = '';
  String jalur = '';

  Future<void> loginFunc(String email, password) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      Response response = await http.post(Uri.parse("${API_URL}/login"), body: {
        'email': email.toLowerCase(),
        'password': password,
      });
      if (response.statusCode == 200) {
        await prefs.setString('email', email);
        final bodyParsed = json.decode(response.body.toLowerCase());
        setState(() {
          loading = false;
          logged = true;
          role = bodyParsed['role'];
        });
        print('gaada: ${bodyParsed['jalur']}');
        if (bodyParsed['jalur'] != null) {
          setState(() {
            jalur = bodyParsed['jalur'];
          });
        }
      } else {
        await showDialogError(context, [
          ...[
            'Gagal masuk',
            'Silahkan cek kembali email dan password yang terdaftar',
            response.statusCode.toString()
          ]
        ]);
        setState(() {
          loading = false;
          logged = false;
        });
        print(response.body);
      }
    } catch (e) {
      return print(e.toString());
    }
  }

  Future<void> checkRoleIfLogin() async {
    // if (role == 'pengepul' || role == 'produsen' || role == 'petugastps') {
    //   Navigator.of(context).push(
    //     MaterialPageRoute(
    //       builder: (context) {
    //         return MenuPage(role: role);
    //       },
    //     ),
    //   );
    // }

    if (role == 'pengepul') {
      if (jalur != '') {
        Response response = await http
            .get(Uri.parse('${API_URL}/produsen/pickupbytrack/${jalur}'));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('listpickup', response.body.toString());
        print(response.body);
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return AddLocation();
          },
        ),
      );
    } else if (role == 'produsen') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return HomeIrt();
          },
        ),
      );
    } else if (role == 'petugastps') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return HomepagePetugas();
          },
        ),
      );
    } else {
      showDialogError(context, [
        ...['Gagal masuk', 'Akun tidak terdaftar', '401']
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final pop = await confirmDialog(context, [
          ...['Konfirmasi', 'Apakah anda ingin keluar?']
        ]);
        return pop ?? false;
      },
      child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: SingleChildScrollView(
              child: Column(children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Waste App',
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Opensans',
                          fontSize: 30),
                    )),
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'OpenSans',
                      ),
                    )),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextFormField(
                    obscureText: !_isPasswordVisible,
                    controller: passwordController,
                    decoration: InputDecoration(
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
                                : Icon(Icons.visibility_off))),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        child: loading
                            ? SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ))
                            : Text(
                                'Login',
                                style: TextStyle(
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                        onPressed: () async {
                          if (!buttonDisabled) {
                            setState(() {
                              loading = true;
                              buttonDisabled = true;
                            });
                            await loginFunc(emailController.text.toString(),
                                passwordController.text.toString());
                            if (logged == true) {
                              await checkRoleIfLogin();
                            }
                              setState(() {
                                loading = false;
                                buttonDisabled = false;
                              });
                          }
                        },
                      )),
                ),
                // if (loading)
                //   Container(
                //     padding: EdgeInsets.all(25),
                //     child: const Center(child: CircularProgressIndicator()),
                //   ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                  alignment: Alignment.center,
                  child: Text(
                    'Belum punya akun?',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(width: 1),
                      ),
                      child: Text(
                        'Daftar',
                        style: TextStyle(
                            fontFamily: 'OpenSans', color: Colors.green),
                      ),
                      onPressed: () {
                        if (!buttonDisabled) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const RegisterWidget()));
                        }
                      },
                    ),
                  ),
                ),
              ]),
            ),
          )),
    );
  }
}

class DropdownRole extends StatefulWidget {
  const DropdownRole({
    super.key,
  });

  @override
  State<DropdownRole> createState() => _DropdownRoleState();
}

class _DropdownRoleState extends State<DropdownRole> {
  static const List<String> _role = [
    'Peran',
    'Produsen',
    'Distributor',
    'Pengelola'
  ];

  String dropdownVal = _role.first;

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 40,
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: DropdownButton(
        iconEnabledColor: Colors.green,
        value: dropdownVal,
        icon: const Icon(Icons.arrow_drop_down_circle_outlined),
        elevation: 16,
        style: const TextStyle(color: Colors.black),
        underline: Container(
          height: 2,
          color: Colors.black54,
        ),
        onChanged: (String? value) {
          setState(() {
            dropdownVal = value!;
          });
        },
        items: _role.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}
