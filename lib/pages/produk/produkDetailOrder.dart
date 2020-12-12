import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shope/model/orderModel.dart';
import 'package:shope/model/produkDetailOrder.dart';
import 'package:shope/network/network.dart';
import 'package:http/http.dart' as http;
import 'package:shope/pages/produk/uploadStruk.dart';

class ProdukDetailOrder extends StatefulWidget {
  final OrderModel model;
  ProdukDetailOrder(this.model);
  @override
  _ProdukDetailOrderState createState() => _ProdukDetailOrderState();
}

class _ProdukDetailOrderState extends State<ProdukDetailOrder> {
  Uint8List bytes = Uint8List(0);
  List<ProdukOrderModel> list = [];
  List<OrderModel> listO = [];

  String nama = "";
  String id = "";
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      nama = preferences.getString("nama");
      id = preferences.getString("id");
    });
  }

  getOrder() async {
    setState(() {
      loading = true;
    });
    listO.clear();
    final response = await http.get(NetworkUrl.getOrder(id));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      for (Map i in data) {
        listO.add(OrderModel.fromJson(i));
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

  var loading = false;
  var cekData = false;

  getProdukDetailOrder() async {
    setState(() {
      loading = true;
    });
    list.clear();
    final response =
        await http.get(NetworkUrl.getProdukDetailOrder(widget.model.idBeli));
    print(response);
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
            list.add(ProdukOrderModel.fromJson(i));
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

  GlobalKey key = GlobalKey<RefreshIndicatorState>();
  // Menambahkan Favorite
  Future<void> onRefresh() async {
    getPref();
    getProdukDetailOrder();
    getOrder();
  }

  @override
  void initState() {
    super.initState();
    getPref();
    getOrder();
    getProdukDetailOrder();
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
            appBar: AppBar(
              title: Container(
                child: Text(
                  "Detail Order",
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
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: 20),
                                  Center(child: Text("STATUS BARANG")),
                                  Container(
                                    width: 350,
                                    height: 500,
                                    margin: EdgeInsets.all(10),
                                    decoration:
                                        BoxDecoration(color: Colors.white),
                                    child: Column(
                                      children: <Widget>[
                                        SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text("Nomor Tagihan"),
                                            Text(widget.model.idBeli),
                                          ],
                                        ),
                                        Divider(height: 50),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text("Nomor Rekening"),
                                            Text(widget.model.rek),
                                          ],
                                        ),
                                        Divider(height: 50),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text("BANK"),
                                            Text(widget.model.bank),
                                          ],
                                        ),
                                        Divider(height: 50),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text("Status"),
                                            Container(
                                              width: 100,
                                              margin: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: widget.model.status ==
                                                          'menunggu pembayaran'
                                                      ? Colors.orange
                                                      : widget.model.status ==
                                                              'lunas'
                                                          ? Colors.blue
                                                          : widget.model
                                                                      .status ==
                                                                  'pembatalan'
                                                              ? Colors.red
                                                              : Colors.green),
                                              child: Text(
                                                widget.model.status,
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(height: 50),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text("Total tagihan"),
                                            Text("Rp.${widget.model.total}"),
                                          ],
                                        ),
                                        Divider(height: 50),
                                        Text("Struk Pembayaran"),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            InkWell(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              UploadStruk(widget
                                                                  .model)));
                                                },
                                                child: widget.model.struk ==
                                                        "Struk"
                                                    ? Text(
                                                        "Upload Bukti Pembayaran",
                                                        style: TextStyle(
                                                            color: Colors.blue),
                                                      )
                                                    : Text(widget.model.struk)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          IconButton(
                                              icon: Icon(Icons.grid_on),
                                              onPressed: () {}),
                                          Text("List Barang Order")
                                        ],
                                      ),
                                    ],
                                  ),
                                  GridView.builder(
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
                                          onTap: () {},
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
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(height: 30.0),
                                                    Column(children: <Widget>[
                                                      Text("${a.namaProduk}"),
                                                      Text("${a.harga}"),
                                                    ])
                                                  ],
                                                )),
                                          ),
                                        );
                                      }),
                                ],
                              ),
                            )
                          : Container(
                              height: 300,
                              padding: EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[CircularProgressIndicator()],
                              ),
                            ),
                ],
              ),
            )));
  }
}
