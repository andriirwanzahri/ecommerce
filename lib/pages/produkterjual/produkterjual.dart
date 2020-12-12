import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shope/model/terjualModel.dart';
import 'package:shope/network/network.dart';
import 'package:shope/pages/produkterjual/detailTerjual.dart';

class ProdukTerjual extends StatefulWidget {
  @override
  _ProdukTerjualState createState() => _ProdukTerjualState();
}

class _ProdukTerjualState extends State<ProdukTerjual> {
  List<ProdukTerjualModel> list = [];
  String nama = "";
  String id = "";
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      nama = preferences.getString("nama");
      id = preferences.getString("id");
    });
    getTerjual();
  }

  GlobalKey key = GlobalKey<RefreshIndicatorState>();
  Future<void> onRefresh() async {
    getPref();
  }

  var loading = false;
  var cekData = false;
  getTerjual() async {
    setState(() {
      loading = true;
    });
    list.clear();
    final response = await http.get(NetworkUrl.geterjual(id));
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
            list.add(ProdukTerjualModel.fromJson(i));
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
              "Produk Terjual",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        body: RefreshIndicator(
            onRefresh: onRefresh,
            child: loading
                ? Column(
                    children: <Widget>[
                      Center(child: CircularProgressIndicator()),
                    ],
                  )
                : cekData
                    ? penjualan()
                    : Container(
                        child: Center(
                          child: Text("Barang Belum ada yang terjual"),
                        ),
                      )));
  }

//List Data Produk Terjual
  ListView penjualan() {
    return ListView.builder(
        itemCount: list.length,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemBuilder: (context, i) {
          final a = list[i];
          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => DetailTerjual(a)));
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                color: a.status == 'menunggu pembayaran'
                    ? Colors.orange
                    : a.status == 'telah sampai'
                        ? Colors.green
                        : Colors.blue,
                height: 100,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        a.trans,
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(a.status, style: TextStyle(color: Colors.white))
                    ]),
              ),
            ),
          );
        });
  }
}
