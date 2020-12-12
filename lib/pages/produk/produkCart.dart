import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shope/model/productCartModel.dart';
import 'package:shope/network/network.dart';
import 'package:shope/pages/produk/checkOut.dart';
import 'package:shope/pages/user/login.dart';

class ProductCart extends StatefulWidget {
  @override
  _ProductCartState createState() => _ProductCartState();
}

class _ProductCartState extends State<ProductCart> {
  List<ProductCartModel> list = [];

  String nama = "";
  String id = "";
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      nama = preferences.getString("nama");
      id = preferences.getString("id");
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

  var load = false;
  _addQuantity(ProductCartModel model, String tipe) async {
    final response = await http.post(NetworkUrl.updateQuantity(), body: {
      "idProduk": model.id,
      "unikID": id,
      "tipe": tipe,
    });
    final data = jsonDecode(response.body);
    int value = data['value'];
    String message = data['message'];
    if (value == 3) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Information"),
              content: Text(message),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Ok"),
                )
              ],
            );
          });
    } else {
      setState(() {
        _fetchData();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [Colors.green, Colors.green[100]],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        tileMode: TileMode.clamp,
      )),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("Keranjang Belanja "),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Container(
            child: id == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("anda Belum login"),
                        RaisedButton(
                            child: Text("Login"),
                            color: Colors.orange,
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => Login()));
                            })
                      ],
                    ),
                  )
                : cekData
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
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
                                      width: 100.0,
                                      height: 150.0,
                                      decoration: BoxDecoration(
                                          color: Colors.grey[100],
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
                                                height: 100,
                                                fit: BoxFit.fitHeight,
                                              ),
                                              Text(a.namaProduk),
                                              SizedBox(),
                                              Text("${a.harga}")
                                            ],
                                          ),
                                          Row(children: <Widget>[
                                            Container(
                                              child: IconButton(
                                                onPressed: () {
                                                  _addQuantity(a, "tambah");
                                                },
                                                icon: Icon(Icons.add),
                                              ),
                                            ),
                                            Container(
                                              child: Text(a.qty),
                                            ),
                                            Container(
                                              child: IconButton(
                                                onPressed: () {
                                                  // _decremenTab(a);
                                                  _addQuantity(a, "kurang");
                                                },
                                                icon: Icon(Icons.remove),
                                              ),
                                            )
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
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
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
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CheckOut()));
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              color: Colors.orange),
                                          child: Text(
                                            "Checkout",
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
                    : Center(
                        child: Text("produk dalam keranjang belum ada..?!!"),
                      )),
      ),
    );
  }
}
