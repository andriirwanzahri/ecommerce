import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shope/model/kategoriModel.dart';
import 'package:shope/model/produkModel.dart';
import 'package:shope/network/network.dart';
import 'package:shope/pages/produk/CheckOutOnly.dart';
import 'package:shope/pages/produk/produkCart.dart';
import 'package:shope/pages/produk/produkDetail.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:shope/pages/produk/searchProduk.dart';
import 'package:shope/pages/user/login.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var loading = false;
  var filter = false;
  int index;
  String qrcode = "";

  String nama = "";
  String id = "";
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      nama = preferences.getString("nama");
      id = preferences.getString("id");
    });
    getTotalCart();
  }

  addFavorite(ProdukModel model) async {
    setState(() {
      loading = true;
    });
    final response =
        await http.post(NetworkUrl.addFavoriteWithoutLogin(), body: {
      "deviceInfo": id,
      "idProduk": model.id,
    });
    final data = jsonDecode(response.body);
    int value = data['value'];
    String message = data['message'];
    if (value == 1) {
      print(message);
      setState(() {
        loading = false;
      });
    } else {
      print(message);
      setState(() {
        loading = false;
      });
    }
  }

  List<KategoriModel> listKategori = [];
  getKategori() async {
    setState(() {
      loading = true;
    });
    final response = await http.get(NetworkUrl.getProductCategory());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      for (Map i in data) {
        listKategori.add(KategoriModel.fromJson(i));
      }
      setState(() {
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  List<ProdukModel> list = [];
  getProduct() async {
    setState(() {
      loading = true;
    });
    list.clear();
    final response = await http.get(NetworkUrl.getProduct());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      for (Map i in data) {
        list.add(ProdukModel.fromJson(i));
      }
      setState(() {
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  var loadingCart = false;
  var totalCart = "0";
  getTotalCart() async {
    setState(() {
      loadingCart = true;
    });
    final response = await http.get(NetworkUrl.getTotalCart(id));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)[0];
      String total = data['total'];
      setState(() {
        loadingCart = false;
        totalCart = total;
      });
    } else {
      setState(() {
        loadingCart = false;
      });
    }
  }

  Future<void> onRefresh() async {
    getProduct();
    getTotalCart();
    setState(() {
      filter = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getTotalCart();
    getProduct();
    getKategori();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [Colors.green[400], Colors.green[500]],
        begin: Alignment.center,
        end: Alignment.bottomCenter,
        tileMode: TileMode.clamp,
      )),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Container(
            child: Text(
              "PNL SHOP",
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Stack(children: <Widget>[
                Stack(
                  children: <Widget>[
                    Icon(
                      Icons.shopping_cart,
                    ),
                    id == null
                        ? SizedBox()
                        : totalCart == "0"
                            ? SizedBox()
                            : Positioned(
                                top: -3,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red),
                                  child: Text(
                                    '$totalCart',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                  ],
                ),
              ]),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProductCart()));
              },
              iconSize: 20.0,
            )
          ],
        ),
        body: loading
            ? Center(
                child: Column(
                  children: <Widget>[
                    Center(
                        child: Column(
                      children: <Widget>[
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                        Text('Mohon di tunggu'),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    )),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: onRefresh,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                height: 40.0,
                                child: TextField(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SearchProduct(),
                                        ),
                                      );
                                    },
                                    decoration: InputDecoration(
                                        filled: false,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        border: OutlineInputBorder(),
                                        hintText: "Carilah produk anda",
                                        hintStyle:
                                            TextStyle(color: Colors.black),
                                        prefixIcon: Icon(
                                          Icons.search,
                                          size: 21.0,
                                        ))),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(),
                      Container(
                        padding: EdgeInsets.only(
                          left: 10.0,
                        ),
                        child: Row(
                          children: <Widget>[
                            Text(
                              "Kategori",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                      Container(
                        height: 225.0,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: listKategori.length,
                          itemBuilder: (context, i) {
                            final a = listKategori[i];
                            final gambar = a.gambarKategori;

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  filter = true;
                                  index = i;
                                  print(index);
                                });
                              },
                              child: Container(
                                margin:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
                                height: 325.0,
                                width: 340.0,
                                child: Container(
                                  height: 250.0,
                                  width: 325.0,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Color(0xFF399D63),
                                      image: DecorationImage(
                                          image: AssetImage(
                                            "assets/images/$gambar",
                                          ),
                                          fit: BoxFit.cover)),
                                  child: Column(children: <Widget>[
                                    Text(
                                      a.namaKategori,
                                      style: TextStyle(),
                                    )
                                  ]),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Divider(),
                      filter
                          ? listKategori[index].product.length == null
                              ? Container(
                                  height: 100.0,
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text("Maaf Barang Belum")
                                      ]),
                                )
                              : GridView.builder(
                                  itemCount: listKategori[index].product.length,
                                  shrinkWrap: true,
                                  physics: ClampingScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.6 / 1,
                                  ),
                                  itemBuilder: (context, i) {
                                    final a = listKategori[index].product[i];

                                    final gambar = a.gambar;

                                    return InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProdukDetail(a, getProduct),
                                          ),
                                        );
                                      },
                                      child: Card(
                                        child: Container(
                                            width: 100.0,
                                            height: 200.0,
                                            margin: EdgeInsets.all(4.0),
                                            child: Column(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Stack(
                                                    children: <Widget>[
                                                      Image.network(
                                                        NetworkUrl.cover(
                                                            gambar),
                                                        fit: BoxFit.fill,
                                                        loadingBuilder:
                                                            (context, child,
                                                                progress) {
                                                          return progress ==
                                                                  null
                                                              ? child
                                                              : LinearProgressIndicator();
                                                        },
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        right: 0,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color:
                                                                Colors.black12,
                                                          ),
                                                          child: IconButton(
                                                            icon: Icon(Icons
                                                                .favorite_border),
                                                            color: Colors.red,
                                                            onPressed: () {
                                                              addFavorite(a);
                                                            },
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 30.0),
                                                Column(children: <Widget>[
                                                  Text("${a.namaProduk}"),
                                                  Text("Harga : Rp.${a.harga}"),
                                                  a.stok == 0
                                                      ? Text("Stok Habis",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red))
                                                      : Text(
                                                          "Stok : ${a.stok}"),
                                                ]),
                                                InkWell(
                                                    onTap: () {
                                                      a.stok == 0
                                                          ? showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      "Information"),
                                                                  content:
                                                                      Column(
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                          'Tidak Dapat melakukan pembelian'),
                                                                      Text(
                                                                        'Stok Produk Habis :)',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.red),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  actions: <
                                                                      Widget>[
                                                                    FlatButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: Text(
                                                                          "Ok"),
                                                                    )
                                                                  ],
                                                                );
                                                              })
                                                          : showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      "Pembelian"),
                                                                  content:
                                                                      Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: <
                                                                        Widget>[
                                                                      Container(
                                                                        height:
                                                                            180.0,
                                                                        width:
                                                                            200.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(16),
                                                                          color:
                                                                              Colors.green,
                                                                          image:
                                                                              DecorationImage(
                                                                            image:
                                                                                NetworkImage(NetworkUrl.cover(a.gambar)),
                                                                            fit:
                                                                                BoxFit.fill,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              5.0),
                                                                      Text(
                                                                          "${a.namaProduk}"),
                                                                      Text(
                                                                          "Harga : Rp.${a.harga}"),
                                                                    ],
                                                                  ),
                                                                  actions: <
                                                                      Widget>[
                                                                    FlatButton(
                                                                      color: Colors
                                                                          .orange,
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
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
                                                                                            Navigator.of(context).pop(MaterialPageRoute(builder: (context) => Login()));
                                                                                          });
                                                                                        },
                                                                                        child: Text("Ok"),
                                                                                      )
                                                                                    ],
                                                                                  );
                                                                                })
                                                                            : setState(() {
                                                                                Navigator.of(context).push(
                                                                                  MaterialPageRoute(
                                                                                    builder: (context) => CheckOutOnly(a),
                                                                                  ),
                                                                                );
                                                                              });
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        "CheckOut",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                    )
                                                                  ],
                                                                );
                                                              });
                                                    },
                                                    child: Container(
                                                      width: 220,
                                                      height: 40,
                                                      margin:
                                                          EdgeInsets.all(10),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: Colors.green,
                                                      ),
                                                      child: Center(
                                                          child: Text(
                                                        "Beli Sekarang",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                          color: Colors.white,
                                                        ),
                                                      )),
                                                    )),
                                              ],
                                            )),
                                      ),
                                    );
                                  })

                          // Tampil Barang All
                          : GridView.builder(
                              itemCount: list.length,
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.6 / 1,
                              ),
                              itemBuilder: (context, i) {
                                final a = list[i];
                                final gambar = a.gambar;

                                return InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProdukDetail(a, getProduct)));
                                  },
                                  child: Card(
                                    child: Container(
                                        width: 100.0,
                                        height: 200.0,
                                        margin: EdgeInsets.all(4.0),
                                        child: Column(
                                          children: <Widget>[
                                            Expanded(
                                              child: Stack(
                                                children: <Widget>[
                                                  Image.network(
                                                    NetworkUrl.cover(gambar),
                                                    fit: BoxFit.fill,
                                                    loadingBuilder: (context,
                                                        child, progress) {
                                                      return progress == null
                                                          ? child
                                                          : LinearProgressIndicator();
                                                    },
                                                  ),
                                                  Positioned(
                                                      top: 0,
                                                      right: 0,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.black12,
                                                        ),
                                                        child: IconButton(
                                                            icon: Icon(Icons
                                                                .favorite_border),
                                                            color: Colors.red,
                                                            onPressed: () {
                                                              addFavorite(a);
                                                            }),
                                                      ))
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 30.0),
                                            Column(children: <Widget>[
                                              Text("${a.namaProduk}"),
                                              Text("Harga : Rp.${a.harga}"),
                                              a.stok == 0
                                                  ? Text("Stok Habis",
                                                      style: TextStyle(
                                                          color: Colors.red))
                                                  : Text("Stok : ${a.stok}"),
                                            ]),
                                            InkWell(
                                                onTap: () {
                                                  a.stok == 0
                                                      ? showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                  "Information"),
                                                              content: Column(
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                      'Tidak Dapat melakukan pembelian'),
                                                                  Text(
                                                                    'Stok Produk Habis :)',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .red),
                                                                  ),
                                                                ],
                                                              ),
                                                              actions: <Widget>[
                                                                FlatButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: Text(
                                                                      "Ok"),
                                                                )
                                                              ],
                                                            );
                                                          })
                                                      : showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                  "Pembelian"),
                                                              content: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: <
                                                                    Widget>[
                                                                  Container(
                                                                    height:
                                                                        180.0,
                                                                    width:
                                                                        200.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              16),
                                                                      color: Colors
                                                                          .green,
                                                                      image:
                                                                          DecorationImage(
                                                                        image: NetworkImage(
                                                                            NetworkUrl.cover(a.gambar)),
                                                                        fit: BoxFit
                                                                            .fill,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          5.0),
                                                                  Text(a
                                                                      .namaProduk),
                                                                  Text(
                                                                      "${a.harga}"),
                                                                ],
                                                              ),
                                                              actions: <Widget>[
                                                                FlatButton(
                                                                  color: Colors
                                                                      .orange,
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                    id == null
                                                                        ? showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (context) {
                                                                              return AlertDialog(
                                                                                title: Text("Information"),
                                                                                content: Text('anda Belum login'),
                                                                                actions: <Widget>[
                                                                                  FlatButton(
                                                                                    onPressed: () {
                                                                                      Navigator.pop(context);
                                                                                      setState(() {
                                                                                        Navigator.of(context);
                                                                                      });
                                                                                    },
                                                                                    child: Text("Ok"),
                                                                                  )
                                                                                ],
                                                                              );
                                                                            })
                                                                        : setState(
                                                                            () {
                                                                            Navigator.of(context).push(
                                                                              MaterialPageRoute(
                                                                                builder: (context) => CheckOutOnly(a),
                                                                              ),
                                                                            );
                                                                          });
                                                                  },
                                                                  child: Text(
                                                                    "CheckOut",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                )
                                                              ],
                                                            );
                                                          });
                                                },
                                                child: Container(
                                                  width: 220,
                                                  height: 40,
                                                  margin: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Colors.green,
                                                  ),
                                                  child: Center(
                                                      child: Text(
                                                    "Beli Sekarang",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                    ),
                                                  )),
                                                )),
                                          ],
                                        )),
                                  ),
                                );
                              }),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
