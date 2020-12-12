import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shope/network/network.dart';

class Registrasi extends StatefulWidget {
  final VoidCallback reload;
  Registrasi(this.reload);
  @override
  _RegistrasiState createState() => _RegistrasiState();
}

class _RegistrasiState extends State<Registrasi> {
  String nama, usr, pass;
  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      save();
    }
  }

  save() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text("Processing"),
              content: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 4,
                    ),
                    Text("Loading...")
                  ],
                ),
              ),
              elevation: 24.0);
        });

    try {
      var url = Uri.parse(NetworkUrl.registrasi());
      var request = http.MultipartRequest("POST", url);
      request.fields['nama'] = nama;
      request.fields['username'] = usr;
      request.fields['password'] = pass;

      var response = await request.send();
      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
        final data = jsonDecode(value);
        int valueGet = data['value'];
        String message = data['message'];
        if (valueGet == 1) {
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Pendaftaran"),
                  content: Text(message),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          Navigator.pop(context);
                          widget.reload();
                        });
                      },
                      child: Text("Ok"),
                    )
                  ],
                );
              });
        } else {
          Navigator.pop(context);
          print(message);
        }
      });
    } catch (e) {
      debugPrint("Error $e");
    }
  }

  final _key = new GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pendaftaran"),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04), // 4%
                  Text(
                    "Pendaftaran Akun",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.5,
                      fontSize: 32,
                    ),
                  ),
                  Text(
                    "Semoga Bahagia \n dengan Mendaftar pada aplikasi ini.",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                  Form(
                    key: _key,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          buildNamaFormField(),
                          SizedBox(height: 20),
                          buildUsernameFormField(),
                          SizedBox(height: 20),
                          buildPasswordFormField(),
                          SizedBox(height: 40),
                          InkWell(
                            onTap: () {
                              check();
                            },
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'Daftar',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextFormField buildNamaFormField() {
    return TextFormField(
      validator: (e) => (e.isEmpty) ? "mohon masukkan Nama lengkap" : null,
      onSaved: (e) => nama = e,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          labelText: "Nama Lengkap",
          hintText: "Masukkan Nama Lengkap Anda",
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
          ),
          prefixIcon: Icon(Icons.person)),
    );
  }

  TextFormField buildUsernameFormField() {
    return TextFormField(
      validator: (e) => (e.isEmpty) ? "mohon masukkan Username" : null,
      onSaved: (e) => usr = e,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: "UserName",
        hintText: "Masukkan Username",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        prefixIcon: Icon(Icons.person_add),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: true,
      validator: (e) => (e.isEmpty) ? "mohon masukkan password" : null,
      onSaved: (e) => pass = e,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: "Password",
        hintText: "Masukkan Password Anda",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        prefixIcon: Icon(Icons.lock),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}
