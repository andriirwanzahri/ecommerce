import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shope/model/produkModel.dart';
import 'package:shope/network/network.dart';

class ProdukUser extends StatefulWidget {
  @override
  _ProdukUserState createState() => _ProdukUserState();
}

class _ProdukUserState extends State<ProdukUser> {
  String nama = "";
  String id = "";
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      nama = preferences.getString("nama");
      id = preferences.getString("id");
    });
    getProdukUser();
  }

  var loading = false;
  List<ProdukModel> list = [];
  getProdukUser() async {
    setState(() {
      loading = true;
    });
    list.clear();
    final response = await http.get(NetworkUrl.getProdukUser(id));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      setState(() {
        for (Map i in data) {
          list.add(ProdukModel.fromJson(i));
        }
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Produk Saya"),
        elevation: 1,
      ),
      body: Container(
          child: loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final a = list[i];
                    final gambar = a.gambar;
                    return SizedBox(
                      height: 200,
                      child: InkWell(
                        onTap: () {
                          //push ke halaman Produk Terjual
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => AddProduk()));
                        },
                        child: Card(
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: Image.network(
                                  NetworkUrl.cover(gambar),
                                  fit: BoxFit.fill,
                                  loadingBuilder: (context, child, progress) {
                                    return progress == null
                                        ? child
                                        : LinearProgressIndicator();
                                  },
                                ),
                              ),
                              Divider(height: 40),
                              Text(a.namaProduk),
                              Text("${a.harga}"),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )),
    );
  }
}
