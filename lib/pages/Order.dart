import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shope/model/orderModel.dart';
import 'package:shope/network/network.dart';
import 'package:shope/pages/produk/produkDetailOrder.dart';
import 'package:shope/pages/user/login.dart';

class NonOrder extends StatefulWidget {
  @override
  _NonOrderState createState() => _NonOrderState();
}

class _NonOrderState extends State<NonOrder> {
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
                  "SHOPE ORDER",
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
                  child: Image.asset('assets/images/splash_2.png'),
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

class Order extends StatefulWidget {
  @override
  _OrderState createState() => _OrderState();
}

class _OrderState extends State<Order> {
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
  var cekData = false;
  getProduct() async {
    setState(() {
      loading = true;
    });
    list.clear();
    final response = await http.get(NetworkUrl.getOrder(id));
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
            list.add(OrderModel.fromJson(i));
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
              "Order",
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
                    ? ListView.builder(
                        itemCount: list.length,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (context, i) {
                          final a = list[i];

                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ProdukDetailOrder(a)));
                            },
                            child: Container(
                                width: 100.0,
                                margin: EdgeInsets.all(4.0),
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(height: 30.0),
                                    Column(children: <Widget>[
                                      Text("${a.idBeli}"),
                                    ]),
                                    Container(
                                      width: 220,
                                      height: 40,
                                      margin: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: a.status == 'menunggu pembayaran'
                                            ? Colors.orange
                                            : a.status == 'menunggu Informasi'
                                                ? Colors.blue
                                                : a.status == 'lunas'
                                                    ? Colors.purple
                                                    : Colors.green,
                                      ),
                                      child: Center(
                                          child: Text(
                                        a.status,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      )),
                                    ),
                                  ],
                                )),
                          );
                        })
                    : Container(
                        child: Center(
                          child: Text("belum ada data orderan"),
                        ),
                      )));
  }
}
