import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shope/model/productCartModel.dart';
import 'package:shope/model/produkModel.dart';
import 'package:shope/network/network.dart';
import 'package:shope/pages/produk/detailProduk.dart';

class CheckOutOnly extends StatefulWidget {
  final ProdukModel model;
  CheckOutOnly(this.model);
  @override
  _CheckOutOnlyState createState() => _CheckOutOnlyState();
}

class _CheckOutOnlyState extends State<CheckOutOnly> {
  List<ProductCartModel> list = [];
  String id = "";
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
    });
  }

  final _key = new GlobalKey<FormState>();

  var totalPrice = "";
  String alamat, nomor;
  String nama;

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      print("$alamat,$nama, $nomor");
      addBeli();
    }
  }

  addBeli() async {
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
    try {
      var url = Uri.parse(NetworkUrl.addPembelianOnly());
      var request = http.MultipartRequest("POST", url);
      request.fields['alamat'] = alamat;
      request.fields['nama'] = nama;
      request.fields['nomor'] = nomor;
      request.fields['metode'] = "0763192397";
      request.fields['user'] = id;
      request.fields['codebarang'] = widget.model.id;
      request.fields['bank'] = "Bank BNI";
      request.fields['qty'] = "${i}";
      request.fields['total'] = "${widget.model.harga * i}";
      print("$alamat,$i");
      var response = await request.send();
      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
        print(response);
        final data = jsonDecode(value);
        int valueGet = data['value'];
        String message = data['message'];
        if (valueGet == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return DetailSubmitOrder();
          }));
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Informasi"),
                  content: Text(message),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return DetailSubmitOrder();
                        }));
                        setState(() {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return DetailSubmitOrder();
                          }));
                        });
                      },
                      child: Text("Ok"),
                    )
                  ],
                );
              });
          print(message);
        } else {
          Navigator.pop(context);
          print(message);
        }
      });
    } catch (e) {
      debugPrint("Error $e");
    }
  }

  var i = 1;
  void _incremenTab() {
    if (i < widget.model.stok) {
      setState(() {
        i++;
      });
    } else {
      i = widget.model.stok;
    }
  }

  void _decremenTab() {
    setState(() {
      i == 1 ? i = 1 : i--;
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Information"),
                content: Text("apakah anda ingin keluar dalam check Out.?"),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context);
                      });
                    },
                    child: Text("no"),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            "/CheckUser", (Route<dynamic> route) => false);
                      });
                    },
                    child: Text("Ok"),
                  )
                ],
              );
            });
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Information"),
                        content:
                            Text("apakah anda ingin keluar dalam check Out.?"),
                        actions: <Widget>[
                          FlatButton(
                            onPressed: () {
                              setState(() {
                                Navigator.pop(context);
                              });
                            },
                            child: Text("No"),
                          ),
                          FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    "/CheckUser",
                                    (Route<dynamic> route) => false);
                              });
                            },
                            child: Text("Ok"),
                          )
                        ],
                      );
                    });
              }),
          title: Text("CheckOut"),
        ),
        body: Container(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _key,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      TextFormField(
                        validator: (e) =>
                            (e.isEmpty) ? "mohon masukkan Alamat Anda" : null,
                        onSaved: (e) => alamat = e,
                        decoration: InputDecoration(
                          hintText: 'Alamat',
                          hintStyle: TextStyle(color: Colors.black),
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 10.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0)),
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: 4,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        validator: (e) =>
                            (e.isEmpty) ? "mohon masukkan nama Anda" : null,
                        onSaved: (e) => nama = e,
                        decoration: InputDecoration(
                          hintText: 'Nama Lengkap',
                          hintStyle: TextStyle(color: Colors.black),
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 10.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0)),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        validator: (e) {
                          Pattern pattern = r'(^(?:[+0]6)?[0-9]{10,12}$)';
                          RegExp regExp = new RegExp(pattern);
                          return (!regExp.hasMatch(e))
                              ? 'angka antara 10 atau 12 digit, jangan pakai huruf tapi angka'
                              : null;
                        },
                        onSaved: (e) => nomor = e,
                        decoration: InputDecoration(
                          hintText: '+62 Nomor Telephone',
                          hintStyle: TextStyle(color: Colors.black),
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 10.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0)),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      Divider(
                        height: 10,
                        color: Colors.black,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: Container(
                            width: 80.0,
                            height: 100.0,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blue, Colors.green[100]],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.bottomCenter,
                                  tileMode: TileMode.clamp,
                                ),
                                borderRadius: BorderRadius.circular(20)),
                            margin: EdgeInsets.all(4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Image.network(
                                      NetworkUrl.cover(widget.model.gambar),
                                      height: 80,
                                      fit: BoxFit.fitHeight,
                                    ),
                                    Text(widget.model.namaProduk),
                                  ],
                                ),
                                Row(children: <Widget>[
                                  Container(
                                    child: IconButton(
                                      onPressed: () {
                                        _incremenTab();
                                      },
                                      icon: Icon(Icons.add),
                                    ),
                                  ),
                                  Container(
                                    child: Text("$i"),
                                  ),
                                  Container(
                                    child: IconButton(
                                      onPressed: () {
                                        _decremenTab();
                                      },
                                      icon: Icon(Icons.remove),
                                    ),
                                  )
                                ]),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: <Widget>[
                    Container(
                      height: 70,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Total Harga : Rp. ${widget.model.harga * i}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () {
                              widget.model.stok == 0
                                  ? showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text("Information"),
                                          content: Text('Stok Barang Habis'),
                                          actions: <Widget>[
                                            FlatButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text("Ok"),
                                            )
                                          ],
                                        );
                                      },
                                    )
                                  : i == 0
                                      ? showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text("Information"),
                                              content: Text(
                                                  'Qty Kosong tidak dapat melanjutkan'),
                                              actions: <Widget>[
                                                FlatButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("Ok"),
                                                )
                                              ],
                                            );
                                          },
                                        )
                                      : check();
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: 50, right: 50, top: 16, bottom: 16),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.purpleAccent),
                              child: Text(
                                "Bayar Sekarang",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        )),
      ),
    );
  }
}
