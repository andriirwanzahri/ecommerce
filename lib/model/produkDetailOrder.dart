class ProdukOrderModel {
  final String id;
  final String namaProduk;
  final int harga;
  final String createDate;
  final String gambar;
  final String status;
  final String deskripsi;
  final int stok;
  final String tgglKadaluarsa;
  final String userID;

  ProdukOrderModel(
      {this.id,
      this.namaProduk,
      this.harga,
      this.createDate,
      this.gambar,
      this.status,
      this.deskripsi,
      this.stok,
      this.tgglKadaluarsa,
      this.userID});

  factory ProdukOrderModel.fromJson(Map<String, dynamic> json) {
    return ProdukOrderModel(
      id: json['id'],
      namaProduk: json['namaProduk'],
      harga: json['harga'],
      createDate: json['createDate'],
      gambar: json['gambar'],
      status: json['status'],
      deskripsi: json['deskripsi'],
      stok: json['stok'],
      tgglKadaluarsa: json['tgglKadaluarsa'],
      userID: json['userID'],
    );
  }
}
