class OrderModel {
  final String idBeli;
  final String idUser;
  final String alamat;
  final String nama;
  final String nomer;
  final String createDate;
  final String status;
  final String total;
  final String rek;
  final String bank;
  final String struk;

  OrderModel({
    this.idBeli,
    this.idUser,
    this.alamat,
    this.nama,
    this.nomer,
    this.createDate,
    this.status,
    this.rek,
    this.bank,
    this.total,
    this.struk,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      idBeli: json['idBeli'],
      idUser: json['idUser'],
      alamat: json['alamat'],
      nama: json['nama'],
      nomer: json['nomer'],
      createDate: json['createDate'],
      status: json['status'],
      rek: json['rek'],
      bank: json['bank'],
      total: json['total'],
      struk: json['struk'],
    );
  }
}
