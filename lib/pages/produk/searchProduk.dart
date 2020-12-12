import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shope/model/produkModel.dart';
import 'package:shope/network/network.dart';
import 'package:shope/pages/produk/produkDetail.dart';

class SearchProduct extends StatefulWidget {
  @override
  _SearchProductState createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {
  var loading = false;
  List<ProdukModel> list = [];
  List<ProdukModel> listSearch = [];
  getProduct() async {
    setState(() {
      loading = true;
    });
    list.clear();
    final response = await http.get(NetworkUrl.getProduct());
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

  TextEditingController searchController = TextEditingController();

  onSearch(String text) async {
    listSearch.clear();
    if (text.isEmpty) {
      setState(() {});
    }
    list.forEach((a) {
      if (a.namaProduk.toLowerCase().contains(text)) listSearch.add(a);
    });

    setState(() {});
  }

  Future<void> onRefresh() async {
    getProduct();
  }

  @override
  void initState() {
    super.initState();
    getProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40.0,
          child: TextField(
              autofocus: true,
              controller: searchController,
              onChanged: onSearch,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                  hintText: "Carilah product anda ...",
                  prefixIcon: Icon(
                    Icons.search,
                    size: 21.0,
                  ))),
        ),
      ),
      body: Container(
          child: loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : searchController.text.isNotEmpty || listSearch.length != 0
                  ? GridView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      padding: EdgeInsets.all(10),
                      itemCount: listSearch.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.6 / 1,
                      ),
                      itemBuilder: (context, i) {
                        final a = listSearch[i];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
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
                                            NetworkUrl.cover(a.gambar),
                                            fit: BoxFit.fill,
                                          ),
                                          Positioned(
                                              top: 0,
                                              right: 0,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.black12,
                                                ),
                                                child: IconButton(
                                                    icon: Icon(
                                                        Icons.favorite_border),
                                                    color: Colors.red,
                                                    onPressed: () {}),
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
                                              style:
                                                  TextStyle(color: Colors.red))
                                          : Text("Stok : ${a.stok}"),
                                    ]),
                                    InkWell(
                                        onTap: () {},
                                        child: Container(
                                          width: 220,
                                          height: 40,
                                          margin: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.green,
                                          ),
                                          child: Center(
                                              child: Text(
                                            "Beli Sekarang",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
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
                  : Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.shopping_cart),
                            onPressed: () {},
                            iconSize: 18.0,
                          ),
                          Text(
                            "Please Search your item product",
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    )),
    );
  }
}
