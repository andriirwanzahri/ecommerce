import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shope/model/productCartModel.dart';
import 'package:shope/network/network.dart';
import 'package:shope/pages/produk/detailProduk.dart';

class CheckOut extends StatefulWidget {
  @override
  _CheckOutState createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  final _key = new GlobalKey<FormState>();
  List<ProductCartModel> list = [];

  String id, token;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      token = preferences.getString("token");
    });
    _fetchData();
  }

  var loading = false;
  var cekData = true;
  _fetchData() async {
    setState(() {
      loading = true;
    });
    list.clear();
    final response = await http.get(NetworkUrl.getProductCart(id));
    if (response.statusCode == 200) {
      if (response.contentLength == 2) {
        setState(() {
          loading = false;
          cekData = false;
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          for (Map i in data) {
            list.add(ProductCartModel.fromJson(i));
          }
          loading = false;
          cekData = true;
        });
        _getSummaryAmount();
      }
    } else {
      setState(() {
        loading = false;
        cekData = false;
      });
    }
  }

  var totalPrice = "0";
  _getSummaryAmount() async {
    setState(() {
      loading = true;
    });
    final response = await http.get(NetworkUrl.getSummaryAmountCart(id));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)[0];
      String total = data['total'];
      setState(() {
        loading = false;
        totalPrice = total;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  _addQuantity(ProductCartModel model, String tipe) async {
    await http.post(NetworkUrl.updateQuantity(), body: {
      "idProduk": model.id,
      "unikID": id,
      "tipe": tipe,
    });
    setState(() {
      _fetchData();
    });
  }

  String alamat, nomor;
  String nama;
  checkStok() {}
  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
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
      var url = Uri.parse(NetworkUrl.addPembelian());
      var request = http.MultipartRequest("POST", url);
      request.fields['alamat'] = alamat;
      request.fields['nama'] = nama;
      request.fields['nomor'] = nomor;
      request.fields['bank'] = "Bank BNI";
      request.fields['metode'] = "0763192397";
      request.fields['user'] = id;
      request.fields['total'] = totalPrice;

      var response = await request.send();
      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
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
                            child: Text("no"),
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
          child: loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : cekData
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _key,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            TextFormField(
                              validator: (e) => (e.isEmpty)
                                  ? "mohon masukkan Alamat Anda"
                                  : null,
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
                              validator: (e) => (e.isEmpty)
                                  ? "Nama tidak boleh kosong"
                                  : null,
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
                                hintText: 'Nomor Telephone',
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
                            Expanded(
                              child: ListView.builder(
                                itemCount: list.length,
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                itemBuilder: (context, i) {
                                  final a = list[i];
                                  final gambar = a.gambar;
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      child: Container(
                                        width: 80.0,
                                        height: 100.0,
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.blue,
                                                Colors.green[100]
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.bottomCenter,
                                              tileMode: TileMode.clamp,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        margin: EdgeInsets.all(4.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Column(
                                              children: <Widget>[
                                                Image.network(
                                                  NetworkUrl.cover(gambar),
                                                  height: 50,
                                                ),
                                                Text(a.namaProduk),
                                              ],
                                            ),
                                            a.stok == 0
                                                ? Container(
                                                    child: Text("Stok Habis",
                                                        style: TextStyle(
                                                            color: Colors.red)),
                                                  )
                                                : Row(children: <Widget>[
                                                    Container(
                                                      child: Text(a.qty),
                                                    ),
                                                  ]),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            totalPrice == "0"
                                ? SizedBox()
                                : Container(
                                    height: 70,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          "Total Harga : Rp. ${int.parse(totalPrice)}",
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
                                            check();
                                          },
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                left: 50,
                                                right: 50,
                                                top: 16,
                                                bottom: 16),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16),
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
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          " Tidak Ada barang yang ingin di beli",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
