import 'package:shope/model/produkModel.dart';

class ProdukTerjualModel {
  final String status;
  final String trans;
  final String alamat;
  final String struk;
  final String nama;
  final String nomer;
  final String total;

  ProdukTerjualModel({
    this.status,
    this.trans,
    this.alamat,
    this.struk,
    this.nama,
    this.nomer,
    this.total,
  });

  factory ProdukTerjualModel.fromJson(Map<String, dynamic> json) {
   

    return ProdukTerjualModel(
      status: json['status'],
      trans: json['trans'],
      alamat: json['alamat'],
      struk: json['struk'],
      nama: json['nama'],
      nomer: json['nomer'],
      total: json['total'],
    );
  }
}
