import 'package:shope/model/produkModel.dart';

class KategoriModel {
  final String id;
  final String namaKategori;
  final String status;
  final String createDate;
  final String gambarKategori;
  final List<ProdukModel> product;

  KategoriModel(
      {this.id,
      this.namaKategori,
      this.status,
      this.createDate,
      this.gambarKategori,
      this.product});

  factory KategoriModel.fromJson(Map<String, dynamic> json) {
    var list = json['produk'] as List;
    List<ProdukModel> produkList =
        list.map((i) => ProdukModel.fromJson(i)).toList();

    return KategoriModel(
      product: produkList,
      id: json['id'],
      namaKategori: json['namaKategori'],
      status: json['status'],
      createDate: json['createDate'],
      gambarKategori: json['gambarKategori'],
    );
  }
}
