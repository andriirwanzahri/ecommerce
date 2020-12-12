class DetailTerjualModel {
  final String status;

  DetailTerjualModel({
    this.status,
  });

  factory DetailTerjualModel.fromJson(Map<String, dynamic> json) {
    return DetailTerjualModel(
      status: json['status'],
    );
  }
}
