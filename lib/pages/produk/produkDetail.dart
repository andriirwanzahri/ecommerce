import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shope/model/produkModel.dart';
import 'package:shope/network/network.dart';
import 'package:http/http.dart' as http;
import 'package:shope/pages/produk/CheckOutOnly.dart';
import 'package:shope/pages/user/login.dart';

class ProdukDetail extends StatefulWidget {
  final ProdukModel model;
  final VoidCallback reload;
  ProdukDetail(this.model, this.reload);
  @override
  _ProdukDetailState createState() => _ProdukDetailState();
}

class _ProdukDetailState extends State<ProdukDetail> {
  String nama = "";
  String id = "";
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      nama = preferences.getString("nama");
      id = preferences.getString("id");
    });
  }

  addCart() async {
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
    final response = await http.post(NetworkUrl.addCart(),
        body: {"unikID": id, "idProduk": widget.model.id});
    final data = convert.jsonDecode(response.body);
    int value = data['value'];
    String message = data['message'];
    if (value == 1) {
      Navigator.pop(context);
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
  }

  addPembelian() async {
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
    final response = await http.post(NetworkUrl.addCart(),
        body: {"unikID": id, "idProduk": widget.model.id});
    final data = convert.jsonDecode(response.body);
    int value = data['value'];
    String message = data['message'];
    if (value == 1) {
      Navigator.pop(context);
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
  }

  @override
  void initState() {
    getPref();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _showModalBottomSheet(context) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 300,
            // color: Color(0xFF737373),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(height: 10.0),
                Container(
                  height: 180.0,
                  width: 200.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.green,
                    image: DecorationImage(
                      image:
                          NetworkImage(NetworkUrl.cover(widget.model.gambar)),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                SizedBox(height: 5.0),
                Text("${widget.model.namaProduk}"),
                SizedBox(height: 5.0),
                Text("Harga Barang : ${widget.model.harga}"),
                InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CheckOutOnly(widget.model),
                        ),
                      );
                    },
                    child: Container(
                      width: 250,
                      height: 40,
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.green,
                      ),
                      child: Center(
                          child: Text(
                        "checkOut",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      )),
                    )),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Produk',
          style: TextStyle(
            fontSize: 15.0,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Image.network(
            NetworkUrl.cover(widget.model.gambar),
            fit: BoxFit.fill,
            height: MediaQuery.of(context).size.height / 3,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.green[400],
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: ListView(children: <Widget>[
                  Text(
                    widget.model.namaProduk,
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("Rp.${widget.model.harga}",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: "maison-neue-bold.woff",
                        fontWeight: FontWeight.bold,
                      )),
                  widget.model.stok == 0
                      ? Text("Stok Habis", style: TextStyle(color: Colors.red))
                      : Text("Stok : ${widget.model.stok}"),
                  Text("Satuan: ${widget.model.satuan}"),
                  Text("kadaluarsa : ${widget.model.tgglKadaluarsa}"),
                  SizedBox(height: 20),
                  Divider(),
                  Text("Deskripsi Barang :",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: "maison-neue-bold.woff",
                        fontWeight: FontWeight.bold,
                      )),
                  Divider(),
                  Text(widget.model.deskripsi),
                ]),
              ),
            ),
          ),
          Container(
            color: Colors.green[400],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.add_shopping_cart),
                  onPressed: () {
                    id == null
                        ? showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Information"),
                                content: Text('anda Belum login'),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        Navigator.of(context).pop(
                                            MaterialPageRoute(
                                                builder: (context) => Login()));
                                      });
                                    },
                                    child: Text("Ok"),
                                  )
                                ],
                              );
                            })
                        : widget.model.stok == 0
                            ? showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Information"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                            'Tidak Dapat Memasukkan Dalam Keranjang'),
                                        Text(
                                          'Stok Produk Habis :)',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Ok"),
                                      )
                                    ],
                                  );
                                })
                            : addCart();
                  },
                  iconSize: 30.0,
                ),
                InkWell(
                    onTap: () {
                      widget.model.stok == 0
                          ? showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    "Information",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        'Tidak Dapat di beli',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Text(
                                        'Stok Produk Habis :)',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("Ok"),
                                    )
                                  ],
                                  elevation: 100.0,
                                  backgroundColor: Colors.transparent,
                                );
                              })
                          : _showModalBottomSheet(context);
                    },
                    child: Container(
                      width: 220,
                      height: 40,
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      child: Center(
                          child: Text(
                        "Beli Sekarang",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      )),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
