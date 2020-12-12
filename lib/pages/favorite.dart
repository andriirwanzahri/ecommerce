import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shope/model/produkModel.dart';
import 'package:shope/network/network.dart';
import 'package:shope/pages/produk/produkDetail.dart';
import 'package:shope/pages/user/login.dart';

class FavoriteNonLogin extends StatefulWidget {
  @override
  _FavoriteNonLoginState createState() => _FavoriteNonLoginState();
}

class _FavoriteNonLoginState extends State<FavoriteNonLogin> {
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
                  "SHOPE FAVORITE",
                  style: TextStyle(
                    fontSize: 36,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text("Silahkan Login Terlebih dahulu."),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                  child: Image.asset('assets/images/splash_3.png'),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                Padding(
                  padding: EdgeInsets.only(
                    left: 40.0,
                    right: 40.0,
                  ),
                  child: InkWell(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => Login()));
                      },
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
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

class Favorite extends StatefulWidget {
  @override
  _FavoriteState createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  List<ProdukModel> list = [];

  String nama = "";
  String id = "";
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      nama = preferences.getString("nama");
      id = preferences.getString("id");
    });
    getProduct();
  }

  var loading = false;
  var cekData = false;
  getProduct() async {
    setState(() {
      loading = true;
    });
    list.clear();
    final response =
        await http.get(NetworkUrl.getProductFavoriteWithoutLogin(id));
    if (response.statusCode == 200) {
      if (response.contentLength == 2) {
        setState(() {
          loading = false;
          cekData = false;
        });
      } else {
        final data = jsonDecode(response.body);
        print(data);
        setState(() {
          for (Map i in data) {
            list.add(ProdukModel.fromJson(i));
          }
          loading = false;
          cekData = true;
        });
      }
    } else {
      setState(() {
        loading = false;
        cekData = false;
      });
    }
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

  GlobalKey key = GlobalKey<RefreshIndicatorState>();
  // Menambahkan Favorite
  Future<void> onRefresh() async {
    getPref();
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
          title: Container(
            child: Text(
              "Favorite",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            children: <Widget>[
              loading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : cekData
                      ? Container(
                          child: GridView.builder(
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
                                              Text("${a.harga}"),
                                              a.stok == 0
                                                  ? Text("Stok Habis",
                                                      style: TextStyle(
                                                          color: Colors.red))
                                                  : Text("Stok : ${a.stok}"),
                                            ])
                                          ],
                                        )),
                                  ),
                                );
                              }),
                        )
                      : Container(
                          height: 300,
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Belum ada barang yang favorite",
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
            ],
          ),
        ));
  }
}
