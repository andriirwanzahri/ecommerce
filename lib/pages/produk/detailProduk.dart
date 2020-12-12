import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shope/model/orderModel.dart';
import 'package:shope/network/network.dart';

class DetailSubmitOrder extends StatefulWidget {
  @override
  _DetailSubmitOrderState createState() => _DetailSubmitOrderState();
}

class _DetailSubmitOrderState extends State<DetailSubmitOrder> {
  List<OrderModel> list = [];

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
  getProduct() async {
    setState(() {
      loading = true;
    });
    list.clear();
    final response = await http.get(NetworkUrl.getDataTerakhir(id));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      for (Map i in data) {
        list.add(OrderModel.fromJson(i));
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

  GlobalKey key = GlobalKey<RefreshIndicatorState>();

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
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushNamedAndRemoveUntil(
            "/CheckUser", (Route<dynamic> route) => false);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    "/CheckUser", (Route<dynamic> route) => false);
              }),
          title: Text("Transaksi"),
        ),
        body: RefreshIndicator(
          onRefresh: onRefresh,
          child: loading
              ? Column(
                  children: <Widget>[
                    Center(child: CircularProgressIndicator()),
                  ],
                )
              : ListView.builder(
                  itemCount: list.length,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, i) {
                    final a = list[i];

                    return Container(
                      child: Column(children: <Widget>[
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            "Silahkan Lakukan Pembayaran :",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        Container(
                          width: 350,
                          height: 500,
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.grey[100]),
                          child: Column(children: <Widget>[
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("Nomor Tagihan"),
                                Text(a.idBeli),
                              ],
                            ),
                            Divider(height: 50),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("Nomor Rekening"),
                                Text(a.rek),
                              ],
                            ),
                            Divider(height: 50),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("Transfer Bank"),
                                Text(a.bank),
                              ],
                            ),
                            Divider(height: 50),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("Nama Pembeli"),
                                Text(a.nama),
                              ],
                            ),
                            Divider(height: 50),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("nomer Handphone"),
                                Text(a.nomer),
                              ],
                            ),
                            Divider(height: 50),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("Tanggal Pembelian"),
                                Text(a.createDate),
                              ],
                            ),
                            Divider(height: 50),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("Alamat"),
                                Text(a.alamat),
                              ],
                            ),
                            Divider(height: 50),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("Total Pembayaran"),
                                Text(
                                  "Rp.${a.total}",
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ]),
                        )
                      ]),
                    );
                  }),
        ),
      ),
    );
  }
}
