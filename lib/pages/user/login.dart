import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shope/main.dart';
import 'package:shope/network/network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shope/pages/user/registrasi.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

enum LoginStatus { notSignIn, signIn }

class _LoginState extends State<Login> {
  LoginStatus _loginStatus = LoginStatus.notSignIn;
  String username, password;
  final _key = new GlobalKey<FormState>();
  bool _secureText = true;

  mata() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  var loading = false;
  check() {
    setState(() {});
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      print("$username,$password");

      login();
    }
  }

  login() async {
    setState(() {
      loading = false;
    });

    final response = await http.post(
      NetworkUrl.login(),
      body: {
        "username": username,
        "password": password,
      },
    );

    final data = jsonDecode(response.body);

    print(data);
    int value = data['value'];
    String pesan = data['message'];
    String status1 = data['status'];
    String namaAPI = data['nama'];
    String usernameAPI = data['username'];
    String level = data['level'];
    String id = data['id'];
    String gambar = data['gambar'];
    if (value == 1) {
      setState(() {
        loading = false;
        _loginStatus = LoginStatus.signIn;
        savePref(value, status1, namaAPI, usernameAPI, level, id, gambar);
      });
      print(pesan);
    } else {
      setState(() {
        loading = false;
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Informasi"),
                content: Text(pesan),
              );
            });
      });
      print(pesan);
    }
  }

  savePref(int value, String status1, String nama, String username,
      String level, String id, String gambar) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt('value', value);
      preferences.setString('status1', status1);
      preferences.setString('nama', nama);
      preferences.setString('username', username);
      preferences.setString('level', level);
      preferences.setString('id', id);
      preferences.setString('gambar', gambar);
      preferences.commit();
    });
  }

  int value;
  String status1;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getInt("level");
      status1 = preferences.getString("status1");
      _loginStatus = value == 1 ? LoginStatus.signIn : LoginStatus.notSignIn;
    });
  }

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.clear();
      preferences.commit();
      _loginStatus = LoginStatus.notSignIn;
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
        return Scaffold(
          body: SafeArea(
            child: SizedBox(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.08),
                      SizedBox(
                        height: 100,
                        child: Image.asset('assets/images/ubahprofile.png'),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04),
                      Text(
                        "Silahkan Login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.5,
                          fontSize: 32,
                        ),
                      ),
                      Form(
                        key: _key,
                        child: Container(
                          child: Column(children: <Widget>[
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.08),
                            buildUsernameFormField(),
                            SizedBox(height: 20),
                            buildPasswordFormField(),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.08),
                            InkWell(
                                onTap: () {
                                  check();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.green,
                                  ),
                                  child: Center(
                                      child: Text(
                                    "Login",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  )),
                                )),
                            SizedBox(
                              height: 20,
                            ),
                            Text("Saya Belum"),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Registrasi(login)));
                              },
                              child: Center(
                                child: Text(
                                  "Daftar",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        break;
      case LoginStatus.signIn:
        return CheckUser();
        break;
    }
  }

  TextFormField buildUsernameFormField() {
    return TextFormField(
      validator: (e) => (e.isEmpty) ? "mohon masukkan username" : null,
      onSaved: (e) => username = e,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
          labelText: "Username",
          hintText: "Masukkan Username Anda",
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
          ),
          prefixIcon: Icon(Icons.person)),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: _secureText,
      onSaved: (e) => password = e,
      decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(_secureText ? Icons.visibility_off : Icons.visibility),
            onPressed: mata,
          ),
          labelText: "Password",
          hintText: "Masukkan Password Anda",
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
          ),
          prefixIcon: Icon(Icons.lock)),
    );
  }
}
