import 'package:flutter/material.dart';
import 'package:shope/model/produkDetailOrder.dart';
import 'package:shope/model/terjualModel.dart';
import 'package:shope/network/network.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailTerjual extends StatefulWidget {
  final ProdukTerjualModel model;
  DetailTerjual(this.model);

  @override
  _DetailTerjualState createState() => _DetailTerjualState();
}

class _DetailTerjualState extends State<DetailTerjual> {
  List<ProdukOrderModel> list = [];
  var loading = false;
  var cekData = false;

  getProdukDetailOrder() async {
    setState(() {
      loading = true;
    });
    list.clear();
    final response =
        await http.get(NetworkUrl.getProdukDetailOrder(widget.model.trans));
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

  @override
  void initState() {
    super.initState();
    getProdukDetailOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Detail Penjualan"),
        ),
        body: ListView(
          children: [
            sizedBoxx(),
            Text("PRODUK",
                textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0)),
            Divider(
              color: Colors.black,
            ),
            produk(),
            Divider(
              height: 50,
              color: Colors.black,
            ),
            Text(
              "Struk Pembayaran",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            Divider(
              height: 50,
              color: Colors.black,
            ),
            widget.model.struk == "Struk"
                ? Text(
                    "Belum Ada Struk Pembayaran",
                    textAlign: TextAlign.center,
                  )
                : gambar()
          ],
        ));
  }

// METHODE PEMANGILAN
  Image gambar() {
    return Image.network(
      NetworkUrl.struk(widget.model.struk),
      loadingBuilder: (context, child, progress) {
        return progress == null ? child : LinearProgressIndicator();
      },
      fit: BoxFit.contain,
    );
  }

  GridView produk() {
    return GridView.builder(
        itemCount: list.length,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 5,
          crossAxisCount: 2,
          childAspectRatio: 1 / 1,
        ),
        itemBuilder: (context, i) {
          final a = list[i];
          final gambar = a.gambar;
          return InkWell(
            child: Card(
              child: Container(
                width: 100.0,
                height: 200.0,
                margin: EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Image.network(
                            NetworkUrl.cover(gambar),
                            loadingBuilder: (context, child, progress) {
                              return progress == null
                                  ? child
                                  : LinearProgressIndicator();
                            },
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Column(
                      children: [
                        Text(a.namaProduk),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  SizedBox sizedBoxx() {
    final b = widget.model;
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Nomor Tagihan'), Text(b.trans)],
            ),
            Divider(color: Colors.black),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Nama Pembeli'), Text(b.nama)],
            ),
            Divider(color: Colors.black),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Nomor Hp'), Text(b.nomer)],
            ),
            Divider(color: Colors.black),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Alamat'), Text(b.alamat)],
            ),
            Divider(color: Colors.black),
          ],
        ),
      ),
    );
  }
}
