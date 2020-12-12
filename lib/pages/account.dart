import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shope/network/network.dart';
import 'package:shope/pages/produk/produkUser.dart';
import 'package:shope/pages/produkterjual/produkterjual.dart';
import 'package:shope/pages/user/login.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:firebase_messaging/firebase_messaging.dart';

class NotAccount extends StatefulWidget {
  @override
  _NotAccountState createState() => _NotAccountState();
}

class _NotAccountState extends State<NotAccount> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                Text(
                  "PNL SHOPE",
                  style: TextStyle(
                    fontSize: 36,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text("Sebelum Membeli"),
                Text("Silahkan Login Terlebih dahulu."),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                  child: Image.asset('assets/images/splash_1.png'),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                Padding(
                  padding: const EdgeInsets.only(left: 40.0, right: 40),
                  child: InkWell(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => Login()));
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Account extends StatefulWidget {
  @override
  createState() => _AccountState();
}

class _AccountState extends State<Account> {
  String nama = "";
  String id = "";
  String level = "";
  String gambar = "";
  String qrcode = "";
  String token = "";

  Future _scan() async {
    await scanner.scan().then((String qrcode) async {
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
            );
          });
      final response = await http.post(NetworkUrl.verqr(), body: {
        "verqr": qrcode,
        "iduser": id,
      });
      final data = jsonDecode(response.body);
      int value = data['value'];
      String message = data['message'];
      if (value == 1) {
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Information"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(message),
                    Text(qrcode),
                  ],
                ),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Ok"),
                  )
                ],
              );
            });
      } else {
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Warning"),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Ok"),
                  )
                ],
              );
            });
      }
    });
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      nama = preferences.getString("nama");
      id = preferences.getString("id");
      level = preferences.getString("level");
      gambar = preferences.getString("gambar");
      token = preferences.getString("token");
    });
  }

  FirebaseMessaging fm = FirebaseMessaging();
  _AccountState() {
    fm.configure();
  }
  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0.0,
        title: Center(child: Text("Profile", textAlign: TextAlign.center)),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: 300,
            width: 400,
            decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                )),
            child: ListView(
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.network(
                        NetworkUrl.cover(gambar),
                        height: 150.0,
                        width: 150.0,
                      ),
                    ]),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Center(
                    child: Text(
                      nama,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          // jika level adalah user
          level == '2'
              ? Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 150,
                        child: InkWell(
                          onTap: () {
                            _scan();
                          },
                          child: Card(
                            child: Column(
                              children: <Widget>[
                                Expanded(
                                  flex: 2,
                                  child: Image.asset(
                                      'assets/images/generate_qrcode.png'),
                                ),
                                Divider(height: 40),
                                Expanded(flex: 1, child: Text("Scan QR")),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              //jika level adalah admin/penjual
              : Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 150,
                        child: InkWell(
                          onTap: () {
                            //push ke halaman PRODUK SAYA
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProdukUser()));
                          },
                          child: Card(
                            child: Column(
                              children: <Widget>[
                                Expanded(
                                  flex: 2,
                                  child: Image.asset(
                                      'assets/images/tambahbarang.png'),
                                ),
                                Divider(height: 40),
                                Expanded(flex: 1, child: Text("Produk saya")),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 150,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProdukTerjual()));
                          },
                          child: Card(
                            child: Column(
                              children: <Widget>[
                                Expanded(
                                  flex: 2,
                                  child:
                                      Image.asset('assets/images/terjual.png'),
                                ),
                                Divider(height: 40),
                                Expanded(
                                    flex: 1, child: Text("Produk Terjual")),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          //jika level adalah user
          level == '2'
              ? SizedBox()
              //jika level adalah admin/ penjual
              : Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 150,
                        child: InkWell(
                          onTap: () {
                            _scan();
                          },
                          child: Card(
                            child: Column(
                              children: <Widget>[
                                Expanded(
                                  flex: 2,
                                  child: Image.asset(
                                      'assets/images/generate_qrcode.png'),
                                ),
                                Divider(height: 40),
                                Expanded(flex: 1, child: Text("Scan QR")),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
