class ProdukModel {
  final String id;
  final String namaProduk;
  final int harga;
  final String satuan;
  final String createDate;
  final String gambar;
  final String status;
  final String deskripsi;
  final int stok;
  final String tgglKadaluarsa;
  final String userID;

  ProdukModel(
      {this.id,
      this.namaProduk,
      this.harga,
      this.createDate,
      this.gambar,
      this.status,
      this.satuan,
      this.deskripsi,
      this.stok,
      this.tgglKadaluarsa,
      this.userID});

  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    return ProdukModel(
      id: json['id'],
      namaProduk: json['namaProduk'],
      harga: json['harga'],
      satuan: json['satuan'],
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
